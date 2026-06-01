transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/xil_defaultlib
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_vip_v1_1_22
vlib activehdl/processing_system7_vip_v1_0_24
vlib activehdl/proc_sys_reset_v5_0_17
vlib activehdl/xbip_utils_v3_0_15
vlib activehdl/axi_utils_v2_0_11
vlib activehdl/cic_compiler_v4_0_22
vlib activehdl/axis_infrastructure_v1_1_1
vlib activehdl/axis_register_slice_v1_1_35
vlib activehdl/axis_dwidth_converter_v1_1_34
vlib activehdl/xbip_pipe_v3_0_11
vlib activehdl/fir_compiler_v7_2_26
vlib activehdl/axis_subset_converter_v1_1_36
vlib activehdl/xbip_dsp48_wrapper_v3_0_7
vlib activehdl/mult_gen_v12_0_24
vlib activehdl/floating_point_v7_1_21
vlib activehdl/axis_combiner_v1_1_33
vlib activehdl/c_reg_fd_v12_0_11
vlib activehdl/c_addsub_v12_0_21

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_22 activehdl/axi_vip_v1_1_22
vmap processing_system7_vip_v1_0_24 activehdl/processing_system7_vip_v1_0_24
vmap proc_sys_reset_v5_0_17 activehdl/proc_sys_reset_v5_0_17
vmap xbip_utils_v3_0_15 activehdl/xbip_utils_v3_0_15
vmap axi_utils_v2_0_11 activehdl/axi_utils_v2_0_11
vmap cic_compiler_v4_0_22 activehdl/cic_compiler_v4_0_22
vmap axis_infrastructure_v1_1_1 activehdl/axis_infrastructure_v1_1_1
vmap axis_register_slice_v1_1_35 activehdl/axis_register_slice_v1_1_35
vmap axis_dwidth_converter_v1_1_34 activehdl/axis_dwidth_converter_v1_1_34
vmap xbip_pipe_v3_0_11 activehdl/xbip_pipe_v3_0_11
vmap fir_compiler_v7_2_26 activehdl/fir_compiler_v7_2_26
vmap axis_subset_converter_v1_1_36 activehdl/axis_subset_converter_v1_1_36
vmap xbip_dsp48_wrapper_v3_0_7 activehdl/xbip_dsp48_wrapper_v3_0_7
vmap mult_gen_v12_0_24 activehdl/mult_gen_v12_0_24
vmap floating_point_v7_1_21 activehdl/floating_point_v7_1_21
vmap axis_combiner_v1_1_33 activehdl/axis_combiner_v1_1_33
vmap c_reg_fd_v12_0_11 activehdl/c_reg_fd_v12_0_11
vmap c_addsub_v12_0_21 activehdl/c_addsub_v12_0_21

vlog -work xilinx_vip  -sv2k12 "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_pll_0_0/system_pll_0_0_clk_wiz.v" \
"../../../bd/system/ip/system_pll_0_0/system_pll_0_0.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_22  -sv2k12 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/b16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_24  -sv2k12 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_ps_0_0/sim/system_ps_0_0.v" \
"../../../bd/system/ip/system_const_0_0/sim/system_const_0_0.v" \

vcom -work proc_sys_reset_v5_0_17 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/system/ip/system_rst_0_0/sim/system_rst_0_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_adc_0_0/sim/system_adc_0_0.v" \
"../../../bd/system/ip/system_hub_0_0/sim/system_hub_0_0.v" \
"../../../bd/system/ip/system_slice_0_0/sim/system_slice_0_0.v" \
"../../../bd/system/ip/system_const_0_1/sim/system_const_0_1.v" \

vcom -work xbip_utils_v3_0_15 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/fb6f/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_11 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/c6be/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work cic_compiler_v4_0_22 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/0e3c/hdl/cic_compiler_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/system/ip/system_cic_0_0/sim/system_cic_0_0.vhd" \

vlog -work axis_infrastructure_v1_1_1  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work axis_register_slice_v1_1_35  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/be12/hdl/axis_register_slice_v1_1_vl_rfs.v" \

vlog -work axis_dwidth_converter_v1_1_34  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/80a6/hdl/axis_dwidth_converter_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_conv_0_0/sim/system_conv_0_0.v" \

vcom -work xbip_pipe_v3_0_11 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/6a79/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work fir_compiler_v7_2_26 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/655f/hdl/fir_compiler_v7_2_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/system/ip/system_fir_0_0/sim/system_fir_0_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_subset_0_0/hdl/tdata_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tuser_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tstrb_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tkeep_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tid_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tdest_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tlast_system_subset_0_0.v" \

vlog -work axis_subset_converter_v1_1_36  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/5e96/hdl/axis_subset_converter_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_subset_0_0/hdl/top_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/sim/system_subset_0_0.v" \

vcom -work xil_defaultlib -93  \
"../../../bd/system/ip/system_fir_1_0/sim/system_fir_1_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_subset_1_0/hdl/tdata_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tuser_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tstrb_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tkeep_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tid_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tdest_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tlast_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/top_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/sim/system_subset_1_0.v" \

vcom -work xbip_dsp48_wrapper_v3_0_7 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9bc6/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_24 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/6d7a/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_21 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/c90d/hdl/floating_point_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/system/ip/system_fp_0_0/sim/system_fp_0_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_conv_1_0/sim/system_conv_1_0.v" \
"../../../bd/system/ip/system_fifo_0_0/sim/system_fifo_0_0.v" \
"../../../bd/system/ip/system_conv_2_0/sim/system_conv_2_0.v" \

vcom -work xil_defaultlib -93  \
"../../../bd/system/ip/system_cic_10_0/sim/system_cic_10_0.vhd" \

vlog -work axis_combiner_v1_1_33  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ef89/hdl/axis_combiner_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_22 -l processing_system7_vip_v1_0_24 -l proc_sys_reset_v5_0_17 -l xbip_utils_v3_0_15 -l axi_utils_v2_0_11 -l cic_compiler_v4_0_22 -l axis_infrastructure_v1_1_1 -l axis_register_slice_v1_1_35 -l axis_dwidth_converter_v1_1_34 -l xbip_pipe_v3_0_11 -l fir_compiler_v7_2_26 -l axis_subset_converter_v1_1_36 -l xbip_dsp48_wrapper_v3_0_7 -l mult_gen_v12_0_24 -l floating_point_v7_1_21 -l axis_combiner_v1_1_33 -l c_reg_fd_v12_0_11 -l c_addsub_v12_0_21 \
"../../../bd/system/ip/system_axis_combiner_0_0/sim/system_axis_combiner_0_0.v" \
"../../../bd/system/ip/system_port_slicer_0_0/sim/system_port_slicer_0_0.v" \
"../../../bd/system/ip/system_adc_slicer_0_0/sim/system_adc_slicer_0_0.v" \
"../../../bd/system/ip/system_dds_0_0/sim/system_dds_0_0.v" \
"../../../bd/system/ip/system_port_slicer_0_1/sim/system_port_slicer_0_1.v" \
"../../../bd/system/ip/system_dds_0_1/sim/system_dds_0_1.v" \
"../../../bd/system/ip/system_dsp48_0_0/sim/system_dsp48_0_0.v" \
"../../../bd/system/ip/system_port_slicer_0_2/sim/system_port_slicer_0_2.v" \
"../../../bd/system/ip/system_dds_slicer_0_0/sim/system_dds_slicer_0_0.v" \
"../../../bd/system/ip/system_dsp48_0_1/sim/system_dsp48_0_1.v" \
"../../../bd/system/sim/system.v" \
"../../../bd/system/ip/system_dds_slicer_cos_0_0/sim/system_dds_slicer_cos_0_0.v" \
"../../../bd/system/ip/system_dsp48_0_2/sim/system_dsp48_0_2.v" \
"../../../bd/system/ip/system_mult_I_cos_0/sim/system_mult_I_cos_0.v" \
"../../../bd/system/ip/system_port_slicer_0_3/sim/system_port_slicer_0_3.v" \

vcom -work c_reg_fd_v12_0_11 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/0ff7/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_21 -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ed70/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/system/ip/system_c_addsub_0_0/sim/system_c_addsub_0_0.vhd" \
"../../../bd/system/ip/system_c_addsub_0_1/sim/system_c_addsub_0_1.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

