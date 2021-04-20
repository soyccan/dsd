# This is to be read by design_vision by:
#   design_vision -no_gui -f dv.cmd

read_verilog CHIP.v
source CHIP_syn.sdc

report_timing
report_area

quit
