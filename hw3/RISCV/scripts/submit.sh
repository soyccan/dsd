#!/bin/bash

set -ex
prefix="DSD_HW3_b07902143"

mkdir -p "${prefix}"
cat verilog/{Const,ALU,Control,ImmGen,PC,RegFile,CHIP}.v \
    | grep -v '^`include' > "${prefix}/CHIP.v"
cp syn/* "${prefix}"

rm -f "${prefix}.zip"
zip -r "${prefix}.zip" "${prefix}"
rm -rf "${prefix}"
