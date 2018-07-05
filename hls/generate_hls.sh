#!/bin/bash -e

IP_CORES=(ip_handler mac_ip_encode arp_server_subnet icmp_server toe echo_server_application ethernet_frame_padding iperf_client udp ipv4 iperf_udp_client dhcp_client)

if [[ $# < 2 ]]; then
        echo "Usage: $0 <part number> <period>"
        exit 1
fi

if [ "$1" = "vcu709" ]; then
        PART="xc7vx690tffg1761-2"
elif [ "$1" = "vcu118" ]; then
        PART="xcvu9p-flga2104-2L-e"
elif [ "$1" = "xcku060" ]; then
        PART="xcku060-ffva1156-2-i"
else
        PART="$1"
fi

PERIOD="$2"

HLS_DIR="$PWD"

if [ -z "$IPREPO_DIR" ]; then
	IPREPO_DIR="${HLS_DIR}/../iprepo"
fi

if [ ! -d "$IPREPO_DIR" ]; then
	mkdir "$IPREPO_DIR"
fi
echo "${IPREPO_DIR}"

for ip in "${IP_CORES[@]}"; do
	eval cd ${HLS_DIR}/${ip}
	if [ ! -z "$PART" ]; then
		echo "Using part: ${PART}"
		sed -i -e "s/set_part.*/set_part {${PART}}/" \
                       -e "s/create_clock.*/create_clock -period $PERIOD -name default/" run_hls.tcl
	fi
	eval vivado_hls -f run_hls.tcl
	if [ ! -d "${IPREPO_DIR}/${ip}" ]; then
		mkdir "${IPREPO_DIR}/${ip}"
	fi
	#eval cd "${IPREPO_DIR}/${ip}"
	zipname=`ls ${ip}_prj/solution1/impl/ip/*.zip`
	zipname=$(basename ${zipname})
	namelen=${#zipname}
	zipdir=${zipname:0:${namelen}-4}
	echo ${zipname}
	echo ${zipdir}
	eval cp ${ip}_prj/solution1/impl/ip/${zipname} ${IPREPO_DIR}/${ip}/
	unzip -o ${IPREPO_DIR}/${ip}/${zipname} -d ${IPREPO_DIR}/${ip}/${zipdir}
done



echo "Copied all HLS IPs to ip repository."
echo "Go to the projects directory and run vivado -mode batch -source create_<board>_proj.tcl to create the vivado project"

