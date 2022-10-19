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

module video_timing_ctrl#(
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
	parameter sync_v_pos = 132,
	parameter sync_h_pos = 1079
)(
	input wire		pixel_clock,
	//active high async reset
    input wire		reset,
    //External sync input
    input wire		ext_sync,

    //Timing and pixel coordinate outputs
    output wire	[$clog2(video_hlength) - 1 : 0]		timing_h_pos,
    output wire	[$clog2(video_vlength) - 1 : 0]		timing_v_pos,
    output wire	[$clog2(video_h_visible) - 1 : 0]	pixel_x,
    output wire	[$clog2(video_v_visible) - 1 : 0]	pixel_y,

    //Traditional timing signals
    //line_start is like hsync but always active high and only asserted for visible lines and for 1 clock cycle
    output wire		video_vsync,
    output wire		video_hsync,
    output wire		video_den,
    output wire		video_line_start
);
	
	localparam t_hsync_end = video_hsync_len - 1;
	localparam t_hvis_begin = video_hsync_len + video_hbp_len;
	localparam t_hvis_end = t_hvis_begin + video_h_visible - 1;
	localparam t_vsync_end = video_vsync_len - 1;
	localparam t_vvis_begin = video_vsync_len + video_vbp_len;
	localparam t_vvis_end = t_vvis_begin + video_v_visible - 1;
	
	reg	[$clog2(video_hlength) - 1 : 0] h_pos;
	reg	[$clog2(video_vlength) - 1 : 0] v_pos;

	wire	[$clog2(video_h_visible) - 1 : 0]	x_int;
	wire	[$clog2(video_v_visible) - 1 : 0]	y_int;

	wire h_visible, v_visible;
	wire hsync_pos, vsync_pos;
	reg ext_sync_last;
	reg ext_sync_curr;
	
	always@(posedge pixel_clock)begin
		ext_sync_curr <= ext_sync;
		ext_sync_last <= ext_sync_curr;
	end
	
	always@(posedge pixel_clock or posedge reset)begin
		if(reset)begin
			h_pos <= {$clog2(video_hlength){1'b0}};
			v_pos <= {$clog2(video_vlength){1'b0}};
		end else begin
			if(ext_sync_curr & !ext_sync_last)begin
				h_pos <= sync_h_pos;
				v_pos <= sync_v_pos;
			end else begin
				if(h_pos == video_hlength - 1)begin
					h_pos <= {$clog2(video_hlength){1'b0}};
					if(v_pos == video_vlength - 1)begin
						v_pos <= {$clog2(video_vlength){1'b0}};
					end else begin
						v_pos <= v_pos + 1'b1;
					end
				end else begin
					h_pos <= h_pos + 1'b1;
				end
			end
		end
	end
	
	//Visible signals
	assign v_visible = (v_pos >= t_vvis_begin) & (v_pos <= t_vvis_end) ? 1'b1 : 1'b0;
	assign h_visible = (h_pos >= t_hvis_begin) & (h_pos <= t_hvis_end) ? 1'b1 : 1'b0;

	//Pixel coordinates
	assign x_int = (h_visible & v_visible) ? (h_pos - t_hvis_begin) : {$clog2(video_h_visible){1'b0}};
	assign y_int = v_visible ? (v_pos - t_vvis_begin) : {$clog2(video_v_visible){1'b0}};
	//den and line_start signals
	assign video_den = h_visible & v_visible;
	assign video_line_start = v_visible & (h_pos == {$clog2(video_hlength){1'b0}}) ? 1'b1 : 1'b0;
	//Sync signals
	assign vsync_pos = (v_pos <= t_vsync_end) ? 1'b1 : 1'b0;
	assign hsync_pos = (h_pos <= t_hsync_end) ? 1'b1 : 1'b0;
	assign video_vsync = (!video_vsync_pol) ^ vsync_pos;
	assign video_hsync = (!video_hsync_pol) ^ hsync_pos;
	//External outputs
	assign timing_h_pos = h_pos;
	assign timing_v_pos = v_pos;
	assign pixel_x = x_int;
	assign pixel_y = y_int;
  
endmodule
