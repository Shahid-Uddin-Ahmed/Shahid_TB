MODULE += mealy_o_1010.sv
MODULE += mealy_o_1010_tb.sv

TOP += mealy_o_1010_tb

vivado: clean
	xvlog -sv ${MODULE} 
	xelab ${TOP} -s top 
	xsim top -runall

clean: 
	rm -rf xsim.dir *.vcd *.wdb *.log *.pb *.jou *.vdc 

PHONY:	vivado clean
