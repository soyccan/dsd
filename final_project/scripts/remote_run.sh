#!/bin/bash

proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && cd .. && pwd)"

REMOTE_DIR='~/final_project'

# Reuse connection
SOCKET='/tmp/ssh.sock'

# Kill connection on exit
# negative pid specifies process group
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# argument mode
# 1: RTL simulation
# 2: Synthesis
# 4: Post-synthesis simulation
mode="$1"

if [[ ! "$mode" ]]; then
    echo Please specify mode!
    exit 1
fi


# Create connection
args=(-N # do not execute remote command
      -M # ControlMaster=auto: master mode for connection sharing
      -S "$SOCKET") # ControlPath: location of control socket

ssh "${args[@]}" b7902143@cad30.ee.ntu.edu.tw &

# Upload files
scp -r -o "ControlPath=$SOCKET" \
    "$proj_root/lib/" \
    "$proj_root/src/" \
    "$proj_root/syn/" \
    "$proj_root/include/" \
    "$proj_root/test/" \
    b7902143@cad30.ee.ntu.edu.tw:"$REMOTE_DIR"

# Simulate RTL
if (( mode & 1 )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        "cd $REMOTE_DIR
         rm -rf INCA_libs
         source /usr/cad/cadence/cshrc
         ncverilog Final_tb.v CHIP.v slow_memory.v +define+noHazard +access+r
        " | tee rtl.log
fi

# Synthesize
if (( mode & 2 )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        "cd $REMOTE_DIR
         source /usr/cad/synopsys/CIC/synthesis.cshrc
         design_vision -no_gui -x " \
             read_file -format verilog cache_2way.v \
             source cache_syn.sdc"
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

