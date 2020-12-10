/* -*- P4_16 -*- */

#include <core.p4>
#include <v1model.p4>

header ethernet_header {
	bit<48> dstAddr;
	bit<48> srcAddr;
	bit<16> etherType;
}

header ipv4_header {
	bit<4> version;
	bit<4> ihl;
	bit<8> diffserv;
	bit<16> totalLen;
	bit<16> identification;
	bit<3> flags;
	bit<13> fragOffset;
	bit<8> ttl;
	bit<8> protocol;
	bit<16> checksum;
	bit<32> srcAddr;
	bit<32> dstAddr;
}

header udp_header {
	bit<16> srcPort;
	bit<16> dstPort;
	bit<16> totalLen;
	bit<16> checksum;
}

header sensor_header {
	bit<32> sensorId;
	bit<32> sensorValue;
}

struct parsed_packet {
	ethernet_header ethernet;
	ipv4_header ipv4;
	udp_header udp;
	sensor_header sensor;
}

struct metadata {
}

parser MyParser(packet_in pkt, out parsed_packet hdr, inout metadata meta, inout standard_metadata_t stdmeta) {
	state start {
		pkt.extract(hdr.ethernet);
		transition select(hdr.ethernet.etherType) {
			0x0800: parse_ipv4;
			default: accept;
		}
	}
	state parse_ipv4 {
		pkt.extract(hdr.ipv4);
		transition select(hdr.ipv4.protocol) {
			0x11: parse_udp;
			default: accept;
		}
	}
	state parse_udp {
		pkt.extract(hdr.udp);
		pkt.extract(hdr.sensor);
		transition accept;
	}
}

control MyDeparser(packet_out pkt, in parsed_packet hdr) {
	apply { pkt.emit(hdr); }
}
const bit<32> SENSOR_COUNT = 1000;
const bit<32> HISTORY_SIZE = 5;
const bit<32> DISJ_TABLE_SIZE = 1;
const bit<32> DISJ_TABLE_ROWCOUNT = 10;
const bit<32> CONJ_TABLE_SIZE = 1;

const bit<32> MP_COUNT = 16;

register<bit<32>>(SENSOR_COUNT*HISTORY_SIZE) sensor_history;
register<bit<32>>(SENSOR_COUNT) sensor_index;
register<bit<32>>(SENSOR_COUNT) sensor_avg;
register<bit<32>>(CONJ_TABLE_SIZE*SENSOR_COUNT*MP_COUNT) conj_table;
register<bit<32>>(DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT) disj_table_op;
register<bit<32>>(DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT) disj_table_val;
register<bit<32>>(DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT) disj_table_id;

#pragma netro reglocked sensor_history;
#pragma netro reglocked sensor_index;
#pragma netro reglocked sensor_avg;
#pragma netro reglocked conj_table;
#pragma netro reglocked disj_table_op;
#pragma netro reglocked disj_table_val;
#pragma netro reglocked disj_table_id;

extern void sem_lock();
extern void sem_unlock();

control MyIngress(inout parsed_packet hdr, inout metadata meta, inout standard_metadata_t stdmeta) {
	action _drop() {
		mark_to_drop();
	}
	action forward(bit<16> port) {
		stdmeta.egress_spec = port;
	}
	action record_sensor_info() {
	}
	action check_drop() {
	}
	table route {
		key = {
			stdmeta.ingress_port: exact;
		}
		actions = {
			forward;
			_drop;
		}
		default_action = _drop;
	}

	apply { 
		if (hdr.sensor.isValid()) {
			bool should_drop = false;
			bool disj = false;
			bit<32> index;
			bit<32> oldavg;
			bit<32> newavg;
			bit<32> opcode;
			bit<32> value;
			bit<32> sensor_id;
			bit<32> sensor_value;
			bit<32> conj_table_index;
			bit<32> conj_entry_0;
			

			route.apply();
			conj_table_index = hdr.sensor.sensorId * MP_COUNT + (bit<32>)stdmeta.egress_spec % 512;

			sem_lock();
			sensor_avg.read(oldavg, hdr.sensor.sensorId);
				newavg = (oldavg * 6 + hdr.sensor.sensorValue * 2) >> 3;
				sensor_avg.write(hdr.sensor.sensorId, newavg);
				
				sensor_index.read(index, hdr.sensor.sensorId);
				index = index + 1;
				if (index >= HISTORY_SIZE) {
					index = 0;
				}
				sensor_index.write(hdr.sensor.sensorId, index);
				
				sensor_history.write(hdr.sensor.sensorId * HISTORY_SIZE + index, hdr.sensor.sensorValue);
				
			sem_unlock();
			
			conj_table.read(conj_entry_0, conj_table_index * CONJ_TABLE_SIZE + 0);
				if (conj_entry_0 != 0) {
					disj = false;
					disj_table_op.read(opcode, conj_entry_0 * DISJ_TABLE_SIZE+0);
					disj_table_val.read(value, conj_entry_0 * DISJ_TABLE_SIZE+0);
					disj_table_id.read(sensor_id, conj_entry_0 * DISJ_TABLE_SIZE+0);
					sensor_index.read(index, sensor_id);
					sensor_history.read(sensor_value, sensor_id * HISTORY_SIZE + index);
					if (opcode == 1 && sensor_value == value) disj = true;
					if (opcode == 2 && sensor_value > value) disj = true;
					if (opcode == 3 && sensor_value < value) disj = true;
					if (opcode == 4 && sensor_value != value) disj = true;
				
					if (!disj) should_drop = true;
				}
				
				

			if (should_drop) {
				_drop();
			}

		}
		else {
			_drop();
		}
	}
}

control MyEgress(inout parsed_packet hdr, inout metadata meta, inout standard_metadata_t stdmeta) {
	apply { }
}

control MyVerify(inout parsed_packet hdr, inout metadata meta) {
	apply { } 
}

control MyCalculate(inout parsed_packet hdr, inout metadata meta) {
	apply {
		update_checksum( hdr.ipv4.isValid(), { 
			hdr.ipv4.version,
			hdr.ipv4.ihl,
			hdr.ipv4.diffserv,
			hdr.ipv4.totalLen,
			hdr.ipv4.identification,
			hdr.ipv4.flags,
			hdr.ipv4.fragOffset,
			hdr.ipv4.ttl,
			hdr.ipv4.protocol,
			hdr.ipv4.srcAddr,
			hdr.ipv4.dstAddr 
		}, hdr.ipv4.checksum, HashAlgorithm.csum16);

		update_checksum_with_payload( hdr.udp.isValid(), {
			hdr.ipv4.srcAddr,
			hdr.ipv4.dstAddr,
			8w0, hdr.ipv4.protocol,
			hdr.udp.totalLen,
			hdr.udp.srcPort,
			hdr.udp.dstPort,
			hdr.udp.totalLen,

			hdr.sensor.sensorId,
			hdr.sensor.sensorValue
		}, hdr.udp.checksum, HashAlgorithm.csum16);
	}
}

V1Switch(
	MyParser(),
	MyVerify(),
	MyIngress(),
	MyEgress(),
	MyCalculate(),
	MyDeparser()
) main;

