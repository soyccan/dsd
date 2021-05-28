#!/bin/bash

set -ex

PREFIX="b07902143_machine"

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
    "rm -rf ${PREFIX} DSD_MachineTest
     unzip -j 1092_DSD_MachineTest.zip -d DSD_MachineTest
     unzip ${PREFIX}.zip
     cd DSD_MachineTest
     cp -fv ~/${PREFIX}/* .

     source /usr/cad/cadence/cshrc
     ncverilog +access+r ALU_tb.v ALU.v
     ncverilog +access+r DFC_tb.v DFC.v ALU.v
     ncverilog +access+r DFC_tb.v DFC_syn.v -v tsmc13.v +define+SDF
    "

