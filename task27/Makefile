FILES += synchronous_fifo.sv
FILES += synchronous_fifo_tb.sv
TOP	  += synchronous_fifo_tb

vivado: clean
	xvlog -sv ${FILES} 
	xelab ${TOP} -s top
	xsim top -runall

clean:
	@rm -rf *.wdb xsim.dir *.log *.pb *.jou *.vcd

.PHONY: vivado clean
