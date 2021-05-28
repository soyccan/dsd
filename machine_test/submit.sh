#!/bin/bash

set -ex

prefix="b07902143_machine"

mkdir -p "${prefix}"

cp DSD_MachineTestFinalOutcome.docx "${prefix}"
cp PartI_ALU/ALU.v "${prefix}"
cp PartII_DFC/DFC.v "${prefix}"
cp syn/DFC_syn.{v,sdf,ddc} "${prefix}"

rm -f "${prefix}.zip"
zip -r "${prefix}.zip" "${prefix}"
rm -rf "${prefix}"
