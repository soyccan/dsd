#!/bin/bash

proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Reuse connection
SOCKET='/tmp/ssh.sock'

# Kill connection on exit
# negative pid specifies process group
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# argument mode
# 0: ALU RTL simulation
# 1: DFC RTL simulation
# 2: DFC Synthesis
# 3: Post-synthesis simulation
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
    # 'rm -rf ~/machine_test/*'

# Upload files
scp -r -o "ControlPath=$SOCKET" \
    "$proj_root/PartI_ALU/"* \
    "$proj_root/PartII_DFC/"* \
    "$proj_root/PartII_DFC/.synopsys_dc.setup" \
    b7902143@cad30.ee.ntu.edu.tw:~/machine_test

# Simulate ALU RTL
if [ "$mode" = 0 ]; then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        'cd ~/machine_test
         rm -rf INCA_libs
         source /usr/cad/cadence/cshrc
         ncverilog +access+r ALU_tb.v ALU.v
        ' | tee rtl_alu.log
fi

# Simulate DFC RTL
if [ "$mode" = 1 ]; then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        'cd ~/machine_test
         rm -rf INCA_libs
         source /usr/cad/cadence/cshrc
         ncverilog +access+r DFC_tb.v DFC.v ALU.v
        ' | tee rtl_dfc.log
fi

# Synthesize
if [ "$mode" = 2 ]; then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        'cd ~/machine_test
         source /usr/cad/synopsys/CIC/synthesis.cshrc
         design_vision -no_gui -f DFC_DC.sdc
        ' | tee syn.log

    # Download gate-level verilog
    scp -o "ControlPath=$SOCKET" \
        b7902143@cad30.ee.ntu.edu.tw:~/machine_test/DFC_syn.{v,sdf,ddc} \
        ./syn/
fi

# Post-synthesis simulation
if [ "$mode" = 3 ]; then
    ssh -S "$SOCKET" b7902143@cad30.ee.ntu.edu.tw \
        "cd ~/machine_test
         rm -rf INCA_libs
         source /usr/cad/cadence/cshrc
         ncverilog +access+r DFC_tb.v DFC_syn.v -v tsmc13.v +define+SDF
        " | tee postsyn.log
fi

