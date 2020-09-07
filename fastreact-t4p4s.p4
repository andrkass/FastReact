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

parser MyParser(packet_in packet, out parsed_packet hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
	state start {
		packet.extract(hdr.ethernet);
		transition select(hdr.ethernet.etherType) {
			0x0800: parse_ipv4;
			default: accept;
		}
	}
	state parse_ipv4 {
		packet.extract(hdr.ipv4);
		transition select(hdr.ipv4.protocol) {
			0x11: parse_udp;
			default: accept;
		}
	}
	state parse_udp {
		packet.extract(hdr.udp);
		packet.extract(hdr.sensor);
		transition accept;
	}
}

control MyDeparser(packet_out packet, in parsed_packet hdr) {
	apply { packet.emit(hdr); }
}
#include "auto-constants.p4"

control ingress(inout parsed_packet hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
	register<bit<32>>(1) configuration;
	register<bit<32>>(SENSOR_COUNT*HISTORY_SIZE) sensor_history;
	register<bit<32>>(SENSOR_COUNT) sensor_index;
	register<bit<32>>(SENSOR_COUNT) sensor_avg;
	register<bit<32>>(CONJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT) conj_table;
	register<bit<32>>(DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT) disj_table_op;
	register<bit<32>>(DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT) disj_table_val;
	register<bit<32>>(DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT) disj_table_id;

	action _nop() {
	}

	action _drop() {
		standard_metadata.egress_spec = standard_metadata.ingress_port;
		standard_metadata.egress_port = standard_metadata.ingress_port;
	}

	action _forward() {
		if(standard_metadata.ingress_port == 0) {
			standard_metadata.egress_spec = 1;
		}
		if(standard_metadata.ingress_port == 1) {
			standard_metadata.egress_spec = 0;
		}
	}

	table route {
		key = {
			standard_metadata.ingress_port: exact;
		}
		actions = {
			_nop;
		}
		default_action = _nop;
	}

	apply { 
		if (hdr.sensor.isValid()) {
			bit<32> config;

			@atomic {
				configuration.read(config, 0);
				if (config == 0) {
					configuration.write(0, 1);

					// Fill entry 1 (sensor1 != 2500)

					// Map conj table to entry 1
					// conj_table.write(1, 1);
					#include "auto-conj.p4"
					_drop();
				}
			}

			bool should_drop = false;
			bool disj = false;
			bit<32> index;
			bit<32> oldavg;
			bit<32> newavg;
			bit<32> opcode;
			bit<32> value;
			bit<32> sensor_id;
			bit<32> sensor_value;
			#include "auto-variables.p4"
			
			@atomic
			{
				#include "auto-sensor.p4"
			}
				
				
			#include "auto-logic.p4"
				
			if (should_drop) {
				_drop();
			}
			else{
				route.apply();
				_forward();
			}
		}
		else {
			_drop();
		}
	}
}

control MyEgress(inout parsed_packet hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
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
	ingress(),
	MyEgress(),
	MyCalculate(),
	MyDeparser()
) main;

