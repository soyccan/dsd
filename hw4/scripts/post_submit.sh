#!/bin/bash

set -ex

PREFIX="DSD_HW4_b07902143"

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
    "rm -rf ${PREFIX} HW4
     unzip HW4.zip
     unzip ${PREFIX}.zip
     cd HW4
     cp -fv ~/${PREFIX}/rtl/* .
     cp -fv ~/${PREFIX}/syn/* .
     ln -sf /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v .
     source /usr/cad/cadence/cshrc

     sed -i 's/define CYCLE .*/define CYCLE 3/' tb_cache.v
     sed -i 's/define SDFFILE .*/define SDFFILE \"cache_dm_syn.sdf\"/' tb_cache.v
     ncverilog tb_cache.v cache_dm.v memory.v +access+r
     ncverilog tb_cache.v cache_dm_syn.v memory.v tsmc13.v +define+SDF +access+r

     sed -i 's/define SDFFILE .*/define SDFFILE \"cache_2way_syn.sdf\"/' tb_cache.v
     ncverilog tb_cache.v cache_2way.v memory.v +access+r
     ncverilog tb_cache.v cache_2way_syn.v memory.v tsmc13.v +define+SDF +access+r
    "

