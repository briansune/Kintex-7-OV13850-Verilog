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

module framebuffer_ctrl_ext#(
	parameter [7:0] burst_len = 16,
	parameter input_width = 3840, //Pixel size of input video
	parameter input_height = 2160,
	parameter output_width = 1920, //Pixel size of output video
	parameter output_height = 1080,
	parameter crop_xoffset = 1024, //X/Y offset in crop mode (chosen to avoid bursts crossing a 4k boundary)
	parameter crop_yoffset = 540,
	parameter scale_xoffset = 0, //X/Y offset in scale mode (not used, for future purposes only)
	parameter scale_yoffset = 0
)(
	input wire			input_clock,
    input wire			input_vsync,
    input wire			input_line_start,
    input wire			input_den,
    input wire	[23:0]	input_data_even,
    input wire	[23:0]	input_data_odd,
	
    //Output pixel port
    input wire			output_clock,
    input wire			output_vsync,
    input wire			output_line_start,
    input wire			output_den,
    output reg	[23:0]	output_data,
	
	//AXI4 master general
	(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axi_clock CLK" *)
	(* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF maxi_fb, ASSOCIATED_RESET axi_resetn, FREQ_HZ 200000000" *)
    input wire					axi_clock,
	(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axi_resetn RST" *)
	(* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input wire					axi_resetn,
	
	// =====================================================================
    //AXI4 write address
	// =====================================================================
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWID" *)
	(* X_INTERFACE_PARAMETER = "CLK_DOMAIN axi_clock,FREQ_HZ 200000000,ID_WIDTH 1,NUM_WRITE_OUTSTANDING 8,NUM_READ_OUTSTANDING 8,SUPPORTS_NARROW_BURST 0" *)
	output wire		[0 : 0]		axi_awid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWADDR" *)
    output wire		[28 : 0]	axi_awaddr,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWLEN" *)
    output wire		[7 : 0]		axi_awlen,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWSIZE" *)
    output wire		[2 : 0]		axi_awsize,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWBURST" *)
    output wire		[1 : 0]		axi_awburst,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWLOCK" *)
    output wire		[0 : 0]		axi_awlock,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWCACHE" *)
    output wire		[3 : 0]		axi_awcache,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWPROT" *)
    output wire		[2 : 0]		axi_awprot,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWQOS" *)
    output wire		[3 : 0]		axi_awqos,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWVALID" *)
    output wire					axi_awvalid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb AWREADY" *)
    input wire					axi_awready,
	// =====================================================================
    //AXI4 write datapath
	// =====================================================================
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb WDATA" *)
    output wire		[255 : 0]	axi_wdata,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb WSTRB" *)
    output wire		[31 : 0]	axi_wstrb,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb WLAST" *)
    output wire					axi_wlast,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb WVALID" *)
    output wire					axi_wvalid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb WREADY" *)
    input wire					axi_wready,
	// =====================================================================
    //AXI4 write response
	// =====================================================================
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb BID" *)
	input wire		[0 : 0]		axi_bid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb BRESP" *)
    input wire		[1 : 0]		axi_bresp,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb BVALID" *)
    input wire					axi_bvalid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb BREADY" *)
    output wire					axi_bready,
	
	// =====================================================================
    //AXI4 read address
	// =====================================================================
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARID" *)
    output wire		[0 : 0]		axi_arid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARADDR" *)
    output wire		[28 : 0]	axi_araddr,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARLEN" *)
    output wire		[7 : 0]		axi_arlen,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARSIZE" *)
    output wire		[2 : 0]		axi_arsize,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARBURST" *)
    output wire		[1 : 0]		axi_arburst,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARLOCK" *)
    output wire		[0 : 0]		axi_arlock,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARCACHE" *)
    output wire		[3 : 0]		axi_arcache,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARPROT" *)
    output wire		[2 : 0]		axi_arprot,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARQOS" *)
    output wire		[3 : 0]		axi_arqos,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARVALID" *)
    output wire					axi_arvalid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb ARREADY" *)
    input wire					axi_arready,
    //AXI4 read data
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb RID" *)
    input wire	[0 : 0]			axi_rid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb RDATA" *)
    input wire	[255 : 0]		axi_rdata,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb RRESP" *)
    input wire	[1 : 0]			axi_rresp,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb RLAST" *)
    input wire					axi_rlast,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb RVALID" *)
    input wire					axi_rvalid,
	(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 maxi_fb RREADY" *)
    output wire					axi_rready,
	
	//Misc
    input wire			zoom_mode, //0=scale, 1=crop
    input wire			freeze, //assert to disable writing
	
	(* X_INTERFACE_MODE = "Master" *)
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_a CLK" *)
	output wire					ilb_clka,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_a EN" *)
	output wire					ilb_ena,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_a WE" *)
	output wire					ilb_wea,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_a ADDR" *)
	output wire		[11:0]		ilb_addra,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_a DIN" *)
	output wire		[63:0]		ilb_dina,
	
	(* X_INTERFACE_MODE = "Master" *)
	(* X_INTERFACE_PARAMETER = "READ_WRITE_MODE READ_ONLY" *)
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_b CLK" *)
	output wire					ilb_clkb,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_b ADDR" *)
	output wire		[9:0]		ilb_addrb,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 lib_b DOUT" *)
	input wire		[255:0]		ilb_doutb,
	
	(* X_INTERFACE_MODE = "Master" *)
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_a CLK" *)
	output wire					olb_clka,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_a EN" *)
	output wire					olb_ena,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_a WE" *)
	output wire					olb_wea,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_a ADDR" *)
	output wire		[9:0]		olb_addra,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_a DIN" *)
	output wire		[255:0]		olb_dina,
	
	(* X_INTERFACE_MODE = "Master" *)
	(* X_INTERFACE_PARAMETER = "READ_WRITE_MODE READ_ONLY" *)
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_b CLK" *)
	output wire					olb_clkb,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_b ADDR" *)
	output wire		[11:0]		olb_addrb,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 olb_b DOUT" *)
	input wire		[63:0]		olb_doutb
);
	
	reg		[1 : 0]		read_state;
	reg		[2 : 0]		write_state;
	reg		[7 : 0]		write_count;
	
	reg		input_linebuf_read_high, input_linebuf_write_high;
	wire	cdc_input_linebuf_write_high;
	
	reg		output_linebuf_read_high, output_linebuf_write_high;
	wire	cdc_output_linebuf_read_high;

	reg		[11 : 0]	input_read_x, input_write_x, output_read_x, output_write_x;
	reg		[11 : 0]	input_read_y, input_write_y, output_read_y, output_write_y;
	
	wire	[11 : 0]	cdc_in_write_y, cdc_out_read_y;
	reg		[11 : 0]	input_write_y_curr, input_write_y_last, output_read_y_curr, output_read_y_last;

	wire	[11:0]		input_linebuf_write_addr;
	wire	[9:0]		input_linebuf_read_addr;
	wire	[9:0]		output_linebuf_write_addr;
	wire	[11:0]		output_linebuf_read_addr;
	
	wire	[63:0]		input_linebuf_din;
	wire				input_linebuf_wren;
	wire	[255:0]		input_linebuf_q;
	
	wire	[255:0]		output_linebuf_din;
	wire				output_linebuf_wren;
	wire	[63:0]		output_linebuf_q;
	
	wire	[23:0]		fb_read_address;
	wire	[23:0]		fb_write_address;
	
	wire	[11:0]		output_write_end_x;
	
	reg				axi_wready_last;
	reg				input_linebuf_ready;
	
	wire			global_reset;
	assign global_reset = ~axi_resetn;
	
	function automatic [23:0] rgb_average;
		input [23:0] pixel_1, pixel_2;
		reg		[23:0]	pixel_1_t, pixel_2_t;
		reg		[8:0]	sum0, sum1, sum2;
		begin
			pixel_1_t = pixel_1;
			pixel_2_t = pixel_2;
			
			sum0 = pixel_1_t[7:0] + pixel_2_t[7:0];
			sum1 = pixel_1_t[15:8] + pixel_2_t[15:8];
			sum2 = pixel_1_t[23:16] + pixel_2_t[23:16];
			
			rgb_average[7:0] = sum0[8:1];
			rgb_average[15:8] = sum1[8:1];
			rgb_average[23:16] = sum2[8:1];
		end
	endfunction
	
	assign input_linebuf_write_addr = {input_linebuf_write_high, input_write_x[11:1]};
	assign input_linebuf_read_addr = {input_linebuf_read_high, input_read_x[11:3]};
	assign output_linebuf_write_addr = {output_linebuf_write_high, output_write_x[11:3]};
	assign output_linebuf_read_addr = {output_linebuf_read_high, output_read_x[11:1]};
	
	assign fb_write_address = (input_read_y * input_width) + input_read_x;
	
	assign fb_read_address = zoom_mode ? 
		(((output_write_y + crop_yoffset) * input_width) + output_write_x + crop_xoffset) : 
		((output_write_y * input_width * 2) + output_write_x);
	
	assign output_write_end_x = zoom_mode ? output_width : (output_width * 2);
	
	// ####################################################################################
	always@(posedge input_clock)begin
		if(input_vsync)begin
			input_write_x <= 12'd0;
			input_write_y <= 12'd0;
			input_linebuf_write_high <= 1'b1;
		end else if(input_line_start)begin
			input_write_x <= 12'd0;
			input_linebuf_write_high <= ~input_linebuf_write_high;
			if(input_write_y == 12'd4095)begin
				input_write_y <= 12'd0;
			end else begin
				input_write_y <= input_write_y + 1;
			end
		end else if(input_den)begin
			input_write_x <= input_write_x + 2;
		end
	end
	// ####################################################################################
	
	
	// ####################################################################################
	always@(posedge output_clock)begin
		if(output_vsync)begin
			output_read_x <= 12'd0;
			output_read_y <= 12'd0;
			output_linebuf_read_high <= 1'b1;
		end else if(output_line_start)begin
			output_read_x <= 12'd0;
			output_linebuf_read_high <= ~output_linebuf_read_high;
			if(output_read_y == 12'd4095)begin
				output_read_y <= 12'd0;
			end else begin
				output_read_y <= output_read_y + 1;
			end
		end else if(output_den)begin
			if(!zoom_mode)begin
				output_read_x <= output_read_x + 2;
			end else begin
				output_read_x <= output_read_x + 1;
			end
		end
	end
	// ####################################################################################
	
	
	xpm_cdc_array_single#(
		.DEST_SYNC_FF(2),	// DECIMAL; range: 2-10
		.INIT_SYNC_FF(0),	// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
		.SIM_ASSERT_CHK(0),	// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
		.SRC_INPUT_REG(0),	// DECIMAL; 0=do not register input, 1=register input
		.WIDTH(12)
	)cdc_write_y_inst(
		.dest_out	(cdc_in_write_y),
		.dest_clk	(axi_clock),
		.src_clk	(input_clock),
		.src_in		(input_write_y)
	);
	
	xpm_cdc_array_single#(
		.DEST_SYNC_FF(2),	// DECIMAL; range: 2-10
		.INIT_SYNC_FF(0),	// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
		.SIM_ASSERT_CHK(0),	// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
		.SRC_INPUT_REG(0),	// DECIMAL; 0=do not register input, 1=register input
		.WIDTH(1)
	)cdc_write_lbh_inst(
		.dest_out	(cdc_input_linebuf_write_high),
		.dest_clk	(axi_clock),
		.src_clk	(input_clock),
		.src_in		(input_linebuf_write_high)
	);
	
	xpm_cdc_array_single#(
		.DEST_SYNC_FF(2),	// DECIMAL; range: 2-10
		.INIT_SYNC_FF(0),	// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
		.SIM_ASSERT_CHK(0),	// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
		.SRC_INPUT_REG(0),	// DECIMAL; 0=do not register input, 1=register input
		.WIDTH(12)
	)cdc_read_y_inst(
		.dest_out	(cdc_out_read_y),
		.dest_clk	(axi_clock),
		.src_clk	(output_clock),
		.src_in		(output_read_y)
	);
	
	xpm_cdc_array_single#(
		.DEST_SYNC_FF(2),	// DECIMAL; range: 2-10
		.INIT_SYNC_FF(0),	// DECIMAL; 0=disable simulation init values, 1=enable simulation init values
		.SIM_ASSERT_CHK(0),	// DECIMAL; 0=disable simulation messages, 1=enable simulation messages
		.SRC_INPUT_REG(0),	// DECIMAL; 0=do not register input, 1=register input
		.WIDTH(1)
	)cdc_read_lbh_inst(
		.dest_out	(cdc_output_linebuf_read_high),
		.dest_clk	(axi_clock),
		.src_clk	(output_clock),
		.src_in		(output_linebuf_read_high)
	);
	
	// ####################################################################################
	always@(posedge axi_clock)begin
		input_write_y_curr <= cdc_in_write_y;
		input_write_y_last <= input_write_y_curr;
		output_read_y_curr <= cdc_out_read_y;
		output_read_y_last <= output_read_y_curr;
		
		if(write_state == 0)begin
			
			if(input_write_y_curr != input_write_y_last)begin
				input_read_x <= 12'd0;
			end
			
			input_linebuf_read_high <= ~cdc_input_linebuf_write_high;
			input_read_y <= input_write_y_curr - 1;
			input_linebuf_ready <= 1'b1;
		end else if(write_state == 3)begin
			if(axi_wready & input_linebuf_ready)begin
				input_read_x <= input_read_x + 8;
				input_linebuf_ready <= 1'b0;
			end else begin
				input_linebuf_ready <= 1'b1;
			end
		end else begin
			input_linebuf_ready <= 1'b1;
		end
		
		if(read_state == 0)begin
			
			if(output_read_y_curr != output_read_y_last)begin
				output_write_x <= 12'd0;
			end
			
			if(output_read_y_curr == 12'd4095)begin
				output_write_y <= 12'd0;
			end else begin
				output_write_y <= output_read_y_curr + 1;
			end
			
			output_linebuf_write_high <= ~cdc_output_linebuf_read_high;
		end else if(read_state == 2)begin
			if(axi_rvalid)begin
				output_write_x <= output_write_x + 8;
			end
		end
	end
	// ####################################################################################
	
	always@(*)begin
		if(zoom_mode)begin
			if(!output_read_x[0])begin
				output_data = output_linebuf_q[31:8];
			end else begin
				output_data = output_linebuf_q[63:40];
			end
		end else begin
			output_data = rgb_average(output_linebuf_q[63:40], output_linebuf_q[31:8]);
		end
	end
	
	assign input_linebuf_din = {input_data_odd, 8'h00, input_data_even, 8'h00};
	assign input_linebuf_wren = input_den;
	
	// ####################################################################################
	// Write state machine
	// ####################################################################################
	
	assign axi_awaddr = {3'b000, fb_write_address, 2'b00};
	assign axi_araddr = {3'b000, fb_read_address, 2'b00};
	
	always@(posedge axi_clock)begin
		axi_wready_last <= axi_wready;
	end
	
	always@(posedge axi_clock)begin
		if(global_reset)begin
			write_state <= 0;
			write_count <= 8'd0;
		end else begin
			case(write_state)
				//wait to be able to start writing
				0: begin
					if((input_read_x < input_width) & (input_read_y < input_height) & !freeze)begin
						write_state <= 1;
					end
				end
				
				1: begin
					if(axi_awready)begin
						write_state <= 2;
						write_count <= 0;
					end
				end
				
				2: begin
					write_state <= 3;
				end
				
				3: begin
					if(input_linebuf_ready & axi_wready)begin
						if(write_count == (burst_len - 1) )begin
							write_state <= 4;
						end else begin
							write_count <= write_count + 1;
						end
					end
				end
				
				default: begin
					write_state <= 0;
				end
			endcase
		end
	end
	
	assign axi_awvalid = (write_state == 1) ? 1'b1 : 1'b0;
	assign axi_wvalid = (write_state == 3) ? input_linebuf_ready : 1'b0;
	assign axi_wlast = ((write_state == 3) & (write_count == (burst_len - 1))) ? 1'b1 : 1'b0;
	assign axi_wdata = input_linebuf_q;
	// ####################################################################################
	
	
	// ####################################################################################
	// Read state machine
	// ####################################################################################
	always@(posedge axi_clock)begin
		if(global_reset)begin
			read_state <= 0;
		end else begin
			
			case(read_state)
				// wait to be able to start reading
				0: begin
					if( (output_write_x < output_write_end_x) & (output_write_y < output_height) )begin
						read_state <= 1;
					end
				end
				// assert arvalid, wait for arready
				1: begin
					if(axi_arready)begin
						read_state <= 2;
					end
				end
				
				2: begin
					if(axi_rvalid & axi_rlast)begin
						read_state <= 3;
					end
				end
				
				3: begin
					read_state <= 0;
				end
			endcase
		end
	end
	
	assign axi_arvalid = (read_state == 1) ? 1'b1 : 1'b0;
	assign output_linebuf_wren = (((read_state == 1) | (read_state == 2)) & axi_rvalid) ? 1'b1 : 1'b0;
	//Split pixels between the two fifos
	assign output_linebuf_din = axi_rdata;
	// ####################################################################################
	
	assign ilb_clka		= input_clock;
	assign ilb_ena		= 1'b1;
	assign ilb_wea		= input_linebuf_wren;
	assign ilb_addra	= input_linebuf_write_addr;
	assign ilb_dina		= input_linebuf_din;
	
	assign ilb_clkb		= axi_clock;
	assign ilb_addrb	= input_linebuf_read_addr;
	assign input_linebuf_q = ilb_doutb;
	
	assign olb_clka		= axi_clock;
	assign olb_ena		= 1'b1;
	assign olb_wea		= output_linebuf_wren;
	assign olb_addra	= output_linebuf_write_addr;
	assign olb_dina		= output_linebuf_din;
	
	assign olb_clkb		= output_clock;
	assign olb_addrb	= output_linebuf_read_addr;
	assign output_linebuf_q = olb_doutb;
	
	// input_line_buffer inbuf(
		// .clka	(input_clock),
		// .ena	(1'b1),
		// .wea	(input_linebuf_wren),
		// .addra	(input_linebuf_write_addr),
		// .dina	(input_linebuf_din),
		
		// .clkb	(axi_clock),
		// .addrb	(input_linebuf_read_addr),
		// .doutb	(input_linebuf_q)
	// );
	
	// output_line_buffer outbuf(
		// .clka	(axi_clock),
		// .ena	(1'b1),
		// .wea	(output_linebuf_wren),
		// .addra	(output_linebuf_write_addr),
		// .dina	(output_linebuf_din),
		
		// .clkb	(output_clock),
		// .addrb	(output_linebuf_read_addr),
		// .doutb	(output_linebuf_q)
	// );
	
	assign axi_awlen = (burst_len - 1); //burst len of 16 transfers (128 32-bit words)
	assign axi_arlen = (burst_len - 1);
	assign axi_awsize = 3'b010; //not sure about this - AXI4 spec does not consider 256-bit datapath
	assign axi_arsize = 3'b010;
	assign axi_awburst = 2'b01; //INCR burst type
	assign axi_arburst = 2'b01;
	assign axi_rready = 1'b1; //we're always ready
	assign axi_bready = 1'b1;
	assign axi_wstrb = 32'hFFFF_FFFF; //all data bytes always valid
	assign axi_awid = 1'b0;
	assign axi_arid = 1'b1;
	
	//Hardwired AXI4 signals (useless)
	assign axi_awlock = 1'b0;
	assign axi_awcache = 4'b0011;
	assign axi_awprot = 3'b000;
	assign axi_awqos = 4'b0000;
	assign axi_arlock = 1'b0;
	assign axi_arcache = 4'b0011;
	assign axi_arprot = 3'b000;
	assign axi_arqos = 4'b0000;
	
endmodule
