read_file -format verilog ALU.v
read_file -format verilog DFC.v
current_design DFC

#### Constraint
# operating conditions and boundary conditions #

set cycle  10         ;#clock period defined by designer

create_clock -period $cycle [get_ports  clk]
set_dont_touch_network      [get_clocks clk]
set_fix_hold                [get_clocks clk]
set_clock_uncertainty  0.1  [get_clocks clk]
set_clock_latency      0.5  [get_clocks clk]

set_input_delay  5      -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 5      -clock clk [all_outputs]
set_load         1     [all_outputs]
set_drive        1     [all_inputs]

set_operating_conditions -max_library slow -max slow
set_wire_load_model -name tsmc13_wl10 -library slow


#### End Constraint

compile

check_design
report_timing
write_sdf -version 2.1 DFC_syn.sdf
write -f verilog -hierarchy -output DFC_syn.v
write -f ddc -hierarchy -output DFC_syn.ddc

quit
