module ast_chk(
	clk		,
	rst_n	,
	rxd		,
	rxd_v	,
	txd		,
	tx_en	,
	reg_value
);
	input	wire		clk			;
	input	wire		rst_n		;
	input	wire[7:0]	rxd			;
	input	wire		rxd_v		;
	input	wire[7:0]	txd			;
	input	wire		tx_en		;
	input	wire[63:0]	reg_value	;

	ast_test01:assert property(
			@(posedge clk) rxd_v ##1 tx_en
	);

endmodule


bind dut ast_chk m_ast_chk(
	clk		,
	rst_n	,
	rxd		,
	rxd_v	,
	txd		,
	tx_en	,
	reg_value
);
