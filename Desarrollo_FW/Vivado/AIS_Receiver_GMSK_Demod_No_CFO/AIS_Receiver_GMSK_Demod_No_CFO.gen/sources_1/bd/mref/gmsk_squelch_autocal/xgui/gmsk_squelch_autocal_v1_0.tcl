# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "K_ALTO" -parent ${Page_0}
  ipgui::add_param $IPINST -name "K_BAJO" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MARGEN_MINIMO" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHIFT_DISP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHIFT_PISO" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.K_ALTO { PARAM_VALUE.K_ALTO } {
	# Procedure called to update K_ALTO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.K_ALTO { PARAM_VALUE.K_ALTO } {
	# Procedure called to validate K_ALTO
	return true
}

proc update_PARAM_VALUE.K_BAJO { PARAM_VALUE.K_BAJO } {
	# Procedure called to update K_BAJO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.K_BAJO { PARAM_VALUE.K_BAJO } {
	# Procedure called to validate K_BAJO
	return true
}

proc update_PARAM_VALUE.MARGEN_MINIMO { PARAM_VALUE.MARGEN_MINIMO } {
	# Procedure called to update MARGEN_MINIMO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MARGEN_MINIMO { PARAM_VALUE.MARGEN_MINIMO } {
	# Procedure called to validate MARGEN_MINIMO
	return true
}

proc update_PARAM_VALUE.SHIFT_DISP { PARAM_VALUE.SHIFT_DISP } {
	# Procedure called to update SHIFT_DISP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT_DISP { PARAM_VALUE.SHIFT_DISP } {
	# Procedure called to validate SHIFT_DISP
	return true
}

proc update_PARAM_VALUE.SHIFT_PISO { PARAM_VALUE.SHIFT_PISO } {
	# Procedure called to update SHIFT_PISO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT_PISO { PARAM_VALUE.SHIFT_PISO } {
	# Procedure called to validate SHIFT_PISO
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.SHIFT_PISO { MODELPARAM_VALUE.SHIFT_PISO PARAM_VALUE.SHIFT_PISO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT_PISO}] ${MODELPARAM_VALUE.SHIFT_PISO}
}

proc update_MODELPARAM_VALUE.SHIFT_DISP { MODELPARAM_VALUE.SHIFT_DISP PARAM_VALUE.SHIFT_DISP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT_DISP}] ${MODELPARAM_VALUE.SHIFT_DISP}
}

proc update_MODELPARAM_VALUE.K_ALTO { MODELPARAM_VALUE.K_ALTO PARAM_VALUE.K_ALTO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.K_ALTO}] ${MODELPARAM_VALUE.K_ALTO}
}

proc update_MODELPARAM_VALUE.K_BAJO { MODELPARAM_VALUE.K_BAJO PARAM_VALUE.K_BAJO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.K_BAJO}] ${MODELPARAM_VALUE.K_BAJO}
}

proc update_MODELPARAM_VALUE.MARGEN_MINIMO { MODELPARAM_VALUE.MARGEN_MINIMO PARAM_VALUE.MARGEN_MINIMO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MARGEN_MINIMO}] ${MODELPARAM_VALUE.MARGEN_MINIMO}
}

