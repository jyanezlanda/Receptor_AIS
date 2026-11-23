# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHIFT_ATAQUE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHIFT_LIBERACION" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.SHIFT_ATAQUE { PARAM_VALUE.SHIFT_ATAQUE } {
	# Procedure called to update SHIFT_ATAQUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT_ATAQUE { PARAM_VALUE.SHIFT_ATAQUE } {
	# Procedure called to validate SHIFT_ATAQUE
	return true
}

proc update_PARAM_VALUE.SHIFT_LIBERACION { PARAM_VALUE.SHIFT_LIBERACION } {
	# Procedure called to update SHIFT_LIBERACION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT_LIBERACION { PARAM_VALUE.SHIFT_LIBERACION } {
	# Procedure called to validate SHIFT_LIBERACION
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.SHIFT_ATAQUE { MODELPARAM_VALUE.SHIFT_ATAQUE PARAM_VALUE.SHIFT_ATAQUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT_ATAQUE}] ${MODELPARAM_VALUE.SHIFT_ATAQUE}
}

proc update_MODELPARAM_VALUE.SHIFT_LIBERACION { MODELPARAM_VALUE.SHIFT_LIBERACION PARAM_VALUE.SHIFT_LIBERACION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT_LIBERACION}] ${MODELPARAM_VALUE.SHIFT_LIBERACION}
}

