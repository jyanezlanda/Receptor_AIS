
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# constant, axis_red_pitaya_adc, axis_red_pitaya_dac, axi_hub, port_slicer, port_slicer, axis_constant, axis_lfsr, axis_fifo, port_slicer, gmsk_iq_pack, axi_hub, port_slicer, port_slicer, port_slicer, axis_ram_reader, axis_fifo, gmsk_iq_unpack32, gmsk_axis_broadcast2, gmsk_axis_mux2, gmsk_nivel_senal, gmsk_pico_rafaga, gmsk_discriminator_pre, gmsk_soft_scale, axis_lfsr, port_slicer, port_slicer, gmsk_squelch, gmsk_reset_rafaga, gmsk_squelch_debounce, gmsk_squelch_autocal, gmsk_activo_extendido, gmsk_nrzi_decode, gmsk_bit_pack32, gmsk_slicer, gmsk_delay_line, gmsk_dc_tracker, gmsk_tau_to_fase, gmsk_symbol_phase_accum, gmsk_iq_pack, gmsk_soft_menos_dc, gmsk_symbol_strobe

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:dds_compiler:6.0\
xilinx.com:ip:cmpy:6.0\
xilinx.com:ip:axis_broadcaster:1.1\
xilinx.com:ip:cic_compiler:4.0\
xilinx.com:ip:fir_compiler:7.2\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:cordic:6.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
constant\
axis_red_pitaya_adc\
axis_red_pitaya_dac\
axi_hub\
port_slicer\
port_slicer\
axis_constant\
axis_lfsr\
axis_fifo\
port_slicer\
gmsk_iq_pack\
axi_hub\
port_slicer\
port_slicer\
port_slicer\
axis_ram_reader\
axis_fifo\
gmsk_iq_unpack32\
gmsk_axis_broadcast2\
gmsk_axis_mux2\
gmsk_nivel_senal\
gmsk_pico_rafaga\
gmsk_discriminator_pre\
gmsk_soft_scale\
axis_lfsr\
port_slicer\
port_slicer\
gmsk_squelch\
gmsk_reset_rafaga\
gmsk_squelch_debounce\
gmsk_squelch_autocal\
gmsk_activo_extendido\
gmsk_nrzi_decode\
gmsk_bit_pack32\
gmsk_slicer\
gmsk_delay_line\
gmsk_dc_tracker\
gmsk_tau_to_fase\
gmsk_symbol_phase_accum\
gmsk_iq_pack\
gmsk_soft_menos_dc\
gmsk_symbol_strobe\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: gmsk_simbolo
proc create_hier_cell_gmsk_simbolo { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gmsk_simbolo() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DATA


  # Create pins
  create_bd_pin -dir I -type clk clk_0
  create_bd_pin -dir I -type rst aresetn_0
  create_bd_pin -dir O -from 0 -to 0 bit_crudo_tdata
  create_bd_pin -dir O bit_crudo_tvalid
  create_bd_pin -dir I -type rst aresetn

  # Create instance: gmsk_slicer_0, and set properties
  set block_name gmsk_slicer
  set block_cell_name gmsk_slicer_0
  if { [catch {set gmsk_slicer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_slicer_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: cordic_goertzel, and set properties
  set cordic_goertzel [ create_bd_cell -type ip -vlnv xilinx.com:ip:cordic:6.0 cordic_goertzel ]
  set_property -dict [list \
    CONFIG.ARESETN {true} \
    CONFIG.Architectural_Configuration {Parallel} \
    CONFIG.Compensation_Scaling {No_Scale_Compensation} \
    CONFIG.Data_Format {SignedFraction} \
    CONFIG.Functional_Selection {Translate} \
    CONFIG.Input_Width {24} \
    CONFIG.Output_Width {16} \
    CONFIG.Phase_Format {Radians} \
    CONFIG.Pipelining_Mode {Maximum} \
  ] $cordic_goertzel


  # Create instance: gmsk_delay_line_0, and set properties
  set block_name gmsk_delay_line
  set block_cell_name gmsk_delay_line_0
  if { [catch {set gmsk_delay_line_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_delay_line_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DELAY {12} $gmsk_delay_line_0


  # Create instance: dds_fixed_goertzel, and set properties
  set dds_fixed_goertzel [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 dds_fixed_goertzel ]
  set_property -dict [list \
    CONFIG.DATA_Has_TLAST {Not_Required} \
    CONFIG.DDS_Clock_Rate {0.192012289} \
    CONFIG.DSP48_Use {Minimal} \
    CONFIG.Frequency_Resolution {0.2} \
    CONFIG.Has_ARESETn {true} \
    CONFIG.Has_Phase_Out {false} \
    CONFIG.Has_TREADY {true} \
    CONFIG.Latency {12} \
    CONFIG.Negative_Sine {true} \
    CONFIG.Noise_Shaping {Auto} \
    CONFIG.OUTPUT_FORM {Twos_Complement} \
    CONFIG.Output_Frequency1 {0.0096} \
    CONFIG.Output_Width {24} \
    CONFIG.PINC1 {1100110011001001} \
    CONFIG.Phase_Increment {Fixed} \
    CONFIG.Phase_Width {20} \
    CONFIG.Resync {false} \
    CONFIG.S_PHASE_Has_TUSER {Not_Required} \
    CONFIG.Spurious_Free_Dynamic_Range {138} \
  ] $dds_fixed_goertzel


  # Create instance: gmsk_dc_tracker_symb, and set properties
  set block_name gmsk_dc_tracker
  set block_cell_name gmsk_dc_tracker_symb
  if { [catch {set gmsk_dc_tracker_symb [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_dc_tracker_symb eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.N_RAPIDO {400} \
    CONFIG.SHIFT {12} \
    CONFIG.SHIFT_RAPIDO {6} \
  ] $gmsk_dc_tracker_symb


  # Create instance: gmsk_tau_to_fase_0, and set properties
  set block_name gmsk_tau_to_fase
  set block_cell_name gmsk_tau_to_fase_0
  if { [catch {set gmsk_tau_to_fase_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_tau_to_fase_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: gmsk_symbol_phase_ac_0, and set properties
  set block_name gmsk_symbol_phase_accum
  set block_cell_name gmsk_symbol_phase_ac_0
  if { [catch {set gmsk_symbol_phase_ac_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_symbol_phase_ac_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.N_BLOQUE {400} \
    CONFIG.SHIFT_SALIDA {39} \
  ] $gmsk_symbol_phase_ac_0


  # Create instance: gmsk_iq_pack_symb, and set properties
  set block_name gmsk_iq_pack
  set block_cell_name gmsk_iq_pack_symb
  if { [catch {set gmsk_iq_pack_symb [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_iq_pack_symb eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DATA_WIDTH {24} $gmsk_iq_pack_symb


  # Create instance: gmsk_soft_menos_dc_0, and set properties
  set block_name gmsk_soft_menos_dc
  set block_cell_name gmsk_soft_menos_dc_0
  if { [catch {set gmsk_soft_menos_dc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_soft_menos_dc_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: gmsk_symbol_strobe_0, and set properties
  set block_name gmsk_symbol_strobe
  set block_cell_name gmsk_symbol_strobe_0
  if { [catch {set gmsk_symbol_strobe_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_symbol_strobe_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.CORR_SHIFT {1} $gmsk_symbol_strobe_0


  # Create instance: fir_soft_0, and set properties
  set fir_soft_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_soft_0 ]
  set_property -dict [list \
    CONFIG.BestPrecision {true} \
    CONFIG.Clock_Frequency {125.0} \
    CONFIG.CoefficientVector {-1.8496877595e-04, -3.1966502107e-04, -3.9983572604e-04, -3.3380304983e-04, 5.2790132615e-07, 7.4938218967e-04, 2.0714362252e-03, 4.1213150936e-03, 7.0296910521e-03, 1.0882164433e-02,\
1.5699626911e-02, 2.1422977056e-02, 2.7904815002e-02, 3.4910084326e-02, 4.2126619127e-02, 4.9185317972e-02, 5.5688373221e-02, 6.1242822589e-02, 6.5495838016e-02, 6.8167763599e-02, 6.9079035719e-02, 6.8167763599e-02,\
6.5495838016e-02, 6.1242822589e-02, 5.5688373221e-02, 4.9185317972e-02, 4.2126619127e-02, 3.4910084326e-02, 2.7904815002e-02, 2.1422977056e-02, 1.5699626911e-02, 1.0882164433e-02, 7.0296910521e-03, 4.1213150936e-03,\
2.0714362252e-03, 7.4938218967e-04, 5.2790132615e-07, -3.3380304983e-04, -3.9983572604e-04, -3.1966502107e-04, -1.8496877595e-04} \
    CONFIG.Coefficient_Fractional_Bits {26} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Inferred} \
    CONFIG.Coefficient_Width {24} \
    CONFIG.Data_Fractional_Bits {23} \
    CONFIG.Data_Sign {Signed} \
    CONFIG.Data_Width {24} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Has_ARESETn {true} \
    CONFIG.M_DATA_Has_TREADY {false} \
    CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
    CONFIG.Output_Width {24} \
    CONFIG.Quantization {Quantize_Only} \
    CONFIG.Sample_Frequency {0.192012289} \
  ] $fir_soft_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins fir_soft_0/S_AXIS_DATA] [get_bd_intf_pins S_AXIS_DATA]
  connect_bd_intf_net -intf_net cordic_goertzel_M_AXIS_DOUT [get_bd_intf_pins cordic_goertzel/M_AXIS_DOUT] [get_bd_intf_pins gmsk_tau_to_fase_0/s_axis_cordic]
  connect_bd_intf_net -intf_net gmsk_delay_line_0_m_axis [get_bd_intf_pins gmsk_delay_line_0/m_axis] [get_bd_intf_pins gmsk_symbol_phase_ac_0/s_axis_soft]
  connect_bd_intf_net -intf_net gmsk_iq_pack_0_m_axis [get_bd_intf_pins cordic_goertzel/S_AXIS_CARTESIAN] [get_bd_intf_pins gmsk_iq_pack_symb/m_axis]
  connect_bd_intf_net -intf_net gmsk_tau_to_fase_0_m_axis_carga [get_bd_intf_pins gmsk_tau_to_fase_0/m_axis_carga] [get_bd_intf_pins gmsk_symbol_strobe_0/s_axis_carga]

  # Create port connections
  connect_bd_net -net aresetn_0_1  [get_bd_pins aresetn_0] \
  [get_bd_pins cordic_goertzel/aresetn] \
  [get_bd_pins gmsk_delay_line_0/aresetn] \
  [get_bd_pins gmsk_slicer_0/aresetn] \
  [get_bd_pins gmsk_iq_pack_symb/aresetn] \
  [get_bd_pins gmsk_symbol_strobe_0/aresetn] \
  [get_bd_pins fir_soft_0/aresetn]
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins dds_fixed_goertzel/aresetn] \
  [get_bd_pins gmsk_tau_to_fase_0/aresetn] \
  [get_bd_pins gmsk_dc_tracker_symb/aresetn] \
  [get_bd_pins gmsk_symbol_phase_ac_0/aresetn]
  connect_bd_net -net clk_0_1  [get_bd_pins clk_0] \
  [get_bd_pins dds_fixed_goertzel/aclk] \
  [get_bd_pins cordic_goertzel/aclk] \
  [get_bd_pins gmsk_delay_line_0/clk] \
  [get_bd_pins gmsk_slicer_0/clk] \
  [get_bd_pins gmsk_iq_pack_symb/clk] \
  [get_bd_pins gmsk_tau_to_fase_0/clk] \
  [get_bd_pins gmsk_dc_tracker_symb/clk] \
  [get_bd_pins gmsk_symbol_strobe_0/clk] \
  [get_bd_pins fir_soft_0/aclk] \
  [get_bd_pins gmsk_symbol_phase_ac_0/clk]
  connect_bd_net -net dds_fixed_goertzel_m_axis_data_tdata  [get_bd_pins dds_fixed_goertzel/m_axis_data_tdata] \
  [get_bd_pins gmsk_symbol_phase_ac_0/s_axis_nco_tdata]
  connect_bd_net -net dds_fixed_goertzel_m_axis_data_tvalid  [get_bd_pins dds_fixed_goertzel/m_axis_data_tvalid] \
  [get_bd_pins gmsk_symbol_phase_ac_0/s_axis_nco_tvalid]
  connect_bd_net -net gmsk_axis_broadcast2_0_m0_axis_tdata  [get_bd_pins fir_soft_0/m_axis_data_tdata] \
  [get_bd_pins gmsk_slicer_0/soft_tdata] \
  [get_bd_pins gmsk_dc_tracker_symb/s_axis_soft_tdata] \
  [get_bd_pins gmsk_soft_menos_dc_0/soft_tdata]
  connect_bd_net -net gmsk_axis_broadcast2_0_m0_axis_tvalid  [get_bd_pins fir_soft_0/m_axis_data_tvalid] \
  [get_bd_pins gmsk_dc_tracker_symb/s_axis_soft_tvalid] \
  [get_bd_pins gmsk_symbol_strobe_0/s_axis_soft_tvalid] \
  [get_bd_pins dds_fixed_goertzel/m_axis_data_tready] \
  [get_bd_pins gmsk_delay_line_0/s_axis_tvalid]
  connect_bd_net -net gmsk_dc_tracker_1_dc_tdata  [get_bd_pins gmsk_dc_tracker_symb/dc_tdata] \
  [get_bd_pins gmsk_slicer_0/dc_tdata] \
  [get_bd_pins gmsk_soft_menos_dc_0/dc_tdata]
  connect_bd_net -net gmsk_slicer_0_bit_crudo_tdata  [get_bd_pins gmsk_slicer_0/bit_crudo_tdata] \
  [get_bd_pins bit_crudo_tdata]
  connect_bd_net -net gmsk_slicer_0_bit_crudo_tvalid  [get_bd_pins gmsk_slicer_0/bit_crudo_tvalid] \
  [get_bd_pins bit_crudo_tvalid]
  connect_bd_net -net gmsk_soft_menos_dc_0_dout_tdata  [get_bd_pins gmsk_soft_menos_dc_0/dout_tdata] \
  [get_bd_pins gmsk_delay_line_0/s_axis_tdata]
  connect_bd_net -net gmsk_symbol_phase_ac_0_m_axis_acc_i_tdata  [get_bd_pins gmsk_symbol_phase_ac_0/m_axis_acc_i_tdata] \
  [get_bd_pins gmsk_iq_pack_symb/s_axis_i_tdata]
  connect_bd_net -net gmsk_symbol_phase_ac_0_m_axis_acc_q_tdata  [get_bd_pins gmsk_symbol_phase_ac_0/m_axis_acc_q_tdata] \
  [get_bd_pins gmsk_iq_pack_symb/s_axis_q_tdata]
  connect_bd_net -net gmsk_symbol_phase_ac_0_m_axis_acc_tvalid  [get_bd_pins gmsk_symbol_phase_ac_0/m_axis_acc_tvalid] \
  [get_bd_pins gmsk_iq_pack_symb/s_axis_i_tvalid] \
  [get_bd_pins gmsk_iq_pack_symb/s_axis_q_tvalid]
  connect_bd_net -net gmsk_symbol_strobe_0_strobe  [get_bd_pins gmsk_symbol_strobe_0/strobe] \
  [get_bd_pins gmsk_slicer_0/strobe]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gmsk_salida
proc create_hier_cell_gmsk_salida { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gmsk_salida() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis


  # Create pins
  create_bd_pin -dir I -type clk clk_0
  create_bd_pin -dir I bit_in
  create_bd_pin -dir I bit_in_valid
  create_bd_pin -dir I -type rst aresetn

  # Create instance: gmsk_nrzi_decode_0, and set properties
  set block_name gmsk_nrzi_decode
  set block_cell_name gmsk_nrzi_decode_0
  if { [catch {set gmsk_nrzi_decode_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_nrzi_decode_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: gmsk_bit_pack32_out, and set properties
  set block_name gmsk_bit_pack32
  set block_cell_name gmsk_bit_pack32_out
  if { [catch {set gmsk_bit_pack32_out [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_bit_pack32_out eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net gmsk_bit_pack32_0_m_axis [get_bd_intf_pins m_axis] [get_bd_intf_pins gmsk_bit_pack32_out/m_axis]

  # Create port connections
  connect_bd_net -net Net  [get_bd_pins aresetn] \
  [get_bd_pins gmsk_bit_pack32_out/aresetn] \
  [get_bd_pins gmsk_nrzi_decode_0/aresetn]
  connect_bd_net -net bit_in_1  [get_bd_pins bit_in] \
  [get_bd_pins gmsk_nrzi_decode_0/bit_in]
  connect_bd_net -net bit_in_valid_1  [get_bd_pins bit_in_valid] \
  [get_bd_pins gmsk_nrzi_decode_0/bit_in_valid]
  connect_bd_net -net clk_0_1  [get_bd_pins clk_0] \
  [get_bd_pins gmsk_bit_pack32_out/clk] \
  [get_bd_pins gmsk_nrzi_decode_0/clk]
  connect_bd_net -net gmsk_nrzi_decode_0_bit_out  [get_bd_pins gmsk_nrzi_decode_0/bit_out] \
  [get_bd_pins gmsk_bit_pack32_out/bit_in]
  connect_bd_net -net gmsk_nrzi_decode_0_bit_out_valid  [get_bd_pins gmsk_nrzi_decode_0/bit_out_valid] \
  [get_bd_pins gmsk_bit_pack32_out/bit_in_valid]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gmsk_squelch_calib
proc create_hier_cell_gmsk_squelch_calib { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gmsk_squelch_calib() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk clk_0
  create_bd_pin -dir I -type rst aresetn_0
  create_bd_pin -dir O -type rst aresetn_simbolo
  create_bd_pin -dir I s_axis_mag_tvalid
  create_bd_pin -dir O activo_confirmado
  create_bd_pin -dir I -from 19 -to 0 s_axis_mag_tdata
  create_bd_pin -dir O -from 19 -to 0 piso_ruido_dbg
  create_bd_pin -dir O -from 19 -to 0 dispersion_dbg
  create_bd_pin -dir O activo_ext

  # Create instance: gmsk_squelch_0, and set properties
  set block_name gmsk_squelch
  set block_cell_name gmsk_squelch_0
  if { [catch {set gmsk_squelch_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_squelch_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.PHASE_WIDTH {20} $gmsk_squelch_0


  # Create instance: gmsk_reset_rafaga_0, and set properties
  set block_name gmsk_reset_rafaga
  set block_cell_name gmsk_reset_rafaga_0
  if { [catch {set gmsk_reset_rafaga_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_reset_rafaga_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.N_CICLOS_RESET {4} $gmsk_reset_rafaga_0


  # Create instance: gmsk_squelch_debounce_0, and set properties
  set block_name gmsk_squelch_debounce
  set block_cell_name gmsk_squelch_debounce_0
  if { [catch {set gmsk_squelch_debounce_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_squelch_debounce_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: gmsk_squelch_autocal_0, and set properties
  set block_name gmsk_squelch_autocal
  set block_cell_name gmsk_squelch_autocal_0
  if { [catch {set gmsk_squelch_autocal_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_squelch_autocal_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DATA_WIDTH {20} $gmsk_squelch_autocal_0


  # Create instance: gmsk_activo_extendido_0, and set properties
  set block_name gmsk_activo_extendido
  set block_cell_name gmsk_activo_extendido_0
  if { [catch {set gmsk_activo_extendido_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_activo_extendido_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net aresetn_0_1  [get_bd_pins aresetn_0] \
  [get_bd_pins gmsk_reset_rafaga_0/aresetn_global] \
  [get_bd_pins gmsk_squelch_debounce_0/aresetn] \
  [get_bd_pins gmsk_squelch_0/aresetn] \
  [get_bd_pins gmsk_activo_extendido_0/aresetn] \
  [get_bd_pins gmsk_squelch_autocal_0/aresetn]
  connect_bd_net -net clk_0_1  [get_bd_pins clk_0] \
  [get_bd_pins gmsk_squelch_debounce_0/clk] \
  [get_bd_pins gmsk_reset_rafaga_0/clk] \
  [get_bd_pins gmsk_squelch_0/clk] \
  [get_bd_pins gmsk_activo_extendido_0/clk] \
  [get_bd_pins gmsk_squelch_autocal_0/clk]
  connect_bd_net -net gmsk_activo_extendido_0_activo_ext  [get_bd_pins gmsk_activo_extendido_0/activo_ext] \
  [get_bd_pins activo_ext]
  connect_bd_net -net gmsk_reset_rafaga_0_aresetn_simbolo  [get_bd_pins gmsk_reset_rafaga_0/aresetn_simbolo] \
  [get_bd_pins aresetn_simbolo]
  connect_bd_net -net gmsk_squelch_0_activo  [get_bd_pins gmsk_squelch_0/activo] \
  [get_bd_pins gmsk_squelch_debounce_0/activo_crudo]
  connect_bd_net -net gmsk_squelch_autocal_0_dispersion_dbg  [get_bd_pins gmsk_squelch_autocal_0/dispersion_dbg] \
  [get_bd_pins dispersion_dbg]
  connect_bd_net -net gmsk_squelch_autocal_0_piso_ruido_dbg  [get_bd_pins gmsk_squelch_autocal_0/piso_ruido_dbg] \
  [get_bd_pins piso_ruido_dbg]
  connect_bd_net -net gmsk_squelch_autocal_0_umbral_alto  [get_bd_pins gmsk_squelch_autocal_0/umbral_alto] \
  [get_bd_pins gmsk_squelch_0/umbral_alto]
  connect_bd_net -net gmsk_squelch_autocal_0_umbral_bajo  [get_bd_pins gmsk_squelch_autocal_0/umbral_bajo] \
  [get_bd_pins gmsk_squelch_0/umbral_bajo]
  connect_bd_net -net gmsk_squelch_debounce_0_activo_confirmado  [get_bd_pins gmsk_squelch_debounce_0/activo_confirmado] \
  [get_bd_pins gmsk_reset_rafaga_0/activo] \
  [get_bd_pins activo_confirmado] \
  [get_bd_pins gmsk_activo_extendido_0/activo] \
  [get_bd_pins gmsk_squelch_autocal_0/activo]
  connect_bd_net -net s_axis_mag_tdata_1  [get_bd_pins s_axis_mag_tdata] \
  [get_bd_pins gmsk_squelch_0/s_axis_mag_tdata] \
  [get_bd_pins gmsk_squelch_autocal_0/mag_tdata]
  connect_bd_net -net s_axis_mag_tvalid_1  [get_bd_pins s_axis_mag_tvalid] \
  [get_bd_pins gmsk_squelch_debounce_0/activo_crudo_tvalid] \
  [get_bd_pins gmsk_squelch_0/s_axis_mag_tvalid] \
  [get_bd_pins gmsk_activo_extendido_0/tick] \
  [get_bd_pins gmsk_squelch_autocal_0/mag_tvalid]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gmsk_discriminador
proc create_hier_cell_gmsk_discriminador { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gmsk_discriminador() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_iq

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_soft


  # Create pins
  create_bd_pin -dir I -type clk clk_0
  create_bd_pin -dir I -type rst aresetn_0
  create_bd_pin -dir O mag_disc_tvalid
  create_bd_pin -dir O -from 19 -to 0 dout

  # Create instance: cmpy_discriminador, and set properties
  set cmpy_discriminador [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy:6.0 cmpy_discriminador ]
  set_property -dict [list \
    CONFIG.APortWidth {32} \
    CONFIG.ARESETN {true} \
    CONFIG.BPortWidth {32} \
    CONFIG.MinimumLatency {13} \
    CONFIG.OutputWidth {24} \
    CONFIG.RoundMode {Random_Rounding} \
  ] $cmpy_discriminador


  # Create instance: gmsk_discriminator_p_0, and set properties
  set block_name gmsk_discriminator_pre
  set block_cell_name gmsk_discriminator_p_0
  if { [catch {set gmsk_discriminator_p_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_discriminator_p_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: cordic_discriminador, and set properties
  set cordic_discriminador [ create_bd_cell -type ip -vlnv xilinx.com:ip:cordic:6.0 cordic_discriminador ]
  set_property -dict [list \
    CONFIG.ARESETN {true} \
    CONFIG.Architectural_Configuration {Parallel} \
    CONFIG.Compensation_Scaling {No_Scale_Compensation} \
    CONFIG.Data_Format {SignedFraction} \
    CONFIG.Functional_Selection {Translate} \
    CONFIG.Input_Width {24} \
    CONFIG.Output_Width {20} \
    CONFIG.Phase_Format {Radians} \
    CONFIG.Pipelining_Mode {Maximum} \
  ] $cordic_discriminador


  # Create instance: gmsk_soft_scale_0, and set properties
  set block_name gmsk_soft_scale
  set block_cell_name gmsk_soft_scale_0
  if { [catch {set gmsk_soft_scale_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_soft_scale_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.PHASE_WIDTH {16} $gmsk_soft_scale_0


  # Create instance: axis_lfsr_disc, and set properties
  set block_name axis_lfsr
  set block_cell_name axis_lfsr_disc
  if { [catch {set axis_lfsr_disc [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_lfsr_disc eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: phase_slice_disc_0, and set properties
  set block_name port_slicer
  set block_cell_name phase_slice_disc_0
  if { [catch {set phase_slice_disc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $phase_slice_disc_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {43} \
    CONFIG.DIN_TO {28} \
    CONFIG.DIN_WIDTH {48} \
  ] $phase_slice_disc_0


  # Create instance: mag_slice_disc_0, and set properties
  set block_name port_slicer
  set block_cell_name mag_slice_disc_0
  if { [catch {set mag_slice_disc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mag_slice_disc_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {19} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {48} \
  ] $mag_slice_disc_0


  # Create interface connections
  connect_bd_intf_net -intf_net axis_lfsr_0_m_axis [get_bd_intf_pins cmpy_discriminador/S_AXIS_CTRL] [get_bd_intf_pins axis_lfsr_disc/m_axis]
  connect_bd_intf_net -intf_net cmpy_discriminador_M_AXIS_DOUT [get_bd_intf_pins cordic_discriminador/S_AXIS_CARTESIAN] [get_bd_intf_pins cmpy_discriminador/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net gmsk_axis_broadcast2_1_m0_axis1 [get_bd_intf_pins s_axis_iq] [get_bd_intf_pins gmsk_discriminator_p_0/s_axis_iq]
  connect_bd_intf_net -intf_net gmsk_discriminator_p_0_m_axis_a [get_bd_intf_pins gmsk_discriminator_p_0/m_axis_a] [get_bd_intf_pins cmpy_discriminador/S_AXIS_A]
  connect_bd_intf_net -intf_net gmsk_discriminator_p_0_m_axis_b [get_bd_intf_pins gmsk_discriminator_p_0/m_axis_b] [get_bd_intf_pins cmpy_discriminador/S_AXIS_B]
  connect_bd_intf_net -intf_net gmsk_soft_scale_0_m_axis_soft [get_bd_intf_pins m_axis_soft] [get_bd_intf_pins gmsk_soft_scale_0/m_axis_soft]

  # Create port connections
  connect_bd_net -net aresetn_0_1  [get_bd_pins aresetn_0] \
  [get_bd_pins cmpy_discriminador/aresetn] \
  [get_bd_pins cordic_discriminador/aresetn] \
  [get_bd_pins gmsk_discriminator_p_0/aresetn] \
  [get_bd_pins axis_lfsr_disc/aresetn] \
  [get_bd_pins gmsk_soft_scale_0/aresetn]
  connect_bd_net -net clk_0_1  [get_bd_pins clk_0] \
  [get_bd_pins cordic_discriminador/aclk] \
  [get_bd_pins cmpy_discriminador/aclk] \
  [get_bd_pins gmsk_discriminator_p_0/clk] \
  [get_bd_pins axis_lfsr_disc/aclk] \
  [get_bd_pins gmsk_soft_scale_0/clk]
  connect_bd_net -net cordic_discriminador_m_axis_dout_tdata  [get_bd_pins cordic_discriminador/m_axis_dout_tdata] \
  [get_bd_pins phase_slice_disc_0/din] \
  [get_bd_pins mag_slice_disc_0/din]
  connect_bd_net -net cordic_discriminador_m_axis_dout_tvalid  [get_bd_pins cordic_discriminador/m_axis_dout_tvalid] \
  [get_bd_pins mag_disc_tvalid] \
  [get_bd_pins gmsk_soft_scale_0/s_axis_phase_tvalid]
  connect_bd_net -net mag_slice_disc_0_dout  [get_bd_pins mag_slice_disc_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net phase_slice_disc_0_dout  [get_bd_pins phase_slice_disc_0/dout] \
  [get_bd_pins gmsk_soft_scale_0/s_axis_phase_tdata]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: GMSK_Demod
proc create_hier_cell_GMSK_Demod { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_GMSK_Demod() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_salida

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis


  # Create pins
  create_bd_pin -dir I -type clk clk_0
  create_bd_pin -dir I -type rst aresetn_0
  create_bd_pin -dir I sel_out
  create_bd_pin -dir O -from 19 -to 0 nivel
  create_bd_pin -dir O activo_confirmado
  create_bd_pin -dir O -from 19 -to 0 piso_ruido_dbg
  create_bd_pin -dir O -from 19 -to 0 dispersion_dbg
  create_bd_pin -dir O activo_ext
  create_bd_pin -dir O -from 31 -to 0 pico_cont
  create_bd_pin -dir O -from 31 -to 0 rafaga_info

  # Create instance: gmsk_discriminador
  create_hier_cell_gmsk_discriminador $hier_obj gmsk_discriminador

  # Create instance: gmsk_squelch_calib
  create_hier_cell_gmsk_squelch_calib $hier_obj gmsk_squelch_calib

  # Create instance: gmsk_salida
  create_hier_cell_gmsk_salida $hier_obj gmsk_salida

  # Create instance: gmsk_simbolo
  create_hier_cell_gmsk_simbolo $hier_obj gmsk_simbolo

  # Create instance: gmsk_iq_unpack32_fir, and set properties
  set block_name gmsk_iq_unpack32
  set block_cell_name gmsk_iq_unpack32_fir
  if { [catch {set gmsk_iq_unpack32_fir [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_iq_unpack32_fir eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: gmsk_axis_broadcast2_fir, and set properties
  set block_name gmsk_axis_broadcast2
  set block_cell_name gmsk_axis_broadcast2_fir
  if { [catch {set gmsk_axis_broadcast2_fir [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_axis_broadcast2_fir eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DATA_WIDTH {64} $gmsk_axis_broadcast2_fir


  # Create instance: gmsk_axis_mux2_out, and set properties
  set block_name gmsk_axis_mux2
  set block_cell_name gmsk_axis_mux2_out
  if { [catch {set gmsk_axis_mux2_out [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_axis_mux2_out eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: gmsk_nivel_senal_0, and set properties
  set block_name gmsk_nivel_senal
  set block_cell_name gmsk_nivel_senal_0
  if { [catch {set gmsk_nivel_senal_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_nivel_senal_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DATA_WIDTH {20} $gmsk_nivel_senal_0


  # Create instance: gmsk_pico_rafaga_0, and set properties
  set block_name gmsk_pico_rafaga
  set block_cell_name gmsk_pico_rafaga_0
  if { [catch {set gmsk_pico_rafaga_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_pico_rafaga_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins gmsk_axis_broadcast2_fir/s_axis] [get_bd_intf_pins s_axis]
  connect_bd_intf_net -intf_net gmsk_axis_broadcast2_0_m1_axis [get_bd_intf_pins gmsk_axis_broadcast2_fir/m1_axis] [get_bd_intf_pins gmsk_iq_unpack32_fir/s_axis]
  connect_bd_intf_net -intf_net gmsk_axis_broadcast2_1_m0_axis1 [get_bd_intf_pins gmsk_axis_broadcast2_fir/m0_axis] [get_bd_intf_pins gmsk_discriminador/s_axis_iq]
  connect_bd_intf_net -intf_net gmsk_axis_mux2_out_m_axis [get_bd_intf_pins m_axis_salida] [get_bd_intf_pins gmsk_axis_mux2_out/m_axis]
  connect_bd_intf_net -intf_net gmsk_discriminador_m_axis_soft [get_bd_intf_pins gmsk_discriminador/m_axis_soft] [get_bd_intf_pins gmsk_simbolo/S_AXIS_DATA]
  connect_bd_intf_net -intf_net gmsk_iq_unpack32_fir_m_axis [get_bd_intf_pins gmsk_iq_unpack32_fir/m_axis] [get_bd_intf_pins gmsk_axis_mux2_out/s_axis_b]
  connect_bd_intf_net -intf_net gmsk_squelch_calib_m_axis [get_bd_intf_pins gmsk_salida/m_axis] [get_bd_intf_pins gmsk_axis_mux2_out/s_axis_a]

  # Create port connections
  connect_bd_net -net aresetn_0_1  [get_bd_pins aresetn_0] \
  [get_bd_pins gmsk_discriminador/aresetn_0] \
  [get_bd_pins gmsk_squelch_calib/aresetn_0] \
  [get_bd_pins gmsk_simbolo/aresetn_0] \
  [get_bd_pins gmsk_axis_broadcast2_fir/aresetn] \
  [get_bd_pins gmsk_iq_unpack32_fir/aresetn] \
  [get_bd_pins gmsk_axis_mux2_out/aresetn] \
  [get_bd_pins gmsk_nivel_senal_0/aresetn] \
  [get_bd_pins gmsk_salida/aresetn] \
  [get_bd_pins gmsk_pico_rafaga_0/aresetn]
  connect_bd_net -net aresetn_1  [get_bd_pins gmsk_squelch_calib/aresetn_simbolo] \
  [get_bd_pins gmsk_simbolo/aresetn]
  connect_bd_net -net clk_0_1  [get_bd_pins clk_0] \
  [get_bd_pins gmsk_discriminador/clk_0] \
  [get_bd_pins gmsk_squelch_calib/clk_0] \
  [get_bd_pins gmsk_salida/clk_0] \
  [get_bd_pins gmsk_simbolo/clk_0] \
  [get_bd_pins gmsk_axis_broadcast2_fir/clk] \
  [get_bd_pins gmsk_iq_unpack32_fir/clk] \
  [get_bd_pins gmsk_axis_mux2_out/clk] \
  [get_bd_pins gmsk_nivel_senal_0/clk] \
  [get_bd_pins gmsk_pico_rafaga_0/clk]
  connect_bd_net -net gmsk_discriminador_dout  [get_bd_pins gmsk_discriminador/dout] \
  [get_bd_pins gmsk_squelch_calib/s_axis_mag_tdata] \
  [get_bd_pins gmsk_nivel_senal_0/mag_tdata]
  connect_bd_net -net gmsk_discriminador_m2_axis_tvalid  [get_bd_pins gmsk_discriminador/mag_disc_tvalid] \
  [get_bd_pins gmsk_squelch_calib/s_axis_mag_tvalid] \
  [get_bd_pins gmsk_nivel_senal_0/mag_tvalid] \
  [get_bd_pins gmsk_pico_rafaga_0/tick]
  connect_bd_net -net gmsk_nivel_senal_0_nivel  [get_bd_pins gmsk_nivel_senal_0/nivel] \
  [get_bd_pins nivel] \
  [get_bd_pins gmsk_pico_rafaga_0/nivel]
  connect_bd_net -net gmsk_pico_rafaga_0_pico_cont  [get_bd_pins gmsk_pico_rafaga_0/pico_cont] \
  [get_bd_pins pico_cont]
  connect_bd_net -net gmsk_pico_rafaga_0_rafaga_info  [get_bd_pins gmsk_pico_rafaga_0/rafaga_info] \
  [get_bd_pins rafaga_info]
  connect_bd_net -net gmsk_simbolo_bit_crudo_tdata  [get_bd_pins gmsk_simbolo/bit_crudo_tdata] \
  [get_bd_pins gmsk_salida/bit_in]
  connect_bd_net -net gmsk_simbolo_bit_crudo_tvalid  [get_bd_pins gmsk_simbolo/bit_crudo_tvalid] \
  [get_bd_pins gmsk_salida/bit_in_valid]
  connect_bd_net -net gmsk_squelch_calib_activo_confirmado  [get_bd_pins gmsk_squelch_calib/activo_confirmado] \
  [get_bd_pins activo_confirmado] \
  [get_bd_pins gmsk_pico_rafaga_0/activo]
  connect_bd_net -net gmsk_squelch_calib_activo_ext  [get_bd_pins gmsk_squelch_calib/activo_ext] \
  [get_bd_pins activo_ext]
  connect_bd_net -net gmsk_squelch_calib_dispersion_dbg  [get_bd_pins gmsk_squelch_calib/dispersion_dbg] \
  [get_bd_pins dispersion_dbg]
  connect_bd_net -net gmsk_squelch_calib_piso_ruido_dbg  [get_bd_pins gmsk_squelch_calib/piso_ruido_dbg] \
  [get_bd_pins piso_ruido_dbg]
  connect_bd_net -net sel_1  [get_bd_pins sel_out] \
  [get_bd_pins gmsk_axis_mux2_out/sel]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: test_0
proc create_hier_cell_test_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_test_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: axi_hub_0, and set properties
  set block_name axi_hub
  set block_cell_name axi_hub_0
  if { [catch {set axi_hub_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axi_hub_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.CFG_DATA_WIDTH {96} \
    CONFIG.STS_DATA_WIDTH {32} \
  ] $axi_hub_0


  # Create instance: addr_slice, and set properties
  set block_name port_slicer
  set block_cell_name addr_slice
  if { [catch {set addr_slice [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $addr_slice eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {63} \
    CONFIG.DIN_TO {32} \
    CONFIG.DIN_WIDTH {96} \
  ] $addr_slice


  # Create instance: rst_slice, and set properties
  set block_name port_slicer
  set block_cell_name rst_slice
  if { [catch {set rst_slice [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $rst_slice eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {96} \
  ] $rst_slice


  # Create instance: size_slice, and set properties
  set block_name port_slicer
  set block_cell_name size_slice
  if { [catch {set size_slice [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $size_slice eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {81} \
    CONFIG.DIN_TO {64} \
    CONFIG.DIN_WIDTH {96} \
  ] $size_slice


  # Create instance: axis_ram_reader_0, and set properties
  set block_name axis_ram_reader
  set block_cell_name axis_ram_reader_0
  if { [catch {set axis_ram_reader_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_ram_reader_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.ADDR_WIDTH {18} \
    CONFIG.AXIS_TDATA_WIDTH {32} \
    CONFIG.AXI_ID_WIDTH {3} \
    CONFIG.FIFO_WRITE_DEPTH {1024} \
  ] $axis_ram_reader_0


  # Create instance: axis_fifo_0, and set properties
  set block_name axis_fifo
  set block_cell_name axis_fifo_0
  if { [catch {set axis_fifo_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_fifo_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.ALWAYS_READY {TRUE} \
    CONFIG.WRITE_DEPTH {8192} \
  ] $axis_fifo_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axis_fifo_0/m_axis] [get_bd_intf_pins m_axis]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axis_ram_reader_0/m_axi] [get_bd_intf_pins m_axi]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axi_hub_0/s_axi] [get_bd_intf_pins s_axi]
  connect_bd_intf_net -intf_net axis_ram_reader_0_m_axis [get_bd_intf_pins axis_ram_reader_0/m_axis] [get_bd_intf_pins axis_fifo_0/s_axis]

  # Create port connections
  connect_bd_net -net addr_slice_dout  [get_bd_pins addr_slice/dout] \
  [get_bd_pins axis_ram_reader_0/min_addr]
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins axi_hub_0/aresetn] \
  [get_bd_pins axis_fifo_0/aresetn]
  connect_bd_net -net axi_hub_0_cfg_data  [get_bd_pins axi_hub_0/cfg_data] \
  [get_bd_pins addr_slice/din] \
  [get_bd_pins rst_slice/din] \
  [get_bd_pins size_slice/din]
  connect_bd_net -net axis_ram_reader_0_sts_data  [get_bd_pins axis_ram_reader_0/sts_data] \
  [get_bd_pins axi_hub_0/sts_data]
  connect_bd_net -net pll_0_clk_out1  [get_bd_pins aclk] \
  [get_bd_pins axi_hub_0/aclk] \
  [get_bd_pins axis_ram_reader_0/aclk] \
  [get_bd_pins axis_fifo_0/aclk]
  connect_bd_net -net rst_slice_dout  [get_bd_pins rst_slice/dout] \
  [get_bd_pins axis_ram_reader_0/aresetn]
  connect_bd_net -net size_slice_dout  [get_bd_pins size_slice/dout] \
  [get_bd_pins axis_ram_reader_0/cfg_data]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: rx_0
proc create_hier_cell_rx_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_rx_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_adc

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn_0
  create_bd_pin -dir I -from 127 -to 0 din
  create_bd_pin -dir O -from 159 -to 0 dout

  # Create instance: slice_0, and set properties
  set block_name port_slicer
  set block_cell_name slice_0
  if { [catch {set slice_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $slice_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {128} \
  ] $slice_0


  # Create instance: slice_1, and set properties
  set block_name port_slicer
  set block_cell_name slice_1
  if { [catch {set slice_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $slice_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {40} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {128} \
  ] $slice_1


  # Create instance: phase_0, and set properties
  set block_name axis_constant
  set block_cell_name phase_0
  if { [catch {set phase_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $phase_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.AXIS_TDATA_WIDTH {40} $phase_0


  # Create instance: osc_0, and set properties
  set osc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 osc_0 ]
  set_property -dict [list \
    CONFIG.DDS_Clock_Rate {125} \
    CONFIG.DSP48_Use {Minimal} \
    CONFIG.Frequency_Resolution {0.2} \
    CONFIG.Has_Phase_Out {false} \
    CONFIG.Negative_Sine {true} \
    CONFIG.Output_Width {24} \
    CONFIG.Phase_Increment {Streaming} \
    CONFIG.Phase_Width {30} \
    CONFIG.Resync {true} \
    CONFIG.Spurious_Free_Dynamic_Range {138} \
  ] $osc_0


  # Create instance: lfsr_0, and set properties
  set block_name axis_lfsr
  set block_cell_name lfsr_0
  if { [catch {set lfsr_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $lfsr_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: mult_0, and set properties
  set mult_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy:6.0 mult_0 ]
  set_property -dict [list \
    CONFIG.APortWidth {14} \
    CONFIG.BPortWidth {24} \
    CONFIG.OutputWidth {26} \
    CONFIG.RoundMode {Random_Rounding} \
  ] $mult_0


  # Create instance: bcast_0, and set properties
  set bcast_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 bcast_0 ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {0} \
    CONFIG.HAS_TLAST {0} \
    CONFIG.HAS_TREADY {0} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M00_TDATA_REMAP {tdata[23:0]} \
    CONFIG.M01_TDATA_REMAP {tdata[55:32]} \
    CONFIG.M_TDATA_NUM_BYTES {3} \
    CONFIG.M_TUSER_WIDTH {0} \
    CONFIG.S_TDATA_NUM_BYTES {8} \
    CONFIG.S_TUSER_WIDTH {0} \
    CONFIG.TDEST_WIDTH {0} \
    CONFIG.TID_WIDTH {0} \
  ] $bcast_0

  set_property -dict [list \
    CONFIG.HAS_TKEEP.VALUE_MODE {auto} \
    CONFIG.HAS_TLAST.VALUE_MODE {auto} \
    CONFIG.HAS_TREADY.VALUE_MODE {auto} \
    CONFIG.HAS_TSTRB.VALUE_MODE {auto} \
    CONFIG.M_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.S_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.TDEST_WIDTH.VALUE_MODE {auto} \
    CONFIG.TID_WIDTH.VALUE_MODE {auto} \
  ] $bcast_0


  # Create instance: cic_0, and set properties
  set cic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Fixed_Or_Initial_Rate {651} \
    CONFIG.HAS_ARESETN {true} \
    CONFIG.HAS_DOUT_TREADY {true} \
    CONFIG.Input_Data_Width {24} \
    CONFIG.Input_Sample_Frequency {125} \
    CONFIG.Maximum_Rate {651} \
    CONFIG.Minimum_Rate {651} \
    CONFIG.Number_Of_Stages {6} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Quantization {Truncation} \
    CONFIG.SamplePeriod {1} \
    CONFIG.Sample_Rate_Changes {Fixed} \
    CONFIG.Use_Xtreme_DSP_Slice {false} \
  ] $cic_0


  # Create instance: fifo_0, and set properties
  set block_name axis_fifo
  set block_cell_name fifo_0
  if { [catch {set fifo_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fifo_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.ALWAYS_READY {FALSE} \
    CONFIG.M_AXIS_TDATA_WIDTH {32} \
    CONFIG.S_AXIS_TDATA_WIDTH {32} \
    CONFIG.WRITE_DEPTH {16} \
  ] $fifo_0


  # Create instance: cic_1, and set properties
  set cic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_1 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Fixed_Or_Initial_Rate {651} \
    CONFIG.HAS_ARESETN {true} \
    CONFIG.HAS_DOUT_TREADY {true} \
    CONFIG.Input_Data_Width {24} \
    CONFIG.Input_Sample_Frequency {125} \
    CONFIG.Maximum_Rate {651} \
    CONFIG.Minimum_Rate {651} \
    CONFIG.Number_Of_Stages {6} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Quantization {Truncation} \
    CONFIG.SamplePeriod {1} \
    CONFIG.Sample_Rate_Changes {Fixed} \
    CONFIG.Use_Xtreme_DSP_Slice {false} \
  ] $cic_1


  # Create instance: fir_0, and set properties
  set fir_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_0 ]
  set_property -dict [list \
    CONFIG.BestPrecision {true} \
    CONFIG.Clock_Frequency {125} \
    CONFIG.CoefficientVector {1.1896509788e-07, 6.9660228675e-05, 1.8425018915e-04, 3.2960570394e-04, 4.7279860336e-04, 5.6454358018e-04, 5.4730828786e-04, 3.6883610405e-04, -9.5501433577e-07, -5.5323682079e-04,\
-1.2281903741e-03, -1.9121033747e-03, -2.4470597682e-03, -2.6544152007e-03, -2.3702213517e-03, -1.4874792911e-03, 2.7116524257e-06, 1.9806444192e-03, 4.1874630308e-03, 6.2416178231e-03, 7.6850822476e-03,\
8.0564557276e-03, 6.9820306278e-03, 4.2706497456e-03, -5.0750014526e-06, -5.4589249828e-03, -1.1387267116e-02, -1.6819594829e-02, -2.0623007315e-02, -2.1650489475e-02, -1.8913867874e-02, -1.1755829839e-02,\
7.1619023374e-06, 1.5997042827e-02, 3.5260495169e-02, 5.6337852597e-02, 7.7410091897e-02, 9.6506595624e-02, 1.1174577702e-01, 1.2157425767e-01, 1.2496933198e-01, 1.2157425767e-01, 1.1174577702e-01, 9.6506595624e-02,\
7.7410091897e-02, 5.6337852597e-02, 3.5260495169e-02, 1.5997042827e-02, 7.1619023374e-06, -1.1755829839e-02, -1.8913867874e-02, -2.1650489475e-02, -2.0623007315e-02, -1.6819594829e-02, -1.1387267116e-02,\
-5.4589249828e-03, -5.0750014526e-06, 4.2706497456e-03, 6.9820306278e-03, 8.0564557276e-03, 7.6850822476e-03, 6.2416178231e-03, 4.1874630308e-03, 1.9806444192e-03, 2.7116524257e-06, -1.4874792911e-03,\
-2.3702213517e-03, -2.6544152007e-03, -2.4470597682e-03, -1.9121033747e-03, -1.2281903741e-03, -5.5323682079e-04, -9.5501433577e-07, 3.6883610405e-04, 5.4730828786e-04, 5.6454358018e-04, 4.7279860336e-04,\
3.2960570394e-04, 1.8425018915e-04, 6.9660228675e-05, 1.1896509788e-07} \
    CONFIG.Coefficient_Fractional_Bits {26} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Inferred} \
    CONFIG.Coefficient_Width {24} \
    CONFIG.ColumnConfig {1} \
    CONFIG.DATA_Has_TLAST {Not_Required} \
    CONFIG.Data_Width {32} \
    CONFIG.Decimation_Rate {1} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Single_Rate} \
    CONFIG.Has_ARESETn {true} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.M_DATA_Has_TUSER {Not_Required} \
    CONFIG.Number_Channels {1} \
    CONFIG.Number_Paths {1} \
    CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
    CONFIG.Output_Width {32} \
    CONFIG.Quantization {Quantize_Only} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.S_DATA_Has_TUSER {Not_Required} \
    CONFIG.Sample_Frequency {0.192012289} \
    CONFIG.Select_Pattern {All} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_0


  # Create instance: GMSK_Demod
  create_hier_cell_GMSK_Demod $hier_obj GMSK_Demod

  # Create instance: fir_1, and set properties
  set fir_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_1 ]
  set_property -dict [list \
    CONFIG.BestPrecision {true} \
    CONFIG.Clock_Frequency {125} \
    CONFIG.CoefficientVector {1.1896509788e-07, 6.9660228675e-05, 1.8425018915e-04, 3.2960570394e-04, 4.7279860336e-04, 5.6454358018e-04, 5.4730828786e-04, 3.6883610405e-04, -9.5501433577e-07, -5.5323682079e-04,\
-1.2281903741e-03, -1.9121033747e-03, -2.4470597682e-03, -2.6544152007e-03, -2.3702213517e-03, -1.4874792911e-03, 2.7116524257e-06, 1.9806444192e-03, 4.1874630308e-03, 6.2416178231e-03, 7.6850822476e-03,\
8.0564557276e-03, 6.9820306278e-03, 4.2706497456e-03, -5.0750014526e-06, -5.4589249828e-03, -1.1387267116e-02, -1.6819594829e-02, -2.0623007315e-02, -2.1650489475e-02, -1.8913867874e-02, -1.1755829839e-02,\
7.1619023374e-06, 1.5997042827e-02, 3.5260495169e-02, 5.6337852597e-02, 7.7410091897e-02, 9.6506595624e-02, 1.1174577702e-01, 1.2157425767e-01, 1.2496933198e-01, 1.2157425767e-01, 1.1174577702e-01, 9.6506595624e-02,\
7.7410091897e-02, 5.6337852597e-02, 3.5260495169e-02, 1.5997042827e-02, 7.1619023374e-06, -1.1755829839e-02, -1.8913867874e-02, -2.1650489475e-02, -2.0623007315e-02, -1.6819594829e-02, -1.1387267116e-02,\
-5.4589249828e-03, -5.0750014526e-06, 4.2706497456e-03, 6.9820306278e-03, 8.0564557276e-03, 7.6850822476e-03, 6.2416178231e-03, 4.1874630308e-03, 1.9806444192e-03, 2.7116524257e-06, -1.4874792911e-03,\
-2.3702213517e-03, -2.6544152007e-03, -2.4470597682e-03, -1.9121033747e-03, -1.2281903741e-03, -5.5323682079e-04, -9.5501433577e-07, 3.6883610405e-04, 5.4730828786e-04, 5.6454358018e-04, 4.7279860336e-04,\
3.2960570394e-04, 1.8425018915e-04, 6.9660228675e-05, 1.1896509788e-07} \
    CONFIG.Coefficient_Fractional_Bits {26} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Inferred} \
    CONFIG.Coefficient_Width {24} \
    CONFIG.ColumnConfig {1} \
    CONFIG.DATA_Has_TLAST {Not_Required} \
    CONFIG.Data_Width {32} \
    CONFIG.Decimation_Rate {1} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Single_Rate} \
    CONFIG.Has_ARESETn {true} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.M_DATA_Has_TUSER {Not_Required} \
    CONFIG.Number_Channels {1} \
    CONFIG.Number_Paths {1} \
    CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
    CONFIG.Output_Width {32} \
    CONFIG.Quantization {Quantize_Only} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.S_DATA_Has_TUSER {Not_Required} \
    CONFIG.Sample_Frequency {0.192012289} \
    CONFIG.Select_Pattern {All} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_1


  # Create instance: mux_out_sel_slice, and set properties
  set block_name port_slicer
  set block_cell_name mux_out_sel_slice
  if { [catch {set mux_out_sel_slice [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mux_out_sel_slice eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {96} \
    CONFIG.DIN_TO {96} \
    CONFIG.DIN_WIDTH {128} \
  ] $mux_out_sel_slice


  # Create instance: gmsk_iq_pack_fir, and set properties
  set block_name gmsk_iq_pack
  set block_cell_name gmsk_iq_pack_fir
  if { [catch {set gmsk_iq_pack_fir [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gmsk_iq_pack_fir eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {16} \
    CONFIG.IN1_WIDTH {20} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {20} \
    CONFIG.IN4_WIDTH {20} \
    CONFIG.IN5_WIDTH {1} \
    CONFIG.IN6_WIDTH {18} \
    CONFIG.IN7_WIDTH {32} \
    CONFIG.IN8_WIDTH {32} \
    CONFIG.NUM_PORTS {9} \
  ] $xlconcat_0


  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {18} \
  ] $xlconstant_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins fifo_0/m_axis] [get_bd_intf_pins m_axis]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins mult_0/S_AXIS_A] [get_bd_intf_pins s_axis_adc]
  connect_bd_intf_net -intf_net GMSK_Demod_m_axis1 [get_bd_intf_pins fifo_0/s_axis] [get_bd_intf_pins GMSK_Demod/m_axis_salida]
  connect_bd_intf_net -intf_net bcast_0_M00_AXIS [get_bd_intf_pins cic_0/S_AXIS_DATA] [get_bd_intf_pins bcast_0/M00_AXIS]
  connect_bd_intf_net -intf_net bcast_0_M01_AXIS [get_bd_intf_pins bcast_0/M01_AXIS] [get_bd_intf_pins cic_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net cic_0_M_AXIS_DATA [get_bd_intf_pins cic_0/M_AXIS_DATA] [get_bd_intf_pins fir_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net cic_1_M_AXIS_DATA [get_bd_intf_pins cic_1/M_AXIS_DATA] [get_bd_intf_pins fir_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net dds_0_M_AXIS_DATA [get_bd_intf_pins mult_0/S_AXIS_B] [get_bd_intf_pins osc_0/M_AXIS_DATA]
  connect_bd_intf_net -intf_net fir_0_M_AXIS_DATA [get_bd_intf_pins fir_0/M_AXIS_DATA] [get_bd_intf_pins gmsk_iq_pack_fir/s_axis_i]
  connect_bd_intf_net -intf_net fir_1_M_AXIS_DATA [get_bd_intf_pins fir_1/M_AXIS_DATA] [get_bd_intf_pins gmsk_iq_pack_fir/s_axis_q]
  connect_bd_intf_net -intf_net gmsk_iq_pack_fir_m_axis [get_bd_intf_pins gmsk_iq_pack_fir/m_axis] [get_bd_intf_pins GMSK_Demod/s_axis]
  connect_bd_intf_net -intf_net lfsr_0_m_axis [get_bd_intf_pins mult_0/S_AXIS_CTRL] [get_bd_intf_pins lfsr_0/m_axis]
  connect_bd_intf_net -intf_net mult_0_M_AXIS_DOUT [get_bd_intf_pins bcast_0/S_AXIS] [get_bd_intf_pins mult_0/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net phase_0_m_axis [get_bd_intf_pins osc_0/S_AXIS_PHASE] [get_bd_intf_pins phase_0/m_axis]

  # Create port connections
  connect_bd_net -net GMSK_Demod_activo_confirmado  [get_bd_pins GMSK_Demod/activo_confirmado] \
  [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net GMSK_Demod_activo_ext  [get_bd_pins GMSK_Demod/activo_ext] \
  [get_bd_pins xlconcat_0/In5]
  connect_bd_net -net GMSK_Demod_dispersion_dbg  [get_bd_pins GMSK_Demod/dispersion_dbg] \
  [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net GMSK_Demod_nivel  [get_bd_pins GMSK_Demod/nivel] \
  [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net GMSK_Demod_pico_cont  [get_bd_pins GMSK_Demod/pico_cont] \
  [get_bd_pins xlconcat_0/In7]
  connect_bd_net -net GMSK_Demod_piso_ruido_dbg  [get_bd_pins GMSK_Demod/piso_ruido_dbg] \
  [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net GMSK_Demod_rafaga_info  [get_bd_pins GMSK_Demod/rafaga_info] \
  [get_bd_pins xlconcat_0/In8]
  connect_bd_net -net aclk_1  [get_bd_pins aclk] \
  [get_bd_pins phase_0/aclk] \
  [get_bd_pins osc_0/aclk] \
  [get_bd_pins mult_0/aclk] \
  [get_bd_pins bcast_0/aclk] \
  [get_bd_pins cic_0/aclk] \
  [get_bd_pins fifo_0/aclk] \
  [get_bd_pins cic_1/aclk] \
  [get_bd_pins fir_0/aclk] \
  [get_bd_pins GMSK_Demod/clk_0] \
  [get_bd_pins fir_1/aclk] \
  [get_bd_pins lfsr_0/aclk] \
  [get_bd_pins gmsk_iq_pack_fir/clk]
  connect_bd_net -net aresetn_0_1  [get_bd_pins aresetn_0] \
  [get_bd_pins bcast_0/aresetn] \
  [get_bd_pins cic_0/aresetn] \
  [get_bd_pins cic_1/aresetn] \
  [get_bd_pins fir_0/aresetn] \
  [get_bd_pins fir_1/aresetn] \
  [get_bd_pins GMSK_Demod/aresetn_0] \
  [get_bd_pins lfsr_0/aresetn] \
  [get_bd_pins gmsk_iq_pack_fir/aresetn]
  connect_bd_net -net fifo_0_read_count  [get_bd_pins fifo_0/read_count] \
  [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net hub_0_cfg_data  [get_bd_pins din] \
  [get_bd_pins slice_1/din] \
  [get_bd_pins slice_0/din] \
  [get_bd_pins mux_out_sel_slice/din]
  connect_bd_net -net sel_out_1  [get_bd_pins mux_out_sel_slice/dout] \
  [get_bd_pins GMSK_Demod/sel_out]
  connect_bd_net -net slice_0_dout  [get_bd_pins slice_0/dout] \
  [get_bd_pins fifo_0/aresetn]
  connect_bd_net -net slice_1_dout  [get_bd_pins slice_1/dout] \
  [get_bd_pins phase_0/cfg_data]
  connect_bd_net -net xlconcat_0_dout  [get_bd_pins xlconcat_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_0/dout] \
  [get_bd_pins xlconcat_0/In6]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]

  set Vaux0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0 ]

  set Vaux1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1 ]

  set Vaux9 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9 ]

  set Vaux8 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8 ]

  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set adc_dat_a_i [ create_bd_port -dir I -from 15 -to 0 adc_dat_a_i ]
  set adc_dat_b_i [ create_bd_port -dir I -from 15 -to 0 adc_dat_b_i ]
  set adc_clk_p_i [ create_bd_port -dir I adc_clk_p_i ]
  set adc_clk_n_i [ create_bd_port -dir I adc_clk_n_i ]
  set adc_csn_o [ create_bd_port -dir O adc_csn_o ]
  set dac_dat_o [ create_bd_port -dir O -from 13 -to 0 dac_dat_o ]
  set dac_clk_o [ create_bd_port -dir O dac_clk_o ]
  set dac_rst_o [ create_bd_port -dir O dac_rst_o ]
  set dac_sel_o [ create_bd_port -dir O dac_sel_o ]
  set dac_wrt_o [ create_bd_port -dir O dac_wrt_o ]
  set dac_pwm_o [ create_bd_port -dir O -from 3 -to 0 dac_pwm_o ]
  set exp_n_tri_io [ create_bd_port -dir IO -from 7 -to 0 exp_n_tri_io ]
  set led_o [ create_bd_port -dir O -from 7 -to 0 led_o ]
  set exp_p_tri_io [ create_bd_port -dir O -from 1 -to 0 exp_p_tri_io ]

  # Create instance: pll_0, and set properties
  set pll_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 pll_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.0} \
    CONFIG.CLKOUT1_USED {true} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT2_REQUESTED_PHASE {157.5} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT3_REQUESTED_PHASE {202.5} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.PRIMITIVE {PLL} \
    CONFIG.PRIM_IN_FREQ {125.0} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.USE_RESET {false} \
  ] $pll_0


  # Create instance: ps_0, and set properties
  set ps_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps_0 ]
  set_property -dict [list \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {50.000000} \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
    CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
    CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_CAN_PERIPHERAL_VALID {0} \
    CONFIG.PCW_CLK0_FREQ {50000000} \
    CONFIG.PCW_CLK1_FREQ {10000000} \
    CONFIG.PCW_CLK2_FREQ {10000000} \
    CONFIG.PCW_CLK3_FREQ {10000000} \
    CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
    CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
    CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
    CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
    CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
    CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
    CONFIG.PCW_ENET0_RESET_ENABLE {0} \
    CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_ENET_RESET_ENABLE {1} \
    CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
    CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_EN_4K_TIMER {0} \
    CONFIG.PCW_EN_CAN0 {0} \
    CONFIG.PCW_EN_CAN1 {0} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_CLK1_PORT {0} \
    CONFIG.PCW_EN_CLK2_PORT {0} \
    CONFIG.PCW_EN_CLK3_PORT {0} \
    CONFIG.PCW_EN_DDR {1} \
    CONFIG.PCW_EN_EMIO_CAN0 {0} \
    CONFIG.PCW_EN_EMIO_CAN1 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_ENET0 {0} \
    CONFIG.PCW_EN_EMIO_ENET1 {0} \
    CONFIG.PCW_EN_EMIO_GPIO {1} \
    CONFIG.PCW_EN_EMIO_I2C0 {0} \
    CONFIG.PCW_EN_EMIO_I2C1 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} \
    CONFIG.PCW_EN_EMIO_PJTAG {0} \
    CONFIG.PCW_EN_EMIO_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_SPI0 {1} \
    CONFIG.PCW_EN_EMIO_SPI1 {0} \
    CONFIG.PCW_EN_EMIO_SRAM_INT {0} \
    CONFIG.PCW_EN_EMIO_TRACE {0} \
    CONFIG.PCW_EN_EMIO_TTC0 {0} \
    CONFIG.PCW_EN_EMIO_TTC1 {0} \
    CONFIG.PCW_EN_EMIO_UART0 {0} \
    CONFIG.PCW_EN_EMIO_UART1 {0} \
    CONFIG.PCW_EN_EMIO_WDT {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
    CONFIG.PCW_EN_ENET0 {1} \
    CONFIG.PCW_EN_ENET1 {0} \
    CONFIG.PCW_EN_GPIO {1} \
    CONFIG.PCW_EN_I2C0 {1} \
    CONFIG.PCW_EN_I2C1 {0} \
    CONFIG.PCW_EN_MODEM_UART0 {0} \
    CONFIG.PCW_EN_MODEM_UART1 {0} \
    CONFIG.PCW_EN_PJTAG {0} \
    CONFIG.PCW_EN_QSPI {0} \
    CONFIG.PCW_EN_SDIO0 {1} \
    CONFIG.PCW_EN_SDIO1 {0} \
    CONFIG.PCW_EN_SMC {0} \
    CONFIG.PCW_EN_SPI0 {1} \
    CONFIG.PCW_EN_SPI1 {1} \
    CONFIG.PCW_EN_TRACE {0} \
    CONFIG.PCW_EN_TTC0 {0} \
    CONFIG.PCW_EN_TTC1 {0} \
    CONFIG.PCW_EN_UART0 {1} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_EN_USB0 {1} \
    CONFIG.PCW_EN_USB1 {0} \
    CONFIG.PCW_EN_WDT {0} \
    CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
    CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} \
    CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
    CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
    CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C0_RESET_ENABLE {0} \
    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_I2C_RESET_ENABLE {1} \
    CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
    CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_IMPORT_BOARD_PRESET {cfg/red_pitaya.xml} \
    CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
    CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_0_PULLUP {disabled} \
    CONFIG.PCW_MIO_0_SLEW {slow} \
    CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_10_PULLUP {enabled} \
    CONFIG.PCW_MIO_10_SLEW {slow} \
    CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_11_PULLUP {enabled} \
    CONFIG.PCW_MIO_11_SLEW {slow} \
    CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_12_PULLUP {enabled} \
    CONFIG.PCW_MIO_12_SLEW {slow} \
    CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_13_PULLUP {enabled} \
    CONFIG.PCW_MIO_13_SLEW {slow} \
    CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_14_PULLUP {enabled} \
    CONFIG.PCW_MIO_14_SLEW {slow} \
    CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_15_PULLUP {enabled} \
    CONFIG.PCW_MIO_15_SLEW {slow} \
    CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_16_PULLUP {disabled} \
    CONFIG.PCW_MIO_16_SLEW {fast} \
    CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_17_PULLUP {disabled} \
    CONFIG.PCW_MIO_17_SLEW {fast} \
    CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_18_PULLUP {disabled} \
    CONFIG.PCW_MIO_18_SLEW {fast} \
    CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_19_PULLUP {disabled} \
    CONFIG.PCW_MIO_19_SLEW {fast} \
    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_1_PULLUP {enabled} \
    CONFIG.PCW_MIO_1_SLEW {slow} \
    CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_20_PULLUP {disabled} \
    CONFIG.PCW_MIO_20_SLEW {fast} \
    CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_21_PULLUP {disabled} \
    CONFIG.PCW_MIO_21_SLEW {fast} \
    CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_22_PULLUP {disabled} \
    CONFIG.PCW_MIO_22_SLEW {fast} \
    CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_23_PULLUP {disabled} \
    CONFIG.PCW_MIO_23_SLEW {fast} \
    CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_24_PULLUP {disabled} \
    CONFIG.PCW_MIO_24_SLEW {fast} \
    CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_25_PULLUP {disabled} \
    CONFIG.PCW_MIO_25_SLEW {fast} \
    CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_26_PULLUP {disabled} \
    CONFIG.PCW_MIO_26_SLEW {fast} \
    CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_27_PULLUP {disabled} \
    CONFIG.PCW_MIO_27_SLEW {fast} \
    CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_28_PULLUP {enabled} \
    CONFIG.PCW_MIO_28_SLEW {fast} \
    CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_29_PULLUP {enabled} \
    CONFIG.PCW_MIO_29_SLEW {fast} \
    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_2_SLEW {slow} \
    CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_30_PULLUP {enabled} \
    CONFIG.PCW_MIO_30_SLEW {fast} \
    CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_31_PULLUP {enabled} \
    CONFIG.PCW_MIO_31_SLEW {fast} \
    CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_32_PULLUP {enabled} \
    CONFIG.PCW_MIO_32_SLEW {fast} \
    CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_33_PULLUP {enabled} \
    CONFIG.PCW_MIO_33_SLEW {fast} \
    CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_34_PULLUP {enabled} \
    CONFIG.PCW_MIO_34_SLEW {fast} \
    CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_35_PULLUP {enabled} \
    CONFIG.PCW_MIO_35_SLEW {fast} \
    CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_36_PULLUP {enabled} \
    CONFIG.PCW_MIO_36_SLEW {fast} \
    CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_37_PULLUP {enabled} \
    CONFIG.PCW_MIO_37_SLEW {fast} \
    CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_38_PULLUP {enabled} \
    CONFIG.PCW_MIO_38_SLEW {fast} \
    CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_39_PULLUP {enabled} \
    CONFIG.PCW_MIO_39_SLEW {fast} \
    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_3_SLEW {slow} \
    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_40_PULLUP {enabled} \
    CONFIG.PCW_MIO_40_SLEW {slow} \
    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_41_PULLUP {enabled} \
    CONFIG.PCW_MIO_41_SLEW {slow} \
    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_42_PULLUP {enabled} \
    CONFIG.PCW_MIO_42_SLEW {slow} \
    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_43_PULLUP {enabled} \
    CONFIG.PCW_MIO_43_SLEW {slow} \
    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_44_PULLUP {enabled} \
    CONFIG.PCW_MIO_44_SLEW {slow} \
    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_45_PULLUP {enabled} \
    CONFIG.PCW_MIO_45_SLEW {slow} \
    CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_46_PULLUP {enabled} \
    CONFIG.PCW_MIO_46_SLEW {slow} \
    CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_47_PULLUP {enabled} \
    CONFIG.PCW_MIO_47_SLEW {slow} \
    CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_48_PULLUP {enabled} \
    CONFIG.PCW_MIO_48_SLEW {slow} \
    CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_49_PULLUP {enabled} \
    CONFIG.PCW_MIO_49_SLEW {slow} \
    CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_4_SLEW {slow} \
    CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_50_PULLUP {enabled} \
    CONFIG.PCW_MIO_50_SLEW {slow} \
    CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_51_PULLUP {enabled} \
    CONFIG.PCW_MIO_51_SLEW {slow} \
    CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_52_PULLUP {enabled} \
    CONFIG.PCW_MIO_52_SLEW {slow} \
    CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_53_PULLUP {enabled} \
    CONFIG.PCW_MIO_53_SLEW {slow} \
    CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_5_SLEW {slow} \
    CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_6_SLEW {slow} \
    CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_7_SLEW {slow} \
    CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_8_SLEW {slow} \
    CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_9_PULLUP {enabled} \
    CONFIG.PCW_MIO_9_SLEW {slow} \
    CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#UART 1#UART 1#SPI 1#SPI 1#SPI 1#SPI 1#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet\
0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#USB Reset#GPIO#I2C 0#I2C 0#Enet 0#Enet 0} \
    CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#gpio[1]#gpio[2]#gpio[3]#gpio[4]#gpio[5]#gpio[6]#gpio[7]#tx#rx#mosi#miso#sclk#ss[0]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#cd#wp#reset#gpio[49]#scl#sda#mdc#mdio}\
\
    CONFIG.PCW_NAND_CYCLES_T_AR {1} \
    CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
    CONFIG.PCW_NAND_CYCLES_T_RC {11} \
    CONFIG.PCW_NAND_CYCLES_T_REA {1} \
    CONFIG.PCW_NAND_CYCLES_T_RR {1} \
    CONFIG.PCW_NAND_CYCLES_T_WC {11} \
    CONFIG.PCW_NAND_CYCLES_T_WP {1} \
    CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_NOR_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_CS0_T_PC {1} \
    CONFIG.PCW_NOR_CS0_T_RC {11} \
    CONFIG.PCW_NOR_CS0_T_TR {1} \
    CONFIG.PCW_NOR_CS0_T_WC {11} \
    CONFIG.PCW_NOR_CS0_T_WP {1} \
    CONFIG.PCW_NOR_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_CS1_T_PC {1} \
    CONFIG.PCW_NOR_CS1_T_RC {11} \
    CONFIG.PCW_NOR_CS1_T_TR {1} \
    CONFIG.PCW_NOR_CS1_T_WC {11} \
    CONFIG.PCW_NOR_CS1_T_WP {1} \
    CONFIG.PCW_NOR_CS1_WE_TIME {0} \
    CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
    CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.080} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.063} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.057} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.068} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.047} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.025} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.006} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.017} \
    CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} \
    CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
    CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
    CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
    CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SMC_PERIPHERAL_VALID {0} \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
    CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
    CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
    CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
    CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
    CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
    CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
    CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
    CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
    CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
    CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_UART0_BAUD_RATE {115200} \
    CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
    CONFIG.PCW_UART1_BAUD_RATE {115200} \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
    CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
    CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
    CONFIG.PCW_UIPARAM_DDR_AL {0} \
    CONFIG.PCW_UIPARAM_DDR_BL {8} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {101.239} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {79.5025} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {60.536} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {71.7715} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {104.5365} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {70.676} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {59.1615} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {81.319} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
    CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
    CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
    CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_IO {MIO 48} \
    CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
    CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USB_RESET_ENABLE {1} \
    CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
    CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_USE_AXI_NONSECURE {0} \
    CONFIG.PCW_USE_CROSS_TRIGGER {0} \
    CONFIG.PCW_USE_M_AXI_GP1 {1} \
    CONFIG.PCW_USE_S_AXI_ACP {0} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
  ] $ps_0


  # Create instance: const_0, and set properties
  set block_name constant
  set block_cell_name const_0
  if { [catch {set const_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $const_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: rst_0, and set properties
  set rst_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_0 ]

  # Create instance: adc_0, and set properties
  set block_name axis_red_pitaya_adc
  set block_cell_name adc_0
  if { [catch {set adc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $adc_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.ADC_DATA_WIDTH {14} $adc_0


  # Create instance: dac_0, and set properties
  set block_name axis_red_pitaya_dac
  set block_cell_name dac_0
  if { [catch {set dac_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dac_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DAC_DATA_WIDTH {14} $dac_0


  # Create instance: rx_0
  create_hier_cell_rx_0 [current_bd_instance .] rx_0

  # Create instance: test_0
  create_hier_cell_test_0 [current_bd_instance .] test_0

  # Create instance: hub_0, and set properties
  set block_name axi_hub
  set block_cell_name hub_0
  if { [catch {set hub_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hub_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.CFG_DATA_WIDTH {128} \
    CONFIG.STS_DATA_WIDTH {160} \
  ] $hub_0


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_A_1 [get_bd_intf_pins rx_0/s_axis_adc] [get_bd_intf_pins adc_0/m_axis]
  connect_bd_intf_net -intf_net ps_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins ps_0/DDR]
  connect_bd_intf_net -intf_net ps_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins ps_0/FIXED_IO]
  connect_bd_intf_net -intf_net ps_0_M_AXI_GP0 [get_bd_intf_pins ps_0/M_AXI_GP0] [get_bd_intf_pins hub_0/s_axi]
  connect_bd_intf_net -intf_net ps_0_M_AXI_GP1 [get_bd_intf_pins ps_0/M_AXI_GP1] [get_bd_intf_pins test_0/s_axi]
  connect_bd_intf_net -intf_net rx_0_m_axis [get_bd_intf_pins hub_0/s00_axis] [get_bd_intf_pins rx_0/m_axis]
  connect_bd_intf_net -intf_net test_0_m_axi [get_bd_intf_pins ps_0/S_AXI_HP0] [get_bd_intf_pins test_0/m_axi]
  connect_bd_intf_net -intf_net test_0_m_axis_0 [get_bd_intf_pins dac_0/s_axis] [get_bd_intf_pins test_0/m_axis]

  # Create port connections
  connect_bd_net -net adc_0_adc_csn  [get_bd_pins adc_0/adc_csn] \
  [get_bd_ports adc_csn_o]
  connect_bd_net -net adc_clk_n_i_1  [get_bd_ports adc_clk_n_i] \
  [get_bd_pins pll_0/clk_in1_n]
  connect_bd_net -net adc_clk_p_i_1  [get_bd_ports adc_clk_p_i] \
  [get_bd_pins pll_0/clk_in1_p]
  connect_bd_net -net adc_dat_a_i_1  [get_bd_ports adc_dat_a_i] \
  [get_bd_pins adc_0/adc_dat_a]
  connect_bd_net -net adc_dat_b_i_1  [get_bd_ports adc_dat_b_i] \
  [get_bd_pins adc_0/adc_dat_b]
  connect_bd_net -net const_0_dout  [get_bd_pins const_0/dout] \
  [get_bd_pins rst_0/ext_reset_in]
  connect_bd_net -net dac_0_dac_clk  [get_bd_pins dac_0/dac_clk] \
  [get_bd_ports dac_clk_o]
  connect_bd_net -net dac_0_dac_dat  [get_bd_pins dac_0/dac_dat] \
  [get_bd_ports dac_dat_o]
  connect_bd_net -net dac_0_dac_rst  [get_bd_pins dac_0/dac_rst] \
  [get_bd_ports dac_rst_o]
  connect_bd_net -net dac_0_dac_sel  [get_bd_pins dac_0/dac_sel] \
  [get_bd_ports dac_sel_o]
  connect_bd_net -net dac_0_dac_wrt  [get_bd_pins dac_0/dac_wrt] \
  [get_bd_ports dac_wrt_o]
  connect_bd_net -net hub_0_cfg_data  [get_bd_pins hub_0/cfg_data] \
  [get_bd_pins rx_0/din]
  connect_bd_net -net pll_0_clk_out1  [get_bd_pins pll_0/clk_out1] \
  [get_bd_pins ps_0/M_AXI_GP0_ACLK] \
  [get_bd_pins rst_0/slowest_sync_clk] \
  [get_bd_pins adc_0/aclk] \
  [get_bd_pins dac_0/aclk] \
  [get_bd_pins rx_0/aclk] \
  [get_bd_pins test_0/aclk] \
  [get_bd_pins hub_0/aclk] \
  [get_bd_pins ps_0/M_AXI_GP1_ACLK] \
  [get_bd_pins ps_0/S_AXI_HP0_ACLK]
  connect_bd_net -net pll_0_clk_out2  [get_bd_pins pll_0/clk_out2] \
  [get_bd_pins dac_0/ddr_clk]
  connect_bd_net -net pll_0_clk_out3  [get_bd_pins pll_0/clk_out3] \
  [get_bd_pins dac_0/wrt_clk]
  connect_bd_net -net pll_0_locked  [get_bd_pins pll_0/locked] \
  [get_bd_pins rst_0/dcm_locked] \
  [get_bd_pins dac_0/locked]
  connect_bd_net -net rst_0_peripheral_aresetn  [get_bd_pins rst_0/peripheral_aresetn] \
  [get_bd_pins rx_0/aresetn_0] \
  [get_bd_pins hub_0/aresetn] \
  [get_bd_pins test_0/aresetn]
  connect_bd_net -net rx_0_dout  [get_bd_pins rx_0/dout] \
  [get_bd_pins hub_0/sts_data]

  # Create address segments
  assign_bd_address -offset 0x80000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs test_0/axi_hub_0/s_axi/reg0] -force
  assign_bd_address -offset 0x40000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs hub_0/s_axi/reg0] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces test_0/axis_ram_reader_0/m_axi] [get_bd_addr_segs ps_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


