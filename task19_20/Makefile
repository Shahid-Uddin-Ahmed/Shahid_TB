FILES += bin_to_gray.sv
FILES += bin_to_gray_tb.sv
TOP	  += bin_to_gray_tb

vivado: clean
	xvlog -sv ${FILES} 
	xelab ${TOP} -s top
	xsim top -runall

clean:
	@rm -rf top.wdb xsim.dir *.log *.pb *.jou *.vcd

.PHONY: vivado clean
	
