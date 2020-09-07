#include <pif_plugin.h>
#include <nfp.h>
#include <mem_atomic.h>

#define SEM_COUNT {sem_count}
__declspec(imem export aligned(64)) int global_semaphores[SEM_COUNT];

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

int pif_plugin_sem_lock(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data) {
    __declspec(local_mem) PIF_PLUGIN_sensor_T *sensor_header = pif_plugin_hdr_get_sensor(headers);
    __declspec(local_mem) uint32_t sensorid = PIF_HEADER_GET_sensor___sensorId(sensor_header);
    semaphore_down(&global_semaphores[sensorid]);
    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_sem_unlock(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data) {
    __declspec(local_mem) PIF_PLUGIN_sensor_T *sensor_header = pif_plugin_hdr_get_sensor(headers);
    __declspec(local_mem) uint32_t sensorid = PIF_HEADER_GET_sensor___sensorId(sensor_header);
    semaphore_up(&global_semaphores[sensorid]);
    return PIF_PLUGIN_RETURN_FORWARD;
}

