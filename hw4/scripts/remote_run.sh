#!/bin/bash

proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && cd .. && pwd)"

# Reuse connection
SOCKET='/tmp/ssh.sock'

# Kill connection on exit
# negative pid specifies process group
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# argument mode
# 1: RTL simulation
# 2: Synthesis
# 4: Post-synthesis simulation
# 8: Use 2-way associative instead of direct-mapped
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

# ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
    # 'rm -rf ~/hw4/*'

# Upload files
scp -r -o "ControlPath=$SOCKET" \
    "$proj_root/lib/"* \
    "$proj_root/src/"* \
    "$proj_root/syn_req/"* \
    "$proj_root/syn_req/.synopsys_dc.setup" \
    b7902143@cad30.ee.ntu.edu.tw:~/hw4

# Simulate RTL
if (( mode & 1 )); then
    if (( mode & 8 )); then
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw4
             rm -rf INCA_libs
             source /usr/cad/cadence/cshrc
             ncverilog tb_cache.v memory.v cache_2way.v +access+r
            ' | tee rtl.log
    else
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw4
             rm -rf INCA_libs
             source /usr/cad/cadence/cshrc
             ncverilog tb_cache.v memory.v cache_dm.v +access+r
            ' | tee rtl.log
    fi
fi

# Synthesize
if (( mode & 2 )); then
    if (( mode & 8 )); then
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw4
             source /usr/cad/synopsys/CIC/synthesis.cshrc
             design_vision -no_gui -x " \
                 read_file -format verilog cache_2way.v \
                 source cache_syn.sdc"
            ' | tee syn/2way/log

        # Download gate-level verilog
        scp -o "ControlPath=$SOCKET" \
            b7902143@cad30.ee.ntu.edu.tw:~/hw4/cache_syn.{v,sdf,ddc} \
            ./syn/2way
    else
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw4
             source /usr/cad/synopsys/CIC/synthesis.cshrc
             design_vision -no_gui -x " \
                 read_file -format verilog cache_dm.v \
                 source cache_syn.sdc"
            ' | tee syn/dm/log

        # Download gate-level verilog
        scp -o "ControlPath=$SOCKET" \
            b7902143@cad30.ee.ntu.edu.tw:~/hw4/cache_syn.{v,sdf,ddc} \
            ./syn/dm
    fi
fi

# Post-synthesis simulation
if (( mode & 4 )); then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        'cd ~/hw4
         rm -rf INCA_libs
         source /usr/cad/cadence/cshrc
         source /usr/spring_soft/CIC/verdi.cshrc
         ncverilog tb_cache.v cache_syn.v memory.v \
                   /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v \
                   +define+SDF +access+r
        ' | tee postsyn.log
fi

