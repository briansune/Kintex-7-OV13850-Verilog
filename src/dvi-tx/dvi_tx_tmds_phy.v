module dvi_tx_tmds_phy(
	
	input				pixel_clock,
	input				ddr_bit_clock,
	input				reset,
	input	[9 : 0]		data,
	output	[1 : 0]		tmds_lane
);
	
	reg reset_reg;
	
	wire cas_shift_1;
	wire cas_shift_2;
	
	wire dq_tmds;
	
	always@(posedge pixel_clock)begin
		if(reset)begin
			reset_reg <= 1'b1;
		end else begin
			reset_reg <= 1'b0;
		end
	end
	
	OSERDESE2 #(
		.DATA_RATE_OQ		("DDR"),
		.DATA_RATE_TQ		("SDR"),
		.DATA_WIDTH			(10),
		.INIT_OQ			(1'b0),
		.INIT_TQ			(1'b0),
		.SERDES_MODE		("MASTER"),
		.SRVAL_OQ			(1'b0),
		.SRVAL_TQ			(1'b0),
		.TBYTE_CTL			("FALSE"),
		.TBYTE_SRC			("FALSE"),
		.TRISTATE_WIDTH		(1)
	)master_oserdes(
		
		.CLK		(ddr_bit_clock),
		.CLKDIV		(pixel_clock),
		.RST		(reset_reg),
		
		.OFB		(),
		.TFB		(),
		.TQ			(),
		
		.OCE		(1),
		.D1			(data[0]),
		.D2			(data[1]),
		.D3			(data[2]),
		.D4			(data[3]),
		.D5			(data[4]),
		.D6			(data[5]),
		.D7			(data[6]),
		.D8			(data[7]),
		.OQ			(dq_tmds),
		
		.SHIFTIN1	(cas_shift_1),
		.SHIFTIN2	(cas_shift_2),
		.SHIFTOUT1	(),
		.SHIFTOUT2	(),
		
		.TCE		(1),
		.T1			(0),
		.T2			(0),
		.T3			(0),
		.T4			(0),
		.TBYTEIN	(0),
		.TBYTEOUT	()
	);
	
	OSERDESE2 #(
		.DATA_RATE_OQ		("DDR"),
		.DATA_RATE_TQ		("SDR"),
		.DATA_WIDTH			(10),
		.INIT_OQ			(1'b0),
		.INIT_TQ			(1'b0),
		.SERDES_MODE		("SLAVE"),
		.SRVAL_OQ			(1'b0),
		.SRVAL_TQ			(1'b0),
		.TBYTE_CTL			("FALSE"),
		.TBYTE_SRC			("FALSE"),
		.TRISTATE_WIDTH		(1)
	)slave_oserdes(
		
		.CLK		(ddr_bit_clock),
		.CLKDIV		(pixel_clock),
		.RST		(reset_reg),
		
		.OFB		(),
		.TFB		(),
		.TQ			(),
		
		.OCE		(1),
		.D1			(0),
		.D2			(0),
		.D3			(data[8]),
		.D4			(data[9]),
		.D5			(0),
		.D6			(0),
		.D7			(0),
		.D8			(0),
		.OQ			(),
		
		.SHIFTIN1	(0),
		.SHIFTIN2	(0),
		.SHIFTOUT1	(cas_shift_1),
		.SHIFTOUT2	(cas_shift_2),
		
		.TCE		(1),
		.T1			(0),
		.T2			(0),
		.T3			(0),
		.T4			(0),
		.TBYTEIN	(0),
		.TBYTEOUT	()
	);
	
	OBUFDS #(
		.IOSTANDARD	("DEFAULT"),
		.SLEW		("FAST")
	)OBUFDS_inst0(
		.I		(dq_tmds),
		.O		(tmds_lane[1]),
		.OB		(tmds_lane[0])
	);
	
endmodule
