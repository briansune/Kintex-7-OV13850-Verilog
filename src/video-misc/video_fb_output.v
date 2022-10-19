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

module video_fb_output#(
	//total visible and blanking pixels per line
	parameter video_hlength = 2200,
	//total visible and blanking lines per frame
	parameter video_vlength = 1125,
	//hsync polarity: true for positive sync, false for negative sync (does not affect framebuffer outputs)
	parameter video_hsync_pol = 1'b1,
	parameter video_hsync_len = 44, //horizontal sync length in pixels
	parameter video_hbp_len = 88, //horizontal back porch length (excluding sync)
	parameter video_h_visible = 1920, //number of visible pixels per line
	//vsync polarity: true for positive sync, false for negative sync
	parameter video_vsync_pol = 1'b1,
	parameter video_vsync_len = 5, //vertical sync length in lines
	parameter video_vbp_len = 4, //vertical back porch length (excluding sync)
	parameter video_v_visible = 1080, //number of visible lines per frame
	parameter rst_act_low = 1'b0
)(
	input wire			pixel_clock,
	//active high async reset
	input wire			reset,
	//Framebuffer controller interface
	output wire			fbc_vsync,
	input wire	[23:0]	fbc_data,
	//Output port timing signals
	//line_start is like hsync but always active high and only asserted for visible lines and for 1 clock cycle
	output wire 		video_vsync,
	output wire 		video_hsync,
	output wire			video_den,
	output wire			video_line_start,
	//Pixel output port
	output wire	[23:0]	video_data
);
	
	wire	[$clog2(video_vlength) - 1 : 0]	timing_v_pos;
	wire	[$clog2(video_hlength) - 1 : 0]	timing_h_pos;
	wire	den_int;
	
	assign fbc_vsync = (timing_v_pos == {$clog2(video_vlength){1'b0}}) ? 1'b1 : 1'b0;
	assign video_data = (den_int) ? fbc_data : 24'h000000;
	assign video_den = den_int;
	
	video_timing_ctrl#(
		.video_hlength		(video_hlength),
		.video_vlength		(video_vlength),
		.video_hsync_pol	(video_hsync_pol),
		.video_hsync_len	(video_hsync_len),
		.video_hbp_len		(video_hbp_len),
		.video_h_visible	(video_h_visible),
		.video_vsync_pol	(video_vsync_pol),
		.video_vsync_len	(video_vsync_len),
		.video_vbp_len		(video_vbp_len),
		.video_v_visible	(video_v_visible)
	)tmg_gen(
		.pixel_clock		(pixel_clock),
		.reset				(rst_act_low ^ reset),
		.ext_sync			(1'b0),
		.timing_h_pos		(timing_h_pos),
		.timing_v_pos		(timing_v_pos),
		.pixel_x			(),
		.pixel_y			(),
		.video_vsync		(video_vsync),
		.video_hsync		(video_hsync),
		.video_den			(den_int),
		.video_line_start	(video_line_start)
	);
	
endmodule
