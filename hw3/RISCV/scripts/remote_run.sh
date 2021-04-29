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
# 8: Use RV32IC instead of RV32I
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
    # 'rm -rf ~/hw3/*'

# Upload files
scp -r -o "ControlPath=$SOCKET" \
    "$proj_root/scripts/"* \
    "$proj_root/verilog/"* \
    "$proj_root/verilog/.synopsys_dc.setup" \
    b7902143@cad30.ee.ntu.edu.tw:~/hw3/

# Simulate RTL
if (( mode & 1 )); then
    if (( mode & 8 )); then
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw3
             rm -rf INCA_libs
             source /usr/cad/cadence/cshrc
             ncverilog RISCV_tb.v \
                       +access+r \
                       +define+RV32IC+RTL
            ' | tee rtl.log
    else
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw3
             rm -rf INCA_libs
             source /usr/cad/cadence/cshrc
             ncverilog RISCV_tb.v \
                       +access+r \
                       +define+RV32I+RTL
            ' | tee rtl.log
    fi
fi

# Synthesize
if (( mode & 2 )); then
    if (( mode & 8 )); then
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw3
             source /usr/cad/synopsys/CIC/synthesis.cshrc
             source /usr/cad/synopsys/CIC/verdi.cshrc
             design_vision -no_gui -f rv32ic.dv
            ' | tee syn/syn.log
    else
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw3
             source /usr/cad/synopsys/CIC/synthesis.cshrc
             source /usr/cad/synopsys/CIC/verdi.cshrc
             design_vision -no_gui -f rv32i.dv
            ' | tee syn/syn.log
    fi

    # Download gate-level verilog
    scp -o "ControlPath=$SOCKET" \
        b7902143@cad30.ee.ntu.edu.tw:~/hw3/CHIP_syn.{v,sdf,ddc} \
        ./syn/
fi

# Post-synthesis simulation
if (( mode & 4 )); then
    if (( mode & 8 )); then
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw3
             rm -rf INCA_libs
             source /usr/cad/cadence/cshrc
             ncverilog RISCV_tb.v \
                       +incdir+lib \
                       +access+r \
                       +define+RV32IC+SYN
            ' | tee postsyn.log
    else
        ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
            'cd ~/hw3
             rm -rf INCA_libs
             source /usr/cad/cadence/cshrc
             ncverilog RISCV_tb.v \
                       +incdir+lib \
                       +access+r \
                       +define+RV32I+SYN
            ' | tee postsyn.log
    fi
fi

