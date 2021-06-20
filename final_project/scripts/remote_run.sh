#!/bin/bash

proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && cd .. && pwd)"

REMOTE_DIR='~/final_project'

# Reuse connection
SOCKET='/tmp/ssh.sock'

# Kill connection on exit
# negative pid specifies process group
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# arguments
cycle=10
while [[ "$1" ]]; do
    case $1 in
        -rtl)
            # RTL simulation
            opt_rtl=1
            ;;
        -syn)
            # Synthesis
            opt_syn=1
            ;;
        -gate)
            # Gate-level simulation
            opt_gate=1
            ;;
        -hazard)
            # With hazard
            opt_hazard=1
            ;;
        -nohazard)
            # Without hazard
            opt_nohazard=1
            ;;
        -brpred)
            # with branch predictor
            opt_brpred=1
            ;;
        -l2)
            # with L2 cache
            opt_l2=1
            ;;
        -muldiv)
            # with multiplier and divider
            opt_muldiv=1
            ;;
        *)
            # clock cycle
            cycle="$1"
            ;;
    esac

    shift
done


# Create connection
ssh -N \
    -o 'ControlMaster=yes' \
    -o "ControlPath=$SOCKET" \
    b7902143@cad30.ee.ntu.edu.tw &

# Upload only updated files
rsync \
    -e "ssh -S '$SOCKET'" \
    --archive --verbose --compress --update --progress --human-readable \
    "$proj_root/lib" \
    "$proj_root/src" \
    "$proj_root/syn" \
    "$proj_root/include" \
    "$proj_root/test" \
    "$proj_root/netlist" \
    b7902143@cad30.ee.ntu.edu.tw:"$REMOTE_DIR/"
rsync \
    -e "ssh -S '$SOCKET'" \
    --archive --verbose --compress --update --progress --human-readable \
    "$proj_root/syn/.synopsys_dc.setup" \
    "$proj_root/test/baseline/pattern/" \
    "$proj_root/test/brPred/pattern/" \
    "$proj_root/test/l2cache/pattern/" \
    "$proj_root/test/mulDiv/pattern/" \
    b7902143@cad30.ee.ntu.edu.tw:"$REMOTE_DIR/"


# compile macro definition
defines=

if (( opt_hazard )); then
    defines="$defines +define+hasHazard"

elif (( opt_nohazard )); then
    defines="$defines +define+noHazard"

elif (( opt_brpred )); then
    defines="$defines +define+BrPred"

elif (( opt_l2 )); then
    defines="$defines +define+L2Cache"

elif (( opt_muldiv )); then
    defines="$defines +define+MultDiv"

fi


# Simulate RTL
if (( opt_rtl )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw "
        cd $REMOTE_DIR
        rm -rf INCA_libs
        source /usr/cad/cadence/cshrc
        ncverilog \
            test/baseline/testbench/Final_tb.v \
            src/CHIP.v \
            src/cacheD.v \
            src/cacheI.v \
            src/L2cache.v \
            src/MIPS_Pipeline.v \
            src/PC.v \
            src/Control.v \
            src/RegFile.v \
            src/Forward.v \
            src/HazardDetect.v \
            src/ALU.v \
            src/StallControl.v \
            lib/slow_memory.v \
            +incdir+test/baseline/testbench \
            +incdir+test/brPred/testbench \
            +incdir+test/l2cache/testbench \
            +incdir+test/mulDiv/testbench \
            +incdir+include \
            +incdir+src \
            $defines +access+r
    " | tee rtl.log
fi

# Synthesize
if (( opt_syn )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw "
        cd $REMOTE_DIR
        sed -i 's/^set cycle.*$/set cycle $cycle/' \
            syn/CHIP_syn.sdc
        source /usr/cad/synopsys/CIC/synthesis.cshrc
        design_vision -no_gui -f syn/CHIP_syn.sdc
    " | tee netlist/syn.log

    # Download gate-level verilog
    scp -o "ControlPath=$SOCKET" \
        b7902143@cad30.ee.ntu.edu.tw:"$REMOTE_DIR"/CHIP_syn.{v,sdf,ddc} \
        ./netlist
fi

# Post-synthesis simulation
if (( opt_gate )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw "
        cd $REMOTE_DIR
        rm -rf INCA_libs
        source /usr/cad/cadence/cshrc
        sed -i 's/^\`define CYCLE.*$/\`define CYCLE $cycle/' \
            test/baseline/testbench/Final_tb.v
        ncverilog \
            test/baseline/testbench/Final_tb.v \
            netlist/CHIP_syn.v \
            lib/slow_memory.v \
            /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v \
            +incdir+test/baseline/testbench \
            +incdir+test/brPred/testbench \
            +incdir+test/l2cache/testbench \
            +incdir+test/mulDiv/testbench \
            +incdir+include \
            +incdir+src \
            $defines +define+SDF +access+r
    " | tee gate.log
fi

