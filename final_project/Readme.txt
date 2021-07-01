Baseline RTL:
ncverilog Final_tb.v CHIP.v cache_controller.v cache_sram_2way.v MIPS_Pipeline.v PC.v Control.v RegFile.v Forward.v HazardDetect.v ALU.v StallControl.v slow_memory.v +define+noHazard +access+r
ncverilog Final_tb.v CHIP.v cache_controller.v cache_sram_2way.v MIPS_Pipeline.v PC.v Control.v RegFile.v Forward.v HazardDetect.v ALU.v StallControl.v slow_memory.v +define+hasHazard +access+r

Baseline gate-level: (tb cycle = 2.8)
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+noHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r




L2Cache RTL:
ncverilog Final_tb.v slow_memory.v ALU.v cacheD.v cacheI.v CHIP.v Control.v Forward.v HazardDetect.v L2cache1.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+noHazard +access+r
ncverilog Final_tb.v slow_memory.v ALU.v cacheD.v cacheI.v CHIP.v Control.v Forward.v HazardDetect.v L2cache1.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+hasHazard +access+r
ncverilog Final_tb.v slow_memory.v ALU.v cacheD.v cacheI.v CHIP.v Control.v Forward.v HazardDetect.v L2cache1.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+L2Cache +access+r

L2Cache gate-level: (tb cycle = 2.73)
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+noHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+L2Cache +define+SDF +access+r




Branch predictor RTL:
ncverilog Final_tb.v slow_memory.v ALU.v BrPred_BTB.v cache_sram_2way.v cache_controller.v BrPred_local_2bit.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+BrPred +access+r

Branch predictor gate-level: (tb cycle = 2.81)
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+BrPred +define+SDF +access+r




MultDiv RTL:
ncverilog Final_tb.v slow_memory.v ALU.v MultDiv_booth.v cache_controller.v CHIP.v Control.v Forward.v HazardDetect.v MIPS_Pipeline.v PC.v RegFile.v StallControl.v +define+MultDiv +define+booth +access+r

MultDiv gate-level: (tb cycle = 3.71)
ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+MultDiv +define+SDF +access+r
