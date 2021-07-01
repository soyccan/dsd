#!/bin/csh -vf
set WORK_DIR=`pwd`


cd Src/Baseline/rtl
ln -sf "$WORK_DIR/../Final_tb.v" .
ln -sf "$WORK_DIR/../Test"* .
ln -sf "$WORK_DIR/../D_mem" .
ln -sf "$WORK_DIR/../I_mem"* .
ln -sf "$WORK_DIR/../slow_memory.v" .
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
ncverilog Final_tb.v CHIP.v cache_controller.v cache_sram_2way.v MIPS_Pipeline.v PC.v Control.v RegFile.v Forward.v HazardDetect.v ALU.v StallControl.v slow_memory.v +define+noHazard +access+r
ncverilog Final_tb.v CHIP.v cache_controller.v cache_sram_2way.v MIPS_Pipeline.v PC.v Control.v RegFile.v Forward.v HazardDetect.v ALU.v StallControl.v slow_memory.v +define+hasHazard +access+r
cd ../../..

cd Src/Baseline/syn
ln -sf "$WORK_DIR/../Final_tb.v" .
ln -sf "$WORK_DIR/../Test"* .
ln -sf "$WORK_DIR/../D_mem" .
ln -sf "$WORK_DIR/../I_mem"* .
ln -sf "$WORK_DIR/../slow_memory.v" .
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
sed -i 's/^`define CYCLE.*$/`define CYCLE 2.8/' Final_tb.v
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+noHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r
cd ../../..

cd Src/L2Cache/rtl
ln -sf "$WORK_DIR/../Final_tb.v" .
ln -sf "$WORK_DIR/../Test"* .
ln -sf "$WORK_DIR/../D_mem" .
ln -sf "$WORK_DIR/../I_mem"* .
ln -sf "$WORK_DIR/../slow_memory.v" .
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
ncverilog Final_tb.v slow_memory.v ALU.v cacheD.v cacheI.v CHIP.v Control.v Forward.v HazardDetect.v L2cache1.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+noHazard +access+r
ncverilog Final_tb.v slow_memory.v ALU.v cacheD.v cacheI.v CHIP.v Control.v Forward.v HazardDetect.v L2cache1.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+hasHazard +access+r
ncverilog Final_tb.v slow_memory.v ALU.v cacheD.v cacheI.v CHIP.v Control.v Forward.v HazardDetect.v L2cache1.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+L2Cache +access+r
cd ../../..

cd Src/L2Cache/syn
ln -sf "$WORK_DIR/../Final_tb.v" .
ln -sf "$WORK_DIR/../Test"* .
ln -sf "$WORK_DIR/../D_mem" .
ln -sf "$WORK_DIR/../I_mem"* .
ln -sf "$WORK_DIR/../slow_memory.v" .
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
sed -i 's/^`define CYCLE.*$/`define CYCLE 2.73/' Final_tb.v
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+noHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+L2Cache +define+SDF +access+r
cd ../../..

cd Src/BrPred/rtl 
ln -sf "$WORK_DIR/../Final_tb.v" . 
ln -sf "$WORK_DIR/../Test"* . 
ln -sf "$WORK_DIR/../D_mem" . 
ln -sf "$WORK_DIR/../I_mem"* . 
ln -sf "$WORK_DIR/../slow_memory.v" . 
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
ncverilog Final_tb.v slow_memory.v ALU.v BrPred_BTB.v cache_controller.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+noHazard +access+r
ncverilog Final_tb.v slow_memory.v ALU.v BrPred_BTB.v cache_controller.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+hasHazard +access+r 
ncverilog Final_tb.v slow_memory.v ALU.v BrPred_BTB.v cache_controller.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+BrPred +access+r
cd ../../..

cd Src/BrPred/syn 
ln -sf "$WORK_DIR/../Final_tb.v" . 
ln -sf "$WORK_DIR/../Test"* . 
ln -sf "$WORK_DIR/../D_mem" . 
ln -sf "$WORK_DIR/../I_mem"* . 
ln -sf "$WORK_DIR/../slow_memory.v" . 
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
sed -i 's/^`define CYCLE.*$/`define CYCLE 2.81/' Final_tb.v 
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+noHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r 
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+BrPred +define+SDF +access+r
cd ../../..

cd Src/MultDiv/rtl
ln -sf "$WORK_DIR/../Final_tb.v" .
ln -sf "$WORK_DIR/../Test"* .
ln -sf "$WORK_DIR/../D_mem" .
ln -sf "$WORK_DIR/../I_mem"* .
ln -sf "$WORK_DIR/../slow_memory.v" .
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
ncverilog Final_tb.v slow_memory.v ALU.v MultDiv_booth.v cache_controller.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+noHazard +define+booth +access+r
ncverilog Final_tb.v slow_memory.v ALU.v MultDiv_booth.v cache_controller.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+hasHazard +define+booth +access+r
ncverilog Final_tb.v slow_memory.v ALU.v MultDiv_booth.v cache_controller.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+MultDiv +define+booth +access+r
cd ../../..

cd Src/MultDiv/syn/normal
ln -sf "$WORK_DIR/../Final_tb.v" .
ln -sf "$WORK_DIR/../Test"* .
ln -sf "$WORK_DIR/../D_mem" .
ln -sf "$WORK_DIR/../I_mem"* .
ln -sf "$WORK_DIR/../slow_memory.v" .
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
sed -i 's/^`define CYCLE.*$/`define CYCLE 3.71/' Final_tb.v
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+noHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+MultDiv +define+SDF +access+r
cd ../../../..

cd Src/MultDiv/syn/booth_nonopt
ln -sf "$WORK_DIR/../Final_tb.v" .
ln -sf "$WORK_DIR/../Test"* .
ln -sf "$WORK_DIR/../D_mem" .
ln -sf "$WORK_DIR/../I_mem"* .
ln -sf "$WORK_DIR/../slow_memory.v" .
ln -sf "/home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v" .
sed -i 's/^`define CYCLE.*$/`define CYCLE 3.71/' Final_tb.v
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+noHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+MultDiv +define+SDF +access+r
cd ../../../..
