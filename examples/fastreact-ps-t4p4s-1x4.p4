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
const bit<32> SENSOR_COUNT = 1000;
const bit<32> HISTORY_SIZE = 5;
const bit<32> DISJ_TABLE_SIZE = 4;
const bit<32> DISJ_TABLE_ROWCOUNT = 10;
const bit<32> CONJ_TABLE_SIZE = 1;


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
					// 5 disj table entry (sen1 != 2500) * tablecount

					disj_table_id.write(0, 1);
					disj_table_op.write(0, 4);
					disj_table_val.write(0, 2500);
					disj_table_id.write(1, 1);
					disj_table_op.write(1, 4);
					disj_table_val.write(1, 2500);
					disj_table_id.write(2, 1);
					disj_table_op.write(2, 4);
					disj_table_val.write(2, 2500);
					disj_table_id.write(3, 1);
					disj_table_op.write(3, 4);
					disj_table_val.write(3, 2500);
					disj_table_id.write(4, 1);
					disj_table_op.write(4, 4);
					disj_table_val.write(4, 2500);
					disj_table_id.write(5, 1);
					disj_table_op.write(5, 4);
					disj_table_val.write(5, 2500);
					disj_table_id.write(6, 1);
					disj_table_op.write(6, 4);
					disj_table_val.write(6, 2500);
					disj_table_id.write(7, 1);
					disj_table_op.write(7, 4);
					disj_table_val.write(7, 2500);
					disj_table_id.write(8, 1);
					disj_table_op.write(8, 4);
					disj_table_val.write(8, 2500);
					disj_table_id.write(9, 1);
					disj_table_op.write(9, 4);
					disj_table_val.write(9, 2500);
					disj_table_id.write(10, 1);
					disj_table_op.write(10, 4);
					disj_table_val.write(10, 2500);
					disj_table_id.write(11, 1);
					disj_table_op.write(11, 4);
					disj_table_val.write(11, 2500);
					disj_table_id.write(12, 1);
					disj_table_op.write(12, 4);
					disj_table_val.write(12, 2500);
					disj_table_id.write(13, 1);
					disj_table_op.write(13, 4);
					disj_table_val.write(13, 2500);
					disj_table_id.write(14, 1);
					disj_table_op.write(14, 4);
					disj_table_val.write(14, 2500);
					disj_table_id.write(15, 1);
					disj_table_op.write(15, 4);
					disj_table_val.write(15, 2500);
					disj_table_id.write(16, 1);
					disj_table_op.write(16, 4);
					disj_table_val.write(16, 2500);
					disj_table_id.write(17, 1);
					disj_table_op.write(17, 4);
					disj_table_val.write(17, 2500);
					disj_table_id.write(18, 1);
					disj_table_op.write(18, 4);
					disj_table_val.write(18, 2500);
					disj_table_id.write(19, 1);
					disj_table_op.write(19, 4);
					disj_table_val.write(19, 2500);


				// Conjunctive table

					conj_table.write(0, 1);
					conj_table.write(1, 1);
					conj_table.write(2, 1);
					conj_table.write(3, 1);
					conj_table.write(4, 1);
					conj_table.write(5, 1);
					conj_table.write(6, 1);
					conj_table.write(7, 1);
					conj_table.write(8, 1);
					conj_table.write(9, 1);
					conj_table.write(10, 1);
					conj_table.write(11, 1);
					conj_table.write(12, 1);
					conj_table.write(13, 1);
					conj_table.write(14, 1);
					conj_table.write(15, 1);
					conj_table.write(16, 1);
					conj_table.write(17, 1);
					conj_table.write(18, 1);
					conj_table.write(19, 1);
					conj_table.write(20, 1);
					conj_table.write(21, 1);
					conj_table.write(22, 1);
					conj_table.write(23, 1);
					conj_table.write(24, 1);
					conj_table.write(25, 1);
					conj_table.write(26, 1);
					conj_table.write(27, 1);
					conj_table.write(28, 1);
					conj_table.write(29, 1);
					conj_table.write(30, 1);
					conj_table.write(31, 1);
					conj_table.write(32, 1);
					conj_table.write(33, 1);
					conj_table.write(34, 1);
					conj_table.write(35, 1);
					conj_table.write(36, 1);
					conj_table.write(37, 1);
					conj_table.write(38, 1);
					conj_table.write(39, 1);
					conj_table.write(40, 1);
					conj_table.write(41, 1);
					conj_table.write(42, 1);
					conj_table.write(43, 1);
					conj_table.write(44, 1);
					conj_table.write(45, 1);
					conj_table.write(46, 1);
					conj_table.write(47, 1);
					conj_table.write(48, 1);
					conj_table.write(49, 1);
					conj_table.write(50, 1);
					conj_table.write(51, 1);
					conj_table.write(52, 1);
					conj_table.write(53, 1);
					conj_table.write(54, 1);
					conj_table.write(55, 1);
					conj_table.write(56, 1);
					conj_table.write(57, 1);
					conj_table.write(58, 1);
					conj_table.write(59, 1);
					conj_table.write(60, 1);
					conj_table.write(61, 1);
					conj_table.write(62, 1);
					conj_table.write(63, 1);
					conj_table.write(64, 1);
					conj_table.write(65, 1);
					conj_table.write(66, 1);
					conj_table.write(67, 1);
					conj_table.write(68, 1);
					conj_table.write(69, 1);
					conj_table.write(70, 1);
					conj_table.write(71, 1);
					conj_table.write(72, 1);
					conj_table.write(73, 1);
					conj_table.write(74, 1);
					conj_table.write(75, 1);
					conj_table.write(76, 1);
					conj_table.write(77, 1);
					conj_table.write(78, 1);
					conj_table.write(79, 1);
					conj_table.write(80, 1);
					conj_table.write(81, 1);
					conj_table.write(82, 1);
					conj_table.write(83, 1);
					conj_table.write(84, 1);
					conj_table.write(85, 1);
					conj_table.write(86, 1);
					conj_table.write(87, 1);
					conj_table.write(88, 1);
					conj_table.write(89, 1);
					conj_table.write(90, 1);
					conj_table.write(91, 1);
					conj_table.write(92, 1);
					conj_table.write(93, 1);
					conj_table.write(94, 1);
					conj_table.write(95, 1);
					conj_table.write(96, 1);
					conj_table.write(97, 1);
					conj_table.write(98, 1);
					conj_table.write(99, 1);
					conj_table.write(100, 1);
					conj_table.write(101, 1);
					conj_table.write(102, 1);
					conj_table.write(103, 1);
					conj_table.write(104, 1);
					conj_table.write(105, 1);
					conj_table.write(106, 1);
					conj_table.write(107, 1);
					conj_table.write(108, 1);
					conj_table.write(109, 1);
					conj_table.write(110, 1);
					conj_table.write(111, 1);
					conj_table.write(112, 1);
					conj_table.write(113, 1);
					conj_table.write(114, 1);
					conj_table.write(115, 1);
					conj_table.write(116, 1);
					conj_table.write(117, 1);
					conj_table.write(118, 1);
					conj_table.write(119, 1);
					conj_table.write(120, 1);
					conj_table.write(121, 1);
					conj_table.write(122, 1);
					conj_table.write(123, 1);
					conj_table.write(124, 1);
					conj_table.write(125, 1);
					conj_table.write(126, 1);
					conj_table.write(127, 1);
					conj_table.write(128, 1);
					conj_table.write(129, 1);
					conj_table.write(130, 1);
					conj_table.write(131, 1);
					conj_table.write(132, 1);
					conj_table.write(133, 1);
					conj_table.write(134, 1);
					conj_table.write(135, 1);
					conj_table.write(136, 1);
					conj_table.write(137, 1);
					conj_table.write(138, 1);
					conj_table.write(139, 1);
					conj_table.write(140, 1);
					conj_table.write(141, 1);
					conj_table.write(142, 1);
					conj_table.write(143, 1);
					conj_table.write(144, 1);
					conj_table.write(145, 1);
					conj_table.write(146, 1);
					conj_table.write(147, 1);
					conj_table.write(148, 1);
					conj_table.write(149, 1);
					conj_table.write(150, 1);
					conj_table.write(151, 1);
					conj_table.write(152, 1);
					conj_table.write(153, 1);
					conj_table.write(154, 1);
					conj_table.write(155, 1);
					conj_table.write(156, 1);
					conj_table.write(157, 1);
					conj_table.write(158, 1);
					conj_table.write(159, 1);
					conj_table.write(160, 1);
					conj_table.write(161, 1);
					conj_table.write(162, 1);
					conj_table.write(163, 1);
					conj_table.write(164, 1);
					conj_table.write(165, 1);
					conj_table.write(166, 1);
					conj_table.write(167, 1);
					conj_table.write(168, 1);
					conj_table.write(169, 1);
					conj_table.write(170, 1);
					conj_table.write(171, 1);
					conj_table.write(172, 1);
					conj_table.write(173, 1);
					conj_table.write(174, 1);
					conj_table.write(175, 1);
					conj_table.write(176, 1);
					conj_table.write(177, 1);
					conj_table.write(178, 1);
					conj_table.write(179, 1);
					conj_table.write(180, 1);
					conj_table.write(181, 1);
					conj_table.write(182, 1);
					conj_table.write(183, 1);
					conj_table.write(184, 1);
					conj_table.write(185, 1);
					conj_table.write(186, 1);
					conj_table.write(187, 1);
					conj_table.write(188, 1);
					conj_table.write(189, 1);
					conj_table.write(190, 1);
					conj_table.write(191, 1);
					conj_table.write(192, 1);
					conj_table.write(193, 1);
					conj_table.write(194, 1);
					conj_table.write(195, 1);
					conj_table.write(196, 1);
					conj_table.write(197, 1);
					conj_table.write(198, 1);
					conj_table.write(199, 1);
					conj_table.write(200, 1);
					conj_table.write(201, 1);
					conj_table.write(202, 1);
					conj_table.write(203, 1);
					conj_table.write(204, 1);
					conj_table.write(205, 1);
					conj_table.write(206, 1);
					conj_table.write(207, 1);
					conj_table.write(208, 1);
					conj_table.write(209, 1);
					conj_table.write(210, 1);
					conj_table.write(211, 1);
					conj_table.write(212, 1);
					conj_table.write(213, 1);
					conj_table.write(214, 1);
					conj_table.write(215, 1);
					conj_table.write(216, 1);
					conj_table.write(217, 1);
					conj_table.write(218, 1);
					conj_table.write(219, 1);
					conj_table.write(220, 1);
					conj_table.write(221, 1);
					conj_table.write(222, 1);
					conj_table.write(223, 1);
					conj_table.write(224, 1);
					conj_table.write(225, 1);
					conj_table.write(226, 1);
					conj_table.write(227, 1);
					conj_table.write(228, 1);
					conj_table.write(229, 1);
					conj_table.write(230, 1);
					conj_table.write(231, 1);
					conj_table.write(232, 1);
					conj_table.write(233, 1);
					conj_table.write(234, 1);
					conj_table.write(235, 1);
					conj_table.write(236, 1);
					conj_table.write(237, 1);
					conj_table.write(238, 1);
					conj_table.write(239, 1);
					conj_table.write(240, 1);
					conj_table.write(241, 1);
					conj_table.write(242, 1);
					conj_table.write(243, 1);
					conj_table.write(244, 1);
					conj_table.write(245, 1);
					conj_table.write(246, 1);
					conj_table.write(247, 1);
					conj_table.write(248, 1);
					conj_table.write(249, 1);
					conj_table.write(250, 1);
					conj_table.write(251, 1);
					conj_table.write(252, 1);
					conj_table.write(253, 1);
					conj_table.write(254, 1);
					conj_table.write(255, 1);
					conj_table.write(256, 1);
					conj_table.write(257, 1);
					conj_table.write(258, 1);
					conj_table.write(259, 1);
					conj_table.write(260, 1);
					conj_table.write(261, 1);
					conj_table.write(262, 1);
					conj_table.write(263, 1);
					conj_table.write(264, 1);
					conj_table.write(265, 1);
					conj_table.write(266, 1);
					conj_table.write(267, 1);
					conj_table.write(268, 1);
					conj_table.write(269, 1);
					conj_table.write(270, 1);
					conj_table.write(271, 1);
					conj_table.write(272, 1);
					conj_table.write(273, 1);
					conj_table.write(274, 1);
					conj_table.write(275, 1);
					conj_table.write(276, 1);
					conj_table.write(277, 1);
					conj_table.write(278, 1);
					conj_table.write(279, 1);
					conj_table.write(280, 1);
					conj_table.write(281, 1);
					conj_table.write(282, 1);
					conj_table.write(283, 1);
					conj_table.write(284, 1);
					conj_table.write(285, 1);
					conj_table.write(286, 1);
					conj_table.write(287, 1);
					conj_table.write(288, 1);
					conj_table.write(289, 1);
					conj_table.write(290, 1);
					conj_table.write(291, 1);
					conj_table.write(292, 1);
					conj_table.write(293, 1);
					conj_table.write(294, 1);
					conj_table.write(295, 1);
					conj_table.write(296, 1);
					conj_table.write(297, 1);
					conj_table.write(298, 1);
					conj_table.write(299, 1);
					conj_table.write(300, 1);
					conj_table.write(301, 1);
					conj_table.write(302, 1);
					conj_table.write(303, 1);
					conj_table.write(304, 1);
					conj_table.write(305, 1);
					conj_table.write(306, 1);
					conj_table.write(307, 1);
					conj_table.write(308, 1);
					conj_table.write(309, 1);
					conj_table.write(310, 1);
					conj_table.write(311, 1);
					conj_table.write(312, 1);
					conj_table.write(313, 1);
					conj_table.write(314, 1);
					conj_table.write(315, 1);
					conj_table.write(316, 1);
					conj_table.write(317, 1);
					conj_table.write(318, 1);
					conj_table.write(319, 1);
					conj_table.write(320, 1);
					conj_table.write(321, 1);
					conj_table.write(322, 1);
					conj_table.write(323, 1);
					conj_table.write(324, 1);
					conj_table.write(325, 1);
					conj_table.write(326, 1);
					conj_table.write(327, 1);
					conj_table.write(328, 1);
					conj_table.write(329, 1);
					conj_table.write(330, 1);
					conj_table.write(331, 1);
					conj_table.write(332, 1);
					conj_table.write(333, 1);
					conj_table.write(334, 1);
					conj_table.write(335, 1);
					conj_table.write(336, 1);
					conj_table.write(337, 1);
					conj_table.write(338, 1);
					conj_table.write(339, 1);
					conj_table.write(340, 1);
					conj_table.write(341, 1);
					conj_table.write(342, 1);
					conj_table.write(343, 1);
					conj_table.write(344, 1);
					conj_table.write(345, 1);
					conj_table.write(346, 1);
					conj_table.write(347, 1);
					conj_table.write(348, 1);
					conj_table.write(349, 1);
					conj_table.write(350, 1);
					conj_table.write(351, 1);
					conj_table.write(352, 1);
					conj_table.write(353, 1);
					conj_table.write(354, 1);
					conj_table.write(355, 1);
					conj_table.write(356, 1);
					conj_table.write(357, 1);
					conj_table.write(358, 1);
					conj_table.write(359, 1);
					conj_table.write(360, 1);
					conj_table.write(361, 1);
					conj_table.write(362, 1);
					conj_table.write(363, 1);
					conj_table.write(364, 1);
					conj_table.write(365, 1);
					conj_table.write(366, 1);
					conj_table.write(367, 1);
					conj_table.write(368, 1);
					conj_table.write(369, 1);
					conj_table.write(370, 1);
					conj_table.write(371, 1);
					conj_table.write(372, 1);
					conj_table.write(373, 1);
					conj_table.write(374, 1);
					conj_table.write(375, 1);
					conj_table.write(376, 1);
					conj_table.write(377, 1);
					conj_table.write(378, 1);
					conj_table.write(379, 1);
					conj_table.write(380, 1);
					conj_table.write(381, 1);
					conj_table.write(382, 1);
					conj_table.write(383, 1);
					conj_table.write(384, 1);
					conj_table.write(385, 1);
					conj_table.write(386, 1);
					conj_table.write(387, 1);
					conj_table.write(388, 1);
					conj_table.write(389, 1);
					conj_table.write(390, 1);
					conj_table.write(391, 1);
					conj_table.write(392, 1);
					conj_table.write(393, 1);
					conj_table.write(394, 1);
					conj_table.write(395, 1);
					conj_table.write(396, 1);
					conj_table.write(397, 1);
					conj_table.write(398, 1);
					conj_table.write(399, 1);
					conj_table.write(400, 1);
					conj_table.write(401, 1);
					conj_table.write(402, 1);
					conj_table.write(403, 1);
					conj_table.write(404, 1);
					conj_table.write(405, 1);
					conj_table.write(406, 1);
					conj_table.write(407, 1);
					conj_table.write(408, 1);
					conj_table.write(409, 1);
					conj_table.write(410, 1);
					conj_table.write(411, 1);
					conj_table.write(412, 1);
					conj_table.write(413, 1);
					conj_table.write(414, 1);
					conj_table.write(415, 1);
					conj_table.write(416, 1);
					conj_table.write(417, 1);
					conj_table.write(418, 1);
					conj_table.write(419, 1);
					conj_table.write(420, 1);
					conj_table.write(421, 1);
					conj_table.write(422, 1);
					conj_table.write(423, 1);
					conj_table.write(424, 1);
					conj_table.write(425, 1);
					conj_table.write(426, 1);
					conj_table.write(427, 1);
					conj_table.write(428, 1);
					conj_table.write(429, 1);
					conj_table.write(430, 1);
					conj_table.write(431, 1);
					conj_table.write(432, 1);
					conj_table.write(433, 1);
					conj_table.write(434, 1);
					conj_table.write(435, 1);
					conj_table.write(436, 1);
					conj_table.write(437, 1);
					conj_table.write(438, 1);
					conj_table.write(439, 1);
					conj_table.write(440, 1);
					conj_table.write(441, 1);
					conj_table.write(442, 1);
					conj_table.write(443, 1);
					conj_table.write(444, 1);
					conj_table.write(445, 1);
					conj_table.write(446, 1);
					conj_table.write(447, 1);
					conj_table.write(448, 1);
					conj_table.write(449, 1);
					conj_table.write(450, 1);
					conj_table.write(451, 1);
					conj_table.write(452, 1);
					conj_table.write(453, 1);
					conj_table.write(454, 1);
					conj_table.write(455, 1);
					conj_table.write(456, 1);
					conj_table.write(457, 1);
					conj_table.write(458, 1);
					conj_table.write(459, 1);
					conj_table.write(460, 1);
					conj_table.write(461, 1);
					conj_table.write(462, 1);
					conj_table.write(463, 1);
					conj_table.write(464, 1);
					conj_table.write(465, 1);
					conj_table.write(466, 1);
					conj_table.write(467, 1);
					conj_table.write(468, 1);
					conj_table.write(469, 1);
					conj_table.write(470, 1);
					conj_table.write(471, 1);
					conj_table.write(472, 1);
					conj_table.write(473, 1);
					conj_table.write(474, 1);
					conj_table.write(475, 1);
					conj_table.write(476, 1);
					conj_table.write(477, 1);
					conj_table.write(478, 1);
					conj_table.write(479, 1);
					conj_table.write(480, 1);
					conj_table.write(481, 1);
					conj_table.write(482, 1);
					conj_table.write(483, 1);
					conj_table.write(484, 1);
					conj_table.write(485, 1);
					conj_table.write(486, 1);
					conj_table.write(487, 1);
					conj_table.write(488, 1);
					conj_table.write(489, 1);
					conj_table.write(490, 1);
					conj_table.write(491, 1);
					conj_table.write(492, 1);
					conj_table.write(493, 1);
					conj_table.write(494, 1);
					conj_table.write(495, 1);
					conj_table.write(496, 1);
					conj_table.write(497, 1);
					conj_table.write(498, 1);
					conj_table.write(499, 1);
					conj_table.write(500, 1);
					conj_table.write(501, 1);
					conj_table.write(502, 1);
					conj_table.write(503, 1);
					conj_table.write(504, 1);
					conj_table.write(505, 1);
					conj_table.write(506, 1);
					conj_table.write(507, 1);
					conj_table.write(508, 1);
					conj_table.write(509, 1);
					conj_table.write(510, 1);
					conj_table.write(511, 1);
					conj_table.write(512, 1);
					conj_table.write(513, 1);
					conj_table.write(514, 1);
					conj_table.write(515, 1);
					conj_table.write(516, 1);
					conj_table.write(517, 1);
					conj_table.write(518, 1);
					conj_table.write(519, 1);
					conj_table.write(520, 1);
					conj_table.write(521, 1);
					conj_table.write(522, 1);
					conj_table.write(523, 1);
					conj_table.write(524, 1);
					conj_table.write(525, 1);
					conj_table.write(526, 1);
					conj_table.write(527, 1);
					conj_table.write(528, 1);
					conj_table.write(529, 1);
					conj_table.write(530, 1);
					conj_table.write(531, 1);
					conj_table.write(532, 1);
					conj_table.write(533, 1);
					conj_table.write(534, 1);
					conj_table.write(535, 1);
					conj_table.write(536, 1);
					conj_table.write(537, 1);
					conj_table.write(538, 1);
					conj_table.write(539, 1);
					conj_table.write(540, 1);
					conj_table.write(541, 1);
					conj_table.write(542, 1);
					conj_table.write(543, 1);
					conj_table.write(544, 1);
					conj_table.write(545, 1);
					conj_table.write(546, 1);
					conj_table.write(547, 1);
					conj_table.write(548, 1);
					conj_table.write(549, 1);
					conj_table.write(550, 1);
					conj_table.write(551, 1);
					conj_table.write(552, 1);
					conj_table.write(553, 1);
					conj_table.write(554, 1);
					conj_table.write(555, 1);
					conj_table.write(556, 1);
					conj_table.write(557, 1);
					conj_table.write(558, 1);
					conj_table.write(559, 1);
					conj_table.write(560, 1);
					conj_table.write(561, 1);
					conj_table.write(562, 1);
					conj_table.write(563, 1);
					conj_table.write(564, 1);
					conj_table.write(565, 1);
					conj_table.write(566, 1);
					conj_table.write(567, 1);
					conj_table.write(568, 1);
					conj_table.write(569, 1);
					conj_table.write(570, 1);
					conj_table.write(571, 1);
					conj_table.write(572, 1);
					conj_table.write(573, 1);
					conj_table.write(574, 1);
					conj_table.write(575, 1);
					conj_table.write(576, 1);
					conj_table.write(577, 1);
					conj_table.write(578, 1);
					conj_table.write(579, 1);
					conj_table.write(580, 1);
					conj_table.write(581, 1);
					conj_table.write(582, 1);
					conj_table.write(583, 1);
					conj_table.write(584, 1);
					conj_table.write(585, 1);
					conj_table.write(586, 1);
					conj_table.write(587, 1);
					conj_table.write(588, 1);
					conj_table.write(589, 1);
					conj_table.write(590, 1);
					conj_table.write(591, 1);
					conj_table.write(592, 1);
					conj_table.write(593, 1);
					conj_table.write(594, 1);
					conj_table.write(595, 1);
					conj_table.write(596, 1);
					conj_table.write(597, 1);
					conj_table.write(598, 1);
					conj_table.write(599, 1);
					conj_table.write(600, 1);
					conj_table.write(601, 1);
					conj_table.write(602, 1);
					conj_table.write(603, 1);
					conj_table.write(604, 1);
					conj_table.write(605, 1);
					conj_table.write(606, 1);
					conj_table.write(607, 1);
					conj_table.write(608, 1);
					conj_table.write(609, 1);
					conj_table.write(610, 1);
					conj_table.write(611, 1);
					conj_table.write(612, 1);
					conj_table.write(613, 1);
					conj_table.write(614, 1);
					conj_table.write(615, 1);
					conj_table.write(616, 1);
					conj_table.write(617, 1);
					conj_table.write(618, 1);
					conj_table.write(619, 1);
					conj_table.write(620, 1);
					conj_table.write(621, 1);
					conj_table.write(622, 1);
					conj_table.write(623, 1);
					conj_table.write(624, 1);
					conj_table.write(625, 1);
					conj_table.write(626, 1);
					conj_table.write(627, 1);
					conj_table.write(628, 1);
					conj_table.write(629, 1);
					conj_table.write(630, 1);
					conj_table.write(631, 1);
					conj_table.write(632, 1);
					conj_table.write(633, 1);
					conj_table.write(634, 1);
					conj_table.write(635, 1);
					conj_table.write(636, 1);
					conj_table.write(637, 1);
					conj_table.write(638, 1);
					conj_table.write(639, 1);
					conj_table.write(640, 1);
					conj_table.write(641, 1);
					conj_table.write(642, 1);
					conj_table.write(643, 1);
					conj_table.write(644, 1);
					conj_table.write(645, 1);
					conj_table.write(646, 1);
					conj_table.write(647, 1);
					conj_table.write(648, 1);
					conj_table.write(649, 1);
					conj_table.write(650, 1);
					conj_table.write(651, 1);
					conj_table.write(652, 1);
					conj_table.write(653, 1);
					conj_table.write(654, 1);
					conj_table.write(655, 1);
					conj_table.write(656, 1);
					conj_table.write(657, 1);
					conj_table.write(658, 1);
					conj_table.write(659, 1);
					conj_table.write(660, 1);
					conj_table.write(661, 1);
					conj_table.write(662, 1);
					conj_table.write(663, 1);
					conj_table.write(664, 1);
					conj_table.write(665, 1);
					conj_table.write(666, 1);
					conj_table.write(667, 1);
					conj_table.write(668, 1);
					conj_table.write(669, 1);
					conj_table.write(670, 1);
					conj_table.write(671, 1);
					conj_table.write(672, 1);
					conj_table.write(673, 1);
					conj_table.write(674, 1);
					conj_table.write(675, 1);
					conj_table.write(676, 1);
					conj_table.write(677, 1);
					conj_table.write(678, 1);
					conj_table.write(679, 1);
					conj_table.write(680, 1);
					conj_table.write(681, 1);
					conj_table.write(682, 1);
					conj_table.write(683, 1);
					conj_table.write(684, 1);
					conj_table.write(685, 1);
					conj_table.write(686, 1);
					conj_table.write(687, 1);
					conj_table.write(688, 1);
					conj_table.write(689, 1);
					conj_table.write(690, 1);
					conj_table.write(691, 1);
					conj_table.write(692, 1);
					conj_table.write(693, 1);
					conj_table.write(694, 1);
					conj_table.write(695, 1);
					conj_table.write(696, 1);
					conj_table.write(697, 1);
					conj_table.write(698, 1);
					conj_table.write(699, 1);
					conj_table.write(700, 1);
					conj_table.write(701, 1);
					conj_table.write(702, 1);
					conj_table.write(703, 1);
					conj_table.write(704, 1);
					conj_table.write(705, 1);
					conj_table.write(706, 1);
					conj_table.write(707, 1);
					conj_table.write(708, 1);
					conj_table.write(709, 1);
					conj_table.write(710, 1);
					conj_table.write(711, 1);
					conj_table.write(712, 1);
					conj_table.write(713, 1);
					conj_table.write(714, 1);
					conj_table.write(715, 1);
					conj_table.write(716, 1);
					conj_table.write(717, 1);
					conj_table.write(718, 1);
					conj_table.write(719, 1);
					conj_table.write(720, 1);
					conj_table.write(721, 1);
					conj_table.write(722, 1);
					conj_table.write(723, 1);
					conj_table.write(724, 1);
					conj_table.write(725, 1);
					conj_table.write(726, 1);
					conj_table.write(727, 1);
					conj_table.write(728, 1);
					conj_table.write(729, 1);
					conj_table.write(730, 1);
					conj_table.write(731, 1);
					conj_table.write(732, 1);
					conj_table.write(733, 1);
					conj_table.write(734, 1);
					conj_table.write(735, 1);
					conj_table.write(736, 1);
					conj_table.write(737, 1);
					conj_table.write(738, 1);
					conj_table.write(739, 1);
					conj_table.write(740, 1);
					conj_table.write(741, 1);
					conj_table.write(742, 1);
					conj_table.write(743, 1);
					conj_table.write(744, 1);
					conj_table.write(745, 1);
					conj_table.write(746, 1);
					conj_table.write(747, 1);
					conj_table.write(748, 1);
					conj_table.write(749, 1);
					conj_table.write(750, 1);
					conj_table.write(751, 1);
					conj_table.write(752, 1);
					conj_table.write(753, 1);
					conj_table.write(754, 1);
					conj_table.write(755, 1);
					conj_table.write(756, 1);
					conj_table.write(757, 1);
					conj_table.write(758, 1);
					conj_table.write(759, 1);
					conj_table.write(760, 1);
					conj_table.write(761, 1);
					conj_table.write(762, 1);
					conj_table.write(763, 1);
					conj_table.write(764, 1);
					conj_table.write(765, 1);
					conj_table.write(766, 1);
					conj_table.write(767, 1);
					conj_table.write(768, 1);
					conj_table.write(769, 1);
					conj_table.write(770, 1);
					conj_table.write(771, 1);
					conj_table.write(772, 1);
					conj_table.write(773, 1);
					conj_table.write(774, 1);
					conj_table.write(775, 1);
					conj_table.write(776, 1);
					conj_table.write(777, 1);
					conj_table.write(778, 1);
					conj_table.write(779, 1);
					conj_table.write(780, 1);
					conj_table.write(781, 1);
					conj_table.write(782, 1);
					conj_table.write(783, 1);
					conj_table.write(784, 1);
					conj_table.write(785, 1);
					conj_table.write(786, 1);
					conj_table.write(787, 1);
					conj_table.write(788, 1);
					conj_table.write(789, 1);
					conj_table.write(790, 1);
					conj_table.write(791, 1);
					conj_table.write(792, 1);
					conj_table.write(793, 1);
					conj_table.write(794, 1);
					conj_table.write(795, 1);
					conj_table.write(796, 1);
					conj_table.write(797, 1);
					conj_table.write(798, 1);
					conj_table.write(799, 1);
					conj_table.write(800, 1);
					conj_table.write(801, 1);
					conj_table.write(802, 1);
					conj_table.write(803, 1);
					conj_table.write(804, 1);
					conj_table.write(805, 1);
					conj_table.write(806, 1);
					conj_table.write(807, 1);
					conj_table.write(808, 1);
					conj_table.write(809, 1);
					conj_table.write(810, 1);
					conj_table.write(811, 1);
					conj_table.write(812, 1);
					conj_table.write(813, 1);
					conj_table.write(814, 1);
					conj_table.write(815, 1);
					conj_table.write(816, 1);
					conj_table.write(817, 1);
					conj_table.write(818, 1);
					conj_table.write(819, 1);
					conj_table.write(820, 1);
					conj_table.write(821, 1);
					conj_table.write(822, 1);
					conj_table.write(823, 1);
					conj_table.write(824, 1);
					conj_table.write(825, 1);
					conj_table.write(826, 1);
					conj_table.write(827, 1);
					conj_table.write(828, 1);
					conj_table.write(829, 1);
					conj_table.write(830, 1);
					conj_table.write(831, 1);
					conj_table.write(832, 1);
					conj_table.write(833, 1);
					conj_table.write(834, 1);
					conj_table.write(835, 1);
					conj_table.write(836, 1);
					conj_table.write(837, 1);
					conj_table.write(838, 1);
					conj_table.write(839, 1);
					conj_table.write(840, 1);
					conj_table.write(841, 1);
					conj_table.write(842, 1);
					conj_table.write(843, 1);
					conj_table.write(844, 1);
					conj_table.write(845, 1);
					conj_table.write(846, 1);
					conj_table.write(847, 1);
					conj_table.write(848, 1);
					conj_table.write(849, 1);
					conj_table.write(850, 1);
					conj_table.write(851, 1);
					conj_table.write(852, 1);
					conj_table.write(853, 1);
					conj_table.write(854, 1);
					conj_table.write(855, 1);
					conj_table.write(856, 1);
					conj_table.write(857, 1);
					conj_table.write(858, 1);
					conj_table.write(859, 1);
					conj_table.write(860, 1);
					conj_table.write(861, 1);
					conj_table.write(862, 1);
					conj_table.write(863, 1);
					conj_table.write(864, 1);
					conj_table.write(865, 1);
					conj_table.write(866, 1);
					conj_table.write(867, 1);
					conj_table.write(868, 1);
					conj_table.write(869, 1);
					conj_table.write(870, 1);
					conj_table.write(871, 1);
					conj_table.write(872, 1);
					conj_table.write(873, 1);
					conj_table.write(874, 1);
					conj_table.write(875, 1);
					conj_table.write(876, 1);
					conj_table.write(877, 1);
					conj_table.write(878, 1);
					conj_table.write(879, 1);
					conj_table.write(880, 1);
					conj_table.write(881, 1);
					conj_table.write(882, 1);
					conj_table.write(883, 1);
					conj_table.write(884, 1);
					conj_table.write(885, 1);
					conj_table.write(886, 1);
					conj_table.write(887, 1);
					conj_table.write(888, 1);
					conj_table.write(889, 1);
					conj_table.write(890, 1);
					conj_table.write(891, 1);
					conj_table.write(892, 1);
					conj_table.write(893, 1);
					conj_table.write(894, 1);
					conj_table.write(895, 1);
					conj_table.write(896, 1);
					conj_table.write(897, 1);
					conj_table.write(898, 1);
					conj_table.write(899, 1);
					conj_table.write(900, 1);
					conj_table.write(901, 1);
					conj_table.write(902, 1);
					conj_table.write(903, 1);
					conj_table.write(904, 1);
					conj_table.write(905, 1);
					conj_table.write(906, 1);
					conj_table.write(907, 1);
					conj_table.write(908, 1);
					conj_table.write(909, 1);
					conj_table.write(910, 1);
					conj_table.write(911, 1);
					conj_table.write(912, 1);
					conj_table.write(913, 1);
					conj_table.write(914, 1);
					conj_table.write(915, 1);
					conj_table.write(916, 1);
					conj_table.write(917, 1);
					conj_table.write(918, 1);
					conj_table.write(919, 1);
					conj_table.write(920, 1);
					conj_table.write(921, 1);
					conj_table.write(922, 1);
					conj_table.write(923, 1);
					conj_table.write(924, 1);
					conj_table.write(925, 1);
					conj_table.write(926, 1);
					conj_table.write(927, 1);
					conj_table.write(928, 1);
					conj_table.write(929, 1);
					conj_table.write(930, 1);
					conj_table.write(931, 1);
					conj_table.write(932, 1);
					conj_table.write(933, 1);
					conj_table.write(934, 1);
					conj_table.write(935, 1);
					conj_table.write(936, 1);
					conj_table.write(937, 1);
					conj_table.write(938, 1);
					conj_table.write(939, 1);
					conj_table.write(940, 1);
					conj_table.write(941, 1);
					conj_table.write(942, 1);
					conj_table.write(943, 1);
					conj_table.write(944, 1);
					conj_table.write(945, 1);
					conj_table.write(946, 1);
					conj_table.write(947, 1);
					conj_table.write(948, 1);
					conj_table.write(949, 1);
					conj_table.write(950, 1);
					conj_table.write(951, 1);
					conj_table.write(952, 1);
					conj_table.write(953, 1);
					conj_table.write(954, 1);
					conj_table.write(955, 1);
					conj_table.write(956, 1);
					conj_table.write(957, 1);
					conj_table.write(958, 1);
					conj_table.write(959, 1);
					conj_table.write(960, 1);
					conj_table.write(961, 1);
					conj_table.write(962, 1);
					conj_table.write(963, 1);
					conj_table.write(964, 1);
					conj_table.write(965, 1);
					conj_table.write(966, 1);
					conj_table.write(967, 1);
					conj_table.write(968, 1);
					conj_table.write(969, 1);
					conj_table.write(970, 1);
					conj_table.write(971, 1);
					conj_table.write(972, 1);
					conj_table.write(973, 1);
					conj_table.write(974, 1);
					conj_table.write(975, 1);
					conj_table.write(976, 1);
					conj_table.write(977, 1);
					conj_table.write(978, 1);
					conj_table.write(979, 1);
					conj_table.write(980, 1);
					conj_table.write(981, 1);
					conj_table.write(982, 1);
					conj_table.write(983, 1);
					conj_table.write(984, 1);
					conj_table.write(985, 1);
					conj_table.write(986, 1);
					conj_table.write(987, 1);
					conj_table.write(988, 1);
					conj_table.write(989, 1);
					conj_table.write(990, 1);
					conj_table.write(991, 1);
					conj_table.write(992, 1);
					conj_table.write(993, 1);
					conj_table.write(994, 1);
					conj_table.write(995, 1);
					conj_table.write(996, 1);
					conj_table.write(997, 1);
					conj_table.write(998, 1);
					conj_table.write(999, 1);



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
			bit<32> conj_entry_0;
			
			
			@atomic
			{
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
				
			}
				
				
			conj_table.read(conj_entry_0, hdr.sensor.sensorId * CONJ_TABLE_SIZE + 0);
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
				
					disj_table_op.read(opcode, conj_entry_0 * DISJ_TABLE_SIZE+1);
					disj_table_val.read(value, conj_entry_0 * DISJ_TABLE_SIZE+1);
					disj_table_id.read(sensor_id, conj_entry_0 * DISJ_TABLE_SIZE+1);
					sensor_index.read(index, sensor_id);
					sensor_history.read(sensor_value, sensor_id * HISTORY_SIZE + index);
					if (opcode == 1 && sensor_value == value) disj = true;
					if (opcode == 2 && sensor_value > value) disj = true;
					if (opcode == 3 && sensor_value < value) disj = true;
					if (opcode == 4 && sensor_value != value) disj = true;
				
					disj_table_op.read(opcode, conj_entry_0 * DISJ_TABLE_SIZE+2);
					disj_table_val.read(value, conj_entry_0 * DISJ_TABLE_SIZE+2);
					disj_table_id.read(sensor_id, conj_entry_0 * DISJ_TABLE_SIZE+2);
					sensor_index.read(index, sensor_id);
					sensor_history.read(sensor_value, sensor_id * HISTORY_SIZE + index);
					if (opcode == 1 && sensor_value == value) disj = true;
					if (opcode == 2 && sensor_value > value) disj = true;
					if (opcode == 3 && sensor_value < value) disj = true;
					if (opcode == 4 && sensor_value != value) disj = true;
				
					disj_table_op.read(opcode, conj_entry_0 * DISJ_TABLE_SIZE+3);
					disj_table_val.read(value, conj_entry_0 * DISJ_TABLE_SIZE+3);
					disj_table_id.read(sensor_id, conj_entry_0 * DISJ_TABLE_SIZE+3);
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

