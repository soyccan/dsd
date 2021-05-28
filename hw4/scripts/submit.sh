#!/bin/bash

set -ex

prefix="DSD_HW4_b07902143"

mkdir -p "${prefix}/"{rtl,syn}

cat src/{cache_sram_dm,cache_controller,cache_dm}.v \
    | grep -v '`include' > "${prefix}/rtl/cache_dm.v"

{
    echo '`define TWO_WAY'
    cat src/{cache_sram_2way,cache_controller,cache_2way}.v \
        | grep -v '`include'
} > "${prefix}/rtl/cache_2way.v"

for name in dm 2way; do
    for ext in ddc sdf v; do
        cp "syn/${name}/cache_syn.${ext}" \
           "${prefix}/syn/cache_${name}_syn.${ext}"
    done
done

rm -f "${prefix}.zip"
zip -r "${prefix}.zip" "${prefix}"
rm -rf "${prefix}"
