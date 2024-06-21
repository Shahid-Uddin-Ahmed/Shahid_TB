FILES += encoder_8_to_3.sv
FILES += encoder_8_to_3_tb.sv
TOP	  += encoder_8_to_3_tb

vivado: clean
	xvlog -sv ${FILES} 
	xelab ${TOP} -s top
	xsim top -runall

clean:
	@rm -rf top.wdb xsim.dir *.log *.pb *.jou *.vcd

.PHONY: vivado clean

