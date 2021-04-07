Update: 2020/04/06
This testbench supports MIPS, RTL, and SYN

Source:
    >	source /usr/cad/cadence/cshrc
    >	source /usr/cad/synopsys/CIC/verdi.cshrc
    >	source /usr/cad/synopsys/CIC/synthesis.cshrc

RTL simulation:
    >	ncverilog MIPS_tb.v +define+RTL +access+r

--------------------------------------------------------------------------
Files for synthesis:
- .synopsys_dc.setup
- CHIP_syn.sdc

Synthesis command:
- Open Design Compiler:
    > dv -no_gui
- In Design Compiler:
    design_vision> read_verilog CHIP.v
    design_vision> source CHIP_syn.sdc
    
- Check if your design passes timing slack:
    design_vision> report_timing
- Check area:
    design_vision> report_area
    
- To reopen the design:
    design_vision> read_ddc CHIP_syn.ddc
- Close Design Compiler:
    design_vision> exit

--------------------------------------------------------------------------
Post-synthesis simulation:
- Check if you have a SDF file (CHIP_syn.sdf)
- Check if you have a library file (tsmc13.v)
- Note: To copy tsmc13.v to your current directory:
    >	cp /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v .

    >	ncverilog MIPS_tb.v +define+SYN +access+r

--------------------------------------------------------------------------
Pattern generation:
- Open the python script in ./pattern/pattern_gen.py
- Change the variables in the script
- Run the script, and there will be two new files:
	data.txt
	ans.txt