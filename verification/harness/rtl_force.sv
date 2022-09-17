`ifndef __RTL_FORCE__
`define __RTL_FORCE__
initial begin
	if($test$plusargs("force_rtl"))begin
		#1000 force top_tb.my_dut.reg_value = 64'b0;
		#2000 release top_tb.my_dut.reg_value;
	end
end
`endif

