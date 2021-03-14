tmpdir=$(mktemp -d)
tmpdir2=$(mktemp -d)

unzip -d $tmpdir DSD_HW1.zip 
unzip -d $tmpdir2 DSD_HW1_b07902143.zip
cp -rvf $tmpdir2/DSD_HW1_b07902143/* $tmpdir

{
    cd $tmpdir

    (
        cd 1-CR_Adder
        ncverilog adder_gate_test.v adder_gate.v +access+r
        ncverilog adder_test.v adder.v +access+r
    )

    (
        cd 2-barrel_shifter
        ncverilog barrel_gate_test.v barrel_shifter_gate.v +access+r
        ncverilog barrel_test.v barrel_shifter.v +access+r
    )

    (
        cd 3-ASU
        ncverilog asu_test.v asu.v ../1-CR_Adder/adder.v ../2-barrel_shifter/barrel_shifter.v +access+r
        ncverilog asu_gate_test.v asu_gate.v ../1-CR_Adder/adder_gate.v ../2-barrel_shifter/barrel_shifter_gate.v +access+r
        ncverilog asu_gate_test.v asu_gate.v adder_gate_opt.v barrel_shifter_gate_opt.v +access+r
    )
} | grep 'An ERROR'
