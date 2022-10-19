// ==================================================
//  ____         _                ____                      
// | __ )  _ __ (_)  __ _  _ __  / ___|  _   _  _ __    ___ 
// |  _ \ | '__|| | / _` || '_ \ \___ \ | | | || '_ \  / _ \
// | |_) || |   | || (_| || | | | ___) || |_| || | | ||  __/
// |____/ |_|   |_| \__,_||_| |_||____/  \__,_||_| |_| \___|
//                                                          
// ==================================================
// Programed By: BrianSune
// Contact: briansune@gmail.com
// ==================================================

`timescale 1ns / 1ps

module dvi_tx_clk_drv(
	
	input				pixel_clock,
	output	[1 : 0]		tmds_clk
);
	
	wire tmds_clk_pre;
	
	ODDR #(
		.DDR_CLK_EDGE("OPPOSITE_EDGE"),
		.INIT(1'b0),
		.SRTYPE("SYNC")
	) ODDR_inst (
		.Q	(tmds_clk_pre),
		.C	(pixel_clock),
		.CE	(1),
		.D1	(1),
		.D2	(0),
		.R	(0),
		.S	(0)
	);
	
	OBUFDS #(
		.IOSTANDARD("DEFAULT"),
		.SLEW("FAST")
	)OBUFDS_hdmi_clk(
		.I		(tmds_clk_pre),
		.O		(tmds_clk[1]),
		.OB		(tmds_clk[0])
	);
	
endmodule
