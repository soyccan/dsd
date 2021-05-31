#!/bin/bash

proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && cd .. && pwd)"

REMOTE_DIR='~/final_project'

# Reuse connection
SOCKET='/tmp/ssh.sock'

# Kill connection on exit
# negative pid specifies process group
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# arguments
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
            opt_hazard=0
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
    b7902143@cad30.ee.ntu.edu.tw:"$REMOTE_DIR/"
rsync \
    -e "ssh -S '$SOCKET'" \
    --archive --verbose --compress --update --progress --human-readable \
    "$proj_root/test/baseline/pattern/" \
    b7902143@cad30.ee.ntu.edu.tw:"$REMOTE_DIR/"

# Simulate RTL
if (( opt_rtl )); then
    if (( opt_hazard )); then
        define=hasHazard
    else
        define=noHazard
    fi

    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw "
        cd $REMOTE_DIR
        rm -rf INCA_libs
        source /usr/cad/cadence/cshrc
        ncverilog \
            test/baseline/testbench/Final_tb.v \
            src/CHIP.v \
            src/cacheD.v \
            src/MIPS_Pipeline.v \
            src/PC.v \
            src/Control.v \
            src/RegFile.v \
            src/Forward.v \
            src/Hazard_Detection.v \
            src/ALU.v \
            lib/slow_memory.v \
            +incdir+test/baseline/testbench \
            +incdir+include \
            +incdir+src \
            +define+$define +access+r
    " | tee rtl.log
fi

# Synthesize
if (( opt_syn )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw "
        cd $REMOTE_DIR
        source /usr/cad/synopsys/CIC/synthesis.cshrc
        design_vision -no_gui -f syn/CHIP_syn.sdc
    " | tee netlist/syn.log

    # Download gate-level verilog
    scp -o "ControlPath=$SOCKET" \
        b7902143@cad30.ee.ntu.edu.tw:"$REMOTE_DIR"/CHIP.{v,sdf,ddc} \
        ./netlist
fi

# Post-synthesis simulation
if (( mode & 4 )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        "cd $REMOTE_DIR
         rm -rf INCA_libs
         source /usr/cad/cadence/cshrc
         source /usr/spring_soft/CIC/verdi.cshrc
         sed -i 's/^\`define CYCLE.*$/\`define CYCLE 3.0/' tb_cache.v
         ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v \
                   +define+noHazard +define+SDF +access+r
        " | tee postsyn.log
fi

