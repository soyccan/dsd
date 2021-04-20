#!/bin/bash

proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Reuse connection
SOCKET='/tmp/ssh.sock'

args=(-N # do not execute remote command
      -M # ControlMaster=auto: master mode for connection sharing
      -S "$SOCKET") # ControlPath: location of control socket

ssh "${args[@]}" b7902143@cad30.ee.ntu.edu.tw &

ssh_pid=$!


# ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
#     'rm -rf ~/hw3/*'

scp -r -o "ControlPath=$SOCKET" \
    "$proj_root/verilog/".* \
    "$proj_root/scripts/"* \
    b7902143@cad30.ee.ntu.edu.tw:~/hw3/

ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
    'cd ~/hw3
     rm -rf INCA_libs
     source /usr/cad/cadence/cshrc
     ncverilog RISCV_tb.v \
               +access+r \
               +define+RV32I+RTL
     source /usr/cad/synopsys/CIC/synthesis.cshrc
     source /usr/cad/synopsys/CIC/verdi.cshrc
     design_vision -no_gui -f dv.cmd
    ' | tee remote.log
     # ncverilog RISCV_tb.v \
     #           +incdir+lib \
     #           +access+r \
     #           +define+RV32I+SYN



               # +define+RV32I+RTL
               # +define+RV32I+SYN
               # +define+RV32IC+RTL'
               # +define+RV32IC+SYN'

kill $ssh_pid

wait $ssh_pid


