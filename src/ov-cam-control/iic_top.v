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

module iic_top#(
	parameter complete_polarity = 1'b1,
	parameter rst_out_polarity = 1'b1,
	parameter use_rst_out = 1'b1
)(
	input wire		clock,
	input wire		reset,
	output wire		rst_out,
	output wire		init_complete,
	inout			i2c_sda,
	inout			i2c_sck
);
	
	localparam [17:0] state_end = 262000;
	
	reg			i2c_start, i2c_en;
	reg	[8:0]	cmd_addr;
	reg	[17:0]	statecntr;
	reg	[17:0]	statecntr_sub;
	
	wire	[23:0]	current_cmd;
	
	initial begin
		statecntr <= 18'd0;
	end
	
	iic_ctrl #(
		.slave_addr		(7'h10)
	)iic_ctrl_inst0(
		.clock_in		(clock),
		.data_in		(current_cmd),
		.enable			(i2c_en),
		.start_xfer		(i2c_start),
		.xfer_done		(i2c_done),
		.i2c_sck		(i2c_sck),
		.i2c_sda		(i2c_sda)
	);
	
	ov13850_4k_regs regs(
		.clock		(clock),
		.address	(cmd_addr),
		.data		(current_cmd)
	);
	
	wire state_over = (statecntr < state_end) ? 1'b1 : 1'b0;
	assign init_complete = complete_polarity ^ state_over;
	
	always@(posedge clock or posedge reset)begin
		if(reset)begin
			statecntr <= 0;
		end else begin
			statecntr <= statecntr + state_over;
		end
	end
	
	wire state_over2 = (statecntr < 16384) ? 1'b0 : 1'b1;
	
	generate
		if(use_rst_out)begin : has_rst
			assign rst_out = (!rst_out_polarity) ^ state_over2;
		end else begin: no_rst
			assign rst_out = (!rst_out_polarity) ^ 1'b1;
		end
	endgenerate
	
	always@(*)begin
		if(statecntr < 32768)begin
			i2c_en = 1'b0;
			i2c_start = 1'b0;
			cmd_addr = 9'b0_0000_0000;
		end else begin
			statecntr_sub = statecntr - 32768;
			cmd_addr = statecntr_sub[17:9];
			
			if(current_cmd == 0)begin
				i2c_en = 1'b0;
			end else begin
				i2c_en = 1'b1;
			end
			
			if(current_cmd == 0)begin
				i2c_start = 1'b0;
			end else if(statecntr_sub[8:2] == 1 || statecntr_sub[8:2] == 2)begin
				i2c_start = 1'b1;
			end else begin
				i2c_start = 1'b0;
			end
		end
	end
	
endmodule
