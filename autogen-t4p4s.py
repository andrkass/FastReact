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
		out += "conj_table.read(conj_entry_%d, hdr.sensor.sensorId * CONJ_TABLE_SIZE + %d);\n" % (n, n)
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

def genconfig():
	out = ""
	out += "// 5 disj table entry (sen1 != 2500) * tablecount\n\n"
	for entry in range(5):
		for disj in range(options.maxdisj):
			out += "\t\t\t\t\tdisj_table_id.write(%d, 1);\n" % (entry * options.maxdisj + disj)
			out += "\t\t\t\t\tdisj_table_op.write(%d, 4);\n" % (entry * options.maxdisj + disj)
			out += "\t\t\t\t\tdisj_table_val.write(%d, 2500);\n" % (entry * options.maxdisj + disj)
	out += "\n\n"

	out += "\t\t\t\t// Conjunctive table\n\n"
	for sensor in range(options.sensorcount):
		for conj in range(options.maxconj):
			out += "\t\t\t\t\tconj_table.write(%d, 1);\n" % (sensor * options.maxconj + conj)

	out += "\n\n"


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

output = options.output

s = ""
with open(options.p4template) as rf:
	s = rf.read()

s = s.replace('#include "auto-logic.p4"', genlogic().replace('\n', '\n\t\t\t\t'))
s = s.replace('#include "auto-sensor.p4"', gensensor().replace('\n', '\n\t\t\t\t'))
s = s.replace('#include "auto-variables.p4"', genvariables().replace('\n', '\n\t\t\t'))
s = s.replace('#include "auto-constants.p4"', genconstants())
s = s.replace('#include "auto-conj.p4"', genconfig())

with open(output, 'w') as wf:
	wf.write(s)

print "Generated %s " % (output)



