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

module dvi_tx_top(
	
	input				pixel_clock,
	input				ddr_bit_clock,
	input				reset,
	
	input				den,
	input				hsync,
	input				vsync,
	input	[23 : 0]	pixel_data,
	
	output	[1 : 0]		tmds_clk,
	output	[1 : 0]		tmds_d0,
	output	[1 : 0]		tmds_d1,
	output	[1 : 0]		tmds_d2
);
	
	wire	[5 : 0]		ctrl;
	wire	[29 : 0]	tmds_enc;
	
	wire	[1 : 0]		data_out_to_pins [2 : 0];
	
	assign ctrl[0] = hsync;
	assign ctrl[1] = vsync;
	assign ctrl[5 : 2] = 4'b0000;
	
	assign tmds_d0 = data_out_to_pins[0];
	assign tmds_d1 = data_out_to_pins[1];
	assign tmds_d2 = data_out_to_pins[2];
	
	generate
		
		genvar i;
		
		for(i = 0; i < 3; i = i + 1)begin : gen_enc
			
			dvi_tx_tmds_enc dvi_tx_tmds_enc_inst(
				
				.clock		(pixel_clock),
				.reset		(reset),
				
				.den		(den),
				.data		(pixel_data[(8*i) +: 8]),
				.ctrl		(ctrl[(2*i) +: 2]),
				.tmds		(tmds_enc[(10*i) +: 10])
			);
			
			dvi_tx_tmds_phy dvi_tx_tmds_phy_inst(
				
				.pixel_clock		(pixel_clock),
				.ddr_bit_clock		(ddr_bit_clock),
				.reset				(reset),
				.data				(tmds_enc[(10*i) +: 10]),
				.tmds_lane			(data_out_to_pins[i])
			);
		end
		
	endgenerate
	
	dvi_tx_clk_drv clock_phy(
		
		.pixel_clock	(pixel_clock),
		.tmds_clk		(tmds_clk)
	);
	
endmodule
