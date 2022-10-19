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

module simple_debayer(
	input wire			clock,
	input wire			input_hsync,
	input wire			input_vsync,
	input wire			input_den,
	input wire			input_line_start,
	input wire			input_odd_line,
	input wire	[19:0]	input_data,
	input wire	[19:0]	input_prev_line_data,
	
	output reg			output_hsync,
	output reg			output_vsync,
	output reg			output_den,
	output reg			output_line_start,
	// 10bit R:G:B
	output reg	[29:0]	output_data_even,
	// 10bit R:G:B
	output reg	[29:0]	output_data_odd
);
	
	reg	[19:0]	last_block_c, last_block_p;
	reg			pre_hsync, pre_vsync, pre_den, pre_line_start;
	reg	[29:0]	pre_data_even, pre_data_odd;
	
	function automatic [9:0] channel_average;
		input [9:0] val_1, val_2;
		reg	[10:0]	sum;
		begin
			sum = val_1 + val_2;
			channel_average = sum[10:1];
		end
	endfunction
	
	reg	[9:0] pixel_0_R, pixel_0_G, pixel_0_B;
    reg	[9:0] pixel_1_R, pixel_1_G, pixel_1_B;
	
	always@(*)begin
		if(input_odd_line)begin
			pixel_0_R = channel_average(input_data[19:10], last_block_c[19 : 10]);
			pixel_0_G = input_data[9 : 0];
			pixel_0_B = input_prev_line_data[9 : 0];
			pixel_1_R = input_data[19 : 10];
			pixel_1_G = channel_average(input_data[9 : 0], last_block_p[19 : 10]);
			pixel_1_B = input_prev_line_data[9 : 0];
		end else begin
			pixel_0_R = channel_average(input_prev_line_data[19 : 10], last_block_p[19 : 10]);
			pixel_0_G = channel_average(input_data[19 : 10], last_block_c[19 : 10]);
			pixel_0_B = input_data[9 : 0];
			pixel_1_R = input_prev_line_data[19 : 10];
			pixel_1_G = input_data[19 : 10];
			pixel_1_B = input_data[9 : 0];
		end
	end
	
	always@(posedge clock)begin
		pre_hsync <= input_hsync;
		pre_vsync <= input_vsync;
		pre_den <= input_den;
		pre_line_start <= input_line_start;
		
		pre_data_even <= {pixel_0_R, pixel_0_G, pixel_0_B};
		pre_data_odd <= {pixel_1_R, pixel_1_G, pixel_1_B};
		
		output_hsync <= pre_hsync;
		output_vsync <= pre_vsync;
		output_den <= pre_den;
		output_line_start <= pre_line_start;
		output_data_even <= pre_data_even;
		output_data_odd <= pre_data_odd;
		
		if(input_den)begin
			last_block_c <= input_data;
			last_block_p <= input_prev_line_data;
		end
	end
	
endmodule
