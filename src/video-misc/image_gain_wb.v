module image_gain_wb#(
	parameter red_gain = 10,
	parameter green_gain = 7,
	parameter blue_gain = 9
)(
	input wire			clock,
    input wire			input_vsync,
    input wire			input_hsync,
    input wire			input_den,
    input wire			input_line_start,
    input wire	[29:0]	input_data_even,
    input wire	[29:0]	input_data_odd,
	
    output reg			output_vsync,
    output reg			output_hsync,
    output reg			output_den,
    output reg			output_line_start,
    output reg	[23:0]	output_data_even,
    output reg	[23:0]	output_data_odd
);
	
	function automatic [10:0] channel_mul;
		input [9:0] ch;
		input [3:0] gain;
		
		reg [9:0] chvalue;
		reg [3:0] gvalue;
		reg [13:0] mul;
		begin
			chvalue = ch;
			gvalue = gain;
			mul = chvalue * gvalue;
			channel_mul = mul[13:3];
		end
	endfunction
	
	function automatic [7:0] clamp_to_8bit;
		input [10:0] inp;
		begin
			clamp_to_8bit = (inp > 11'd1023) ? 8'd255 : inp[9:2];
		end
	endfunction
	
	always@(posedge clock)begin
		output_vsync <= input_vsync;
		output_hsync <= input_hsync;
		output_den <= input_den;
		output_line_start <= input_line_start;
		
		output_data_even[7:0] <= clamp_to_8bit(channel_mul(input_data_even[9:0], blue_gain));
		output_data_even[15:8] <= clamp_to_8bit(channel_mul(input_data_even[19:10], green_gain));
		output_data_even[23:16] <= clamp_to_8bit(channel_mul(input_data_even[29:20], red_gain));
		
		output_data_odd[7:0] <= clamp_to_8bit(channel_mul(input_data_odd[9:0], blue_gain));
		output_data_odd[15:8] <= clamp_to_8bit(channel_mul(input_data_odd[19:10], green_gain));
		output_data_odd[23:16] <= clamp_to_8bit(channel_mul(input_data_odd[29:20], red_gain));
	end
	
endmodule
