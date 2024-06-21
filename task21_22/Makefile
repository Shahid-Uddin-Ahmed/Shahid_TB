FILES += demux_1_to_4.sv
FILES += demux_1_to_4_tb.sv
TOP	  += demux_1_to_4_tb

vivado: clean
	xvlog -sv ${FILES} 
	xelab ${TOP} -s top
	xsim top -runall

clean:
	@rm -rf top.wdb xsim.dir *.log *.pb *.jou *.vcd

.PHONY: vivado clean
	
