#!/usr/bin/env python2
import argparse

LOGIC_VARS = '''bool should_drop = false;
	bool disj = false;
	bit<32> opcode;
	bit<32> value;
	bit<32> sensor_id;
	bit<32> sensor_value;'''

parser = argparse.ArgumentParser(description="Use this tool to automatically generate the maching logic for FastReact")
parser.add_argument("--sensor-count", dest="sensorcount", metavar='<count>', type=int, default=1000)
parser.add_argument("--max-disjunctive", dest="maxdisj", metavar='<count>', type=int, default=1)
parser.add_argument("--disjunctive-rows", dest="disjrows", metavar='<count>', type=int, default=10)
parser.add_argument("--max-conjunctive", dest="maxconj", metavar='<count>', type=int, default=1)
parser.add_argument("--history-size", dest="historysize", metavar='<count>', type=int, default=5)

parser.add_argument("--output", dest="output", metavar='<filename>', type=str, required = True)
parser.add_argument("--p4-template", dest="p4template", metavar='<filename>', type=str, required = True)
parser.add_argument("--c-template", dest="ctemplate", metavar='<filename>', type=str, required = True)

options = parser.parse_args()

def genconstants():
	return \
		"const bit<32> SENSOR_COUNT = %d;\n" % options.sensorcount + \
		"const bit<32> HISTORY_SIZE = %d;\n" % options.historysize + \
		"const bit<32> DISJ_TABLE_SIZE = %d;\n" % options.maxdisj + \
		"const bit<32> DISJ_TABLE_ROWCOUNT = %d;\n" % options.disjrows + \
		"const bit<32> CONJ_TABLE_SIZE = %d;\n" % options.maxconj
	
def genvariables():
	out = ""
	for n in range(0, options.maxconj):
		out += "bit<32> conj_entry_%d;\n" % n
	return out

def genlogic():
	out = ""
	for n in range(0, options.maxconj):
		out += "conj_table.read(conj_entry_%d, conj_table_index * CONJ_TABLE_SIZE + %d);\n" % (n, n)
	for n in range(0, options.maxconj):
		out += "if (conj_entry_%d != 0) {\n" % n
		out += "\tdisj = false;\n"
		for x in range(0, options.maxdisj):
			out += "\tdisj_table_op.read(opcode, conj_entry_%d * DISJ_TABLE_SIZE+%d);\n" % (n, x) + \
			"\tdisj_table_val.read(value, conj_entry_%d * DISJ_TABLE_SIZE+%d);\n" % (n, x) + \
			"\tdisj_table_id.read(sensor_id, conj_entry_%d * DISJ_TABLE_SIZE+%d);\n" % (n, x) + \
			"\tsensor_index.read(index, sensor_id);\n" + \
			"\tsensor_history.read(sensor_value, sensor_id * HISTORY_SIZE + index);\n" + \
			"\tif (opcode == 1 && sensor_value == value) disj = true;\n" + \
			"\tif (opcode == 2 && sensor_value > value) disj = true;\n" + \
			"\tif (opcode == 3 && sensor_value < value) disj = true;\n" + \
			"\tif (opcode == 4 && sensor_value != value) disj = true;\n\n"

		out += "\tif (!disj) should_drop = true;\n"
		out += "}\n\n"
	return out

def genvars_c():
	out = ""
	for n in range(0, options.maxconj):
		out += "\tuint32_t conj_entry_%d;\n" % (n)
	return out

def genlogic_c():
	out = ""
	for n in range(0, options.maxconj):
		out += "\tREG_READ32(&pif_register_conj_table[conj_table_index * CONJ_TABLE_SIZE + %d], conj_entry_%d);\n" % (n, n)
	for n in range(0, options.maxconj):
		out += "\tif(conj_entry_%d != 0) {\n" % n
		out += "\t\tdisj = 0;\n"
		for x in range(0, options.maxdisj):
			out += "\t\t\tREG_READ32(&pif_register_disj_table_op[conj_entry_%d * DISJ_TABLE_SIZE + %d], op);\n" % (n, x) + \
			"\t\t\tREG_READ32(&pif_register_disj_table_val[conj_entry_%d * DISJ_TABLE_SIZE + %d], val);\n" % (n, x) + \
			"\t\t\tREG_READ32(&pif_register_disj_table_id[conj_entry_%d * DISJ_TABLE_SIZE + %d], id);\n" % (n, x) + \
			"\t\t\tREG_READ32(&pif_register_sensor_index[id], index);\n" + \
			"\t\t\tREG_READ32(&pif_register_sensor_history[id * HISTORY_SIZE + index], sensorvalue);\n" + \
			"\t\t\tif (op == 1 && sensorvalue == val) disj = 1;\n" + \
			"\t\t\tif (op == 2 && sensorvalue > val) disj = 1;\n" + \
			"\t\t\tif (op == 3 && sensorvalue < val) disj = 1;\n" + \
			"\t\t\tif (op == 4 && sensorvalue != val) disj = 1;\n\n"

		out += "\t\tif(disj != 1) return PIF_PLUGIN_RETURN_DROP;\n"
		out += "\t}\n\n"
	return out

def gensensor():
	out = ""
	#Sensor Moving Average
	out += "sensor_avg.read(oldavg, hdr.sensor.sensorId);\n"
	out += "newavg = (oldavg * 6 + hdr.sensor.sensorValue * 2) >> 3;\n"
	out += "sensor_avg.write(hdr.sensor.sensorId, newavg);\n\n"

	#Sensor Round-Robin Index
	out += "sensor_index.read(index, hdr.sensor.sensorId);\n"
	out += "index = index + 1;\n" + \
		   "if (index >= HISTORY_SIZE) {\n" + \
			   "\tindex = 0;\n" + \
		   "}\n"
	out += "sensor_index.write(hdr.sensor.sensorId, index);\n\n"

	#Sensor History
	out += "sensor_history.write(hdr.sensor.sensorId * HISTORY_SIZE + index, hdr.sensor.sensorValue);\n"
	
	return out

output_base = options.output.replace('.p4', '')
p4output = '%s.p4' % output_base
coutput = '%s.c' % output_base

s = ""
with open(options.p4template) as rf:
	s = rf.read()

s = s.replace('#include "auto-logic.p4"', genlogic().replace('\n', '\n\t\t\t\t'))
s = s.replace('#include "auto-sensor.p4"', gensensor().replace('\n', '\n\t\t\t\t'))
s = s.replace('#include "auto-variables.p4"', genvariables().replace('\n', '\n\t\t\t'))
s = s.replace('#include "auto-constants.p4"', genconstants())

with open(p4output, 'w') as wf:
	wf.write(s)

s = ""
with open(options.ctemplate) as rf:
	s = rf.read()

s = s.replace('{sem_count}', str(options.sensorcount))
s = s.replace('{sensor_count}', str(options.sensorcount))
s = s.replace('{history_size}', str(options.historysize))
s = s.replace('{disj_table_size}', str(options.maxdisj))
s = s.replace('{disj_table_rowcount}', str(options.disjrows))
s = s.replace('{conj_table_size}', str(options.maxconj))
s = s.replace('{c_logic}', genlogic_c())
s = s.replace('{c_vars}', genvars_c())

with open(coutput, 'w') as wf:
	wf.write(s)

print "Generated %s and %s" % (p4output, coutput)



