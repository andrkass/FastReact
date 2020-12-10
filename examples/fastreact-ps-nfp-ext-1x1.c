#include <pif_plugin.h>
#include <nfp.h>
#include <mem_atomic.h>

#define SENSOR_COUNT 1000
#define HISTORY_SIZE 5
#define DISJ_TABLE_SIZE 1
#define DISJ_TABLE_ROWCOUNT 10
#define CONJ_TABLE_SIZE 1
#define SEM_COUNT 1000
#define MP_COUNT 16

#define REG_WRITE32(X, Y) reg_write32_xfer_out = Y; mem_write32(&reg_write32_xfer_out, X, sizeof(uint32_t))
#define REG_READ32(X, Y) mem_read32(&reg_read32_in_xfer, X, sizeof(uint32_t)); Y = reg_read32_in_xfer;
#define REG_INIT() __xwrite uint32_t reg_write32_xfer_out; __xread uint32_t reg_read32_in_xfer

__export __emem int pif_register_sensor_history[HISTORY_SIZE * SENSOR_COUNT];
__export __emem int pif_register_sensor_index[SENSOR_COUNT];
__export __emem int pif_register_sensor_avg[SENSOR_COUNT];
__export __emem int pif_register_sensor_realavg[SENSOR_COUNT];
__export __emem int pif_register_conj_table[CONJ_TABLE_SIZE*SENSOR_COUNT*MP_COUNT];
__export __emem int pif_register_disj_table_op[DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT];
__export __emem int pif_register_disj_table_val[DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT];
__export __emem int pif_register_disj_table_id[DISJ_TABLE_SIZE*DISJ_TABLE_ROWCOUNT];
__export __mem __declspec(addr40) uint32_t tlock[SENSOR_COUNT];

__declspec(imem export aligned(64)) int global_semaphores[SEM_COUNT] = {1, 1, 1, 1, 1, 1, 1, 1, 1};

void semaphore_down(volatile __declspec(mem addr40) void * addr) {
	/* semaphore "DOWN" = claim = wait */
	unsigned int addr_hi, addr_lo;
	__declspec(read_write_reg) int xfer;
	SIGNAL_PAIR my_signal_pair;
	addr_hi = ((unsigned long long int)addr >> 8) & 0xff000000;
	addr_lo = (unsigned long long int)addr & 0xffffffff;
	do {
		xfer = 1;
		__asm {
            mem[test_subsat, xfer, addr_hi, <<8, addr_lo, 1],\
                sig_done[my_signal_pair];
            ctx_arb[my_signal_pair]
        }
	} while (xfer == 0);
}

void semaphore_up(volatile __declspec(mem addr40) void * addr) {
	/* semaphore "UP" = release = signal */
	unsigned int addr_hi, addr_lo;
	__declspec(read_write_reg) int xfer;
	addr_hi = ((unsigned long long int)addr >> 8) & 0xff000000;
	addr_lo = (unsigned long long int)addr & 0xffffffff;

    __asm {
        mem[incr, --, addr_hi, <<8, addr_lo, 1];
    }
}

void pif_plugin_init_master() {
	int i;
	for (i = 0; i < SEM_COUNT; i++) {
		semaphore_up(&global_semaphores[i]);
	}
}

void pif_plugin_init() { }

int pif_plugin_history(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data) {
    __declspec(local_mem) PIF_PLUGIN_sensor_T *sensor_header = pif_plugin_hdr_get_sensor(headers);
    __declspec(local_mem) uint32_t sensorval = PIF_HEADER_GET_sensor___sensorValue(sensor_header);
    __declspec(local_mem) uint32_t sensorid = PIF_HEADER_GET_sensor___sensorId(sensor_header);
    uint32_t index;
    uint32_t avg;
    __xrw uint32_t xfer = 1;
    __xwrite uint32_t xfer_out = 0;
    REG_INIT();

    semaphore_down( &global_semaphores[sensorid]);
    REG_READ32(&pif_register_sensor_index[sensorid], index);
    index = index + 1;
    if(index >= HISTORY_SIZE)
        index = 0;
    REG_WRITE32(&pif_register_sensor_index[sensorid], index);
    REG_WRITE32(&pif_register_sensor_history[sensorid * HISTORY_SIZE + index], sensorval);

    REG_READ32(&pif_register_sensor_avg[sensorid], avg);
    avg = (avg * 6 + sensorval * 2) >> 3;
    REG_WRITE32(&pif_register_sensor_avg[sensorid], avg);
    
    semaphore_up( &global_semaphores[sensorid]);

    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_logic(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data) {
    PIF_PLUGIN_sensor_T *sensor_header = pif_plugin_hdr_get_sensor(headers);
    uint32_t sensorval = PIF_HEADER_GET_sensor___sensorValue(sensor_header);
    uint32_t sensorid = PIF_HEADER_GET_sensor___sensorId(sensor_header);
    uint32_t op, val, id, index, sensorvalue, conj_table_index;
	uint16_t egress_spec;
    int disj = 0;
		uint32_t conj_entry_0;

    REG_INIT();
	
	egress_spec = pif_plugin_meta_get__standard_metadata__egress_spec(headers);
	conj_table_index = sensorid * MP_COUNT + egress_spec % 512;
		REG_READ32(&pif_register_conj_table[conj_table_index * CONJ_TABLE_SIZE + 0], conj_entry_0);
	if(conj_entry_0 != 0) {
		disj = 0;
			REG_READ32(&pif_register_disj_table_op[conj_entry_0 * DISJ_TABLE_SIZE + 0], op);
			REG_READ32(&pif_register_disj_table_val[conj_entry_0 * DISJ_TABLE_SIZE + 0], val);
			REG_READ32(&pif_register_disj_table_id[conj_entry_0 * DISJ_TABLE_SIZE + 0], id);
			REG_READ32(&pif_register_sensor_index[id], index);
			REG_READ32(&pif_register_sensor_history[id * HISTORY_SIZE + index], sensorvalue);
			if (op == 1 && sensorvalue == val) disj = 1;
			if (op == 2 && sensorvalue > val) disj = 1;
			if (op == 3 && sensorvalue < val) disj = 1;
			if (op == 4 && sensorvalue != val) disj = 1;

		if(disj != 1) return PIF_PLUGIN_RETURN_DROP;
	}


    return PIF_PLUGIN_RETURN_FORWARD;
}

