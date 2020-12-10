#!/usr/bin/env python2

from scapy.all import *
dstmac = "08:33:33:33:33:08"

class Sensor(Packet):
    name = "Sensor"
    fields_desc = [
        BitField("sensorid", 0, 32), 
        BitField("sensorvalue", 0, 32) 
    ]

def genmac():
	return ':'.join([hex(random.randint(0, 255))[2:].zfill(2) for x in range(0, 6)])

def genip():
	#return '10.0.0.%d' % (random.randint(1, 5))
	return '10.'+'.'.join([str(random.randint(5, 250)) for x in range(0, 3)])

def genport():
	return random.randint(1024, 54000)

def genpayload(sz):
	s = ''
	for r in range(sz):
		s += chr(random.randint(65, 90))
	return s

srceth = "08:33:33:33:33:08"
srceth2 = "08:22:22:22:22:08"
dsteth = "08:33:33:33:33:08"

seqnum = 0
def sensorpkt(sensorid, sensorvalue = 0, port = 5100, sz = 64):
	global seqnum
	seqnum += 1
	return Ether(src = genmac(), dst = genmac()) / \
		IP(src = genip(), dst = genip()) / \
		UDP(sport = genport(), dport = genport()) / \
		Sensor(sensorid = sensorid, sensorvalue = sensorvalue) / \
		Raw(genpayload(sz))

#pcap files for experiments
for sensor_count in [1, 5, 10, 50, 100, 500, 1000]:
	print "Sensor Count: %d" % sensor_count
	for packet_size in [100, 200, 500, 1000, 1492]:
		print "Packet Size: %d" % packet_size
		lst = []
		for s in range(1, sensor_count + 1):
			lst.append(sensorpkt(s, 1, sz = -60 + packet_size))
		wrpcap('sensor-%d-%d.cap'  % (sensor_count, packet_size), lst)

#pcap files for testing
wrpcap('sensor-test.cap', [
	sensorpkt(1, 1, sz = -60 + 100),
	sensorpkt(2, 1, sz = -60 + 100),
	sensorpkt(3, 1, sz = -60 + 100),
	sensorpkt(4, 1, sz = -60 + 100),
	
])

wrpcap('sensor-test-logic.cap', [
	sensorpkt(2, 1, sz = -60 + 100),
	sensorpkt(3, 1, sz = -60 + 100),
	sensorpkt(2, 0, sz = -60 + 100),
	sensorpkt(3, 1, sz = -60 + 100),
	
])

