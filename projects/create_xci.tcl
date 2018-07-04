set proj_name "tcp_ip"
set root_dir [pwd]
set proj_dir $root_dir/$proj_name
set src_dir $root_dir/../rtl
set xci_dir $root_dir/xci
set ip_repo $root_dir/../iprepo
set constraints_dir $root_dir/../constraints

if { $argc < 1 } {
    puts "Usage: create_xci.tcl <part name>"
    exit 1
}

#Check if iprepo is available
if { [file isdirectory $ip_repo] } {
	set lib_dir "$ip_repo"
} else {
	puts "iprepo directory could not be found."
	exit 1
}
# Create project
create_project -force $proj_name $proj_dir

# Set project properties
set obj [get_projects $proj_name]
set_property part [lindex $argv 0] $obj
set_property IP_REPO_PATHS $lib_dir [current_fileset]
update_ip_catalog

file mkdir $xci_dir

#create ips

#Register slices

create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_64 -dir $xci_dir 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1}] [get_ips axis_register_slice_64]
generate_target {instantiation_template} [get_files $xci_dir/axis_register_slice_64/axis_register_slice_64.xci]

#Interconnects

create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_3to1 -dir $xci_dir
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {3} CONFIG.SWITCH_TDATA_NUM_BYTES {8} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_S02_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S01_AXIS_TDATA_NUM_BYTES {8} CONFIG.S02_AXIS_TDATA_NUM_BYTES {8} CONFIG.M00_S01_CONNECTIVITY {true} CONFIG.M00_S02_CONNECTIVITY {true}] [get_ips axis_interconnect_3to1]
generate_target {instantiation_template} [get_files $xci_dir/axis_interconnect_3to1/axis_interconnect_3to1.xci]

create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_2to1 -dir $xci_dir
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {8} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S01_AXIS_TDATA_NUM_BYTES {8} CONFIG.M00_S01_CONNECTIVITY {true}] [get_ips axis_interconnect_2to1]
generate_target {instantiation_template} [get_files $xci_dir/axis_interconnect_2to1/axis_interconnect_2to1.xci]

#HLS IP cores

create_ip -name toe -vendor ethz.systems -library hls -version 1.6 -module_name toe_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/toe_ip/toe_ip.xci]

create_ip -name ip_handler -vendor ethz.systems -library hls -version 1.2 -module_name ip_handler_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/ip_handler_ip/ip_handler_ip.xci]

create_ip -name mac_ip_encode -vendor xilinx.labs -library hls -version 1.04 -module_name mac_ip_encode_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/mac_ip_encode_ip/mac_ip_encode_ip.xci]

create_ip -name ethernet_frame_padding -vendor ethz.systems.fpga -library hls -version 0.1 -module_name ethernet_frame_padding_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/ethernet_frame_padding_ip/ethernet_frame_padding_ip.xci]

create_ip -name icmp_server -vendor xilinx.labs -library hls -version 1.67 -module_name icmp_server_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/icmp_server_ip/icmp_server_ip.xci]

create_ip -name echo_server_application -vendor ethz.systems -library hls -version 1.2 -module_name echo_server_application_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/echo_server_application_ip/echo_server_application_ip.xci]

create_ip -name iperf_client -vendor ethz.systems.fpga -library hls -version 1.0 -module_name iperf_client_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/iperf_client_ip/iperf_client_ip.xci]

create_ip -name arp_server_subnet -vendor ethz.systems -library hls -version 1.0 -module_name arp_server_subnet_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/arp_server_subnet_ip/arp_server_subnet_ip.xci]

create_ip -name ipv4 -vendor ethz.systems.fpga -library hls -version 0.1 -module_name ipv4_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/ipv4_ip/ipv4_ip.xci]

create_ip -name udp -vendor ethz.systems.fpga -library hls -version 0.4 -module_name udp_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/udp_ip/udp_ip.xci]

create_ip -name iperf_udp_client -vendor ethz.systems.fpga -library hls -version 0.8 -module_name iperf_udp_client_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/iperf_udp_client_ip/iperf_udp_client_ip.xci]

create_ip -name dhcp_client -vendor xilinx.labs -library hls -version 1.05 -module_name dhcp_client_ip -dir $xci_dir
generate_target {instantiation_template} [get_files $xci_dir/dhcp_client_ip/dhcp_client_ip.xci]

exit 0
