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
	parameter sys_freq = 145000000,
	parameter iic_freq = 156250,
	parameter init_done_polarity = 1'b1,
	parameter rst_out_polarity = 1'b1,
	parameter power_polarity = 1'b0,
	parameter cam_power_on = 1'b1
)(
	input wire		clock,
	input wire		reset,
	output reg		rst_out,
	output wire		init_done,
	
	output wire		cam_pwdn,
	output wire		cam_nrst,
	inout			cam_i2c_sda,
	inout			cam_i2c_sck
);
	
	localparam [17:0] state_end = 18'd262000;
	
	localparam cnt_num = (sys_freq / iic_freq / 2) - 1;
	localparam [11:0] cnt_fx = cnt_num;
	
	reg	[11:0]	clk_cnt;
	reg			clk_en;
	
	always@(posedge clock)begin
		if(reset)begin
			clk_cnt <= 12'd0;
			clk_en <= 1'b0;
		end else begin
			if(clk_cnt >= cnt_fx)begin
				clk_cnt <= 12'd0;
				clk_en <= 1'b1;
			end else begin
				clk_cnt <= clk_cnt + 1;
				clk_en <= 1'b0;
			end
		end
	end
	
	reg			i2c_start, i2c_en;
	reg	[8:0]	cmd_addr;
	reg	[17:0]	statecntr;
	
	wire	[23:0]	current_cmd;
	
	iic_ctrl #(
		.slave_addr		(7'b0010_000)
	)iic_ctrl_inst0(
		.clock_in		(clock),
		.clock_en		(clk_en),
		.data_in		(current_cmd),
		.enable			(i2c_en),
		.start_xfer		(i2c_start),
		.xfer_done		(i2c_done),
		.i2c_sck		(cam_i2c_sck),
		.i2c_sda		(cam_i2c_sda)
	);
	
	ov13850_4k_regs regs(
		.clock		(clock),
		.clock_en	(clk_en),
		.address	(cmd_addr),
		.data		(current_cmd)
	);
	
	assign init_done = ((statecntr < state_end) ? 1'b1 : 1'b0) ^ init_done_polarity;
	
	always@(posedge clock)begin
		if(reset)begin
			statecntr <= 18'd0;
		end else if(clk_en)begin
			if(statecntr < state_end)begin
				statecntr <= statecntr + 1;
			end
		end
	end
	
	assign cam_nrst = ~rst_out;
	assign cam_pwdn = cam_power_on ^ (!power_polarity);
	
	always@(*)begin
		if(statecntr < 18'd16384)begin
			rst_out = 1'b0 ^ rst_out_polarity;
		end else begin
			rst_out = 1'b1 ^ rst_out_polarity;
		end
	end
	
	wire	[17:0]	statecntr_sub;
	assign statecntr_sub = statecntr - 18'd32768;
	
	always@(*)begin
		if(statecntr < 18'd32768)begin
			i2c_en = 1'b0;
			i2c_start = 1'b0;
			cmd_addr = 9'b0_0000_0000;
		end else begin
			cmd_addr = statecntr_sub[17:9];
			
			if(current_cmd == 0)begin
				i2c_start = 1'b0;
				i2c_en = 1'b0;
			end else begin
				i2c_en = 1'b1;
				
				if(statecntr_sub[8:2] == 1 || statecntr_sub[8:2] == 2)begin
					i2c_start = 1'b1;
				end else begin
					i2c_start = 1'b0;
				end
			end
		end
	end
	
endmodule
