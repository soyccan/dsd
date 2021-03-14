#!/bin/bash
rm DSD_HW1_b07902143.zip
zip DSD_HW1_b07902143.zip \
    DSD_HW1_b07902143/1-CR_Adder/{adder.v,adder_gate.v} \
    DSD_HW1_b07902143/2-barrel_shifter/{barrel_shifter.v,barrel_shifter_gate.v} \
    DSD_HW1_b07902143/3-ASU/{asu.v,asu_gate.v,adder_gate_opt.v,barrel_shifter_gate_opt.v}
    # report_HW1_b04901032.pdf
