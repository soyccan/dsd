#!/bin/bash

set -ex
PREFIX="DSD_HW3_b07902143"

# Reuse connection
SOCKET='/tmp/ssh.sock'

# Kill connection on exit
# negative pid specifies process group
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Create connection
ssh -NMS "$SOCKET" b7902143@cad30.ee.ntu.edu.tw &

# Upload files
scp -r -o "ControlPath=$SOCKET" \
    "${PREFIX}.zip" \
    b7902143@cad30.ee.ntu.edu.tw:~

ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
    "rm -rf ${PREFIX} RISCV
     unzip RISCV.zip
     unzip ${PREFIX}.zip
     cd RISCV/verilog
     cp -fv ~/${PREFIX}/* .
     sed -i 's/define END_CYCLE 30/define END_CYCLE 40/' RISCV_tb.v
     sed -i 's/define CYCLE 10/define CYCLE 2.9/' RISCV_tb.v
     ln -sf /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v .
     source /usr/cad/cadence/cshrc
     ncverilog RISCV_tb.v +access+r +define+RV32I+RTL
     ncverilog RISCV_tb.v +access+r +define+RV32I+SYN
    "
