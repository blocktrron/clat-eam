#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_clat_eam_init_config() {
	proto_config_add_string "ip4subnet"
	proto_config_add_string "ip6subnet"
	proto_config_add_int "translation_bits"
	proto_config_add_int "mtu"
	proto_config_add_int "index"
	available=1
	no_proto_task=1
}

proto_clat_eam_setup() {
	local config="$1"
	local config_dir="/proc/net/nat46/control"

	local ip4subnet ip6subnet translation_bits mtu index
	json_get_vars ip4subnet ip6subnet translation_bits mtu index

	local prefix_len_v4
	local prefix_len_v6

	prefix_len_v4="$((32-${translation_bits}))"
	prefix_len_v6="$((128-${translation_bits}))"	

	modprobe nat46 || true
	echo "add ${config}" > $config_dir
	echo "config ${config} local.v4 "${ip4subnet}"/"${prefix_len_v4}" local.v6 "${ip6subnet}"/"${prefix_len_v6}" local.style MAP local.ea-len "${translation_bits}" local.psid-offset 0 remote.v4 0.0.0.0/0 remote.v6 64:ff9b::/96 remote.style RFC6052 remote.ea-len 0 remote.psid-offset 0 debug 0" > $config_dir

	if [ "${mtu}" ]; then
		ip link set mtu "${mtu}" dev "${config}"
	fi

	ip rule add from all fwmark "0x90${index}/0xff00" lookup "60${index}"
	iptables -t mangle -A PREROUTING -s "${ip4subnet}"/"${prefix_len_v4}" -j MARK --set-xmark "0x90${index}/0xff00"

	proto_init_update "${config}" 1
	proto_add_ipv6_route "${ip6subnet}" "${prefix_len_v6}"
	proto_send_update "${config}"

	ip route add default dev "${config}" table "60${index}"
}

proto_clat_eam_teardown() {
	local config="$1"
	local config_dir="/proc/net/nat46/control"

	local ip4subnet ip6subnet translation_bits mtu index
	json_get_vars ip4subnet ip6subnet translation_bits mtu index

	ip route del default dev "${config}" table "60${index}"
	ip rule del from all fwmark "0x90${index}/0xff00" lookup "60${index}"
	iptables -t mangle -D PREROUTING -s "${ip4subnet}"/"${prefix_len_v4}" -j MARK --set-xmark "0x90${index}/0xff00"

	echo "del ${config}" > $config_dir
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol clat_eam
}
