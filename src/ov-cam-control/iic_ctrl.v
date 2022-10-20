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

module iic_ctrl#(
	// xxxx xxx w/R
	parameter [6:0] slave_addr = 7'h10
)(
	input wire			clock_in,
	input wire			clock_en,
	input wire	[23:0]	data_in,
	input wire			enable,
	input wire			start_xfer,
	output reg			xfer_done,
	inout				i2c_sck,
	inout				i2c_sda
);
	
	reg			sck_int, sda_int, bus_en, sck_force;
	reg	[7:0]	state_cntr;
	
	localparam [7:0] state_done = 8'd168;
	
	always@(*)begin
		if(enable & !start_xfer)begin
			if(state_cntr >= state_done)begin
				bus_en = 1'b0;
				xfer_done = 1'b1;
			end else begin
				bus_en = 1'b1;
				xfer_done = 1'b0;
			end
		end else begin
			bus_en = 1'b0;
			xfer_done = 1'b0;
		end
	end
	
	assign i2c_sck = (sck_int | !bus_en) ? 1'bz : 1'b0;
	assign i2c_sda = (sda_int | !bus_en) ? 1'bz : 1'b0;
	
	always@(posedge clock_in)begin
		if(clock_en)begin
			if(start_xfer)begin
				state_cntr <= 8'd0;
			end else if(state_cntr < state_done)begin
				state_cntr <= state_cntr + 1;
			end
		end
	end
	
	always@(posedge clock_in)begin
		if(clock_en)begin
			if(state_cntr[7:2] >= 4 && state_cntr[7:2] <= 39)begin
				sck_int <= sck_force | (state_cntr[1] ^ state_cntr[0]);
			end else begin
				sck_int <= sck_force;
			end
		end
	end
	
	always@(posedge clock_in)begin
		if(clock_en)begin
			if(start_xfer)begin
				sda_int <= 1'b1;
				sck_force <= 1'b1;
			end else if(state_cntr[1 : 0] == 2'b11)begin
				case(state_cntr[7:2])
					0: begin
						sda_int <= 1'b1;
						sck_force <= 1'b1;
					end
					
					1: sda_int <= 1'b0;
					2: sck_force <= 1'b0;
					3: sda_int <= slave_addr[6];
					4: sda_int <= slave_addr[5];
					5: sda_int <= slave_addr[4];
					6: sda_int <= slave_addr[3];
					7: sda_int <= slave_addr[2];
					8: sda_int <= slave_addr[1];
					9: sda_int <= slave_addr[0];
					10: sda_int <= 1'b0;
					11: sda_int <= 1'b1;
					
					12: sda_int <= data_in[23];
					13: sda_int <= data_in[22];
					14: sda_int <= data_in[21];
					15: sda_int <= data_in[20];
					16: sda_int <= data_in[19];
					17: sda_int <= data_in[18];
					18: sda_int <= data_in[17];
					19: sda_int <= data_in[16];
					20: sda_int <= 1'b1;
					
					21: sda_int <= data_in[15];
					22: sda_int <= data_in[14];
					23: sda_int <= data_in[13];
					24: sda_int <= data_in[12];
					25: sda_int <= data_in[11];
					26: sda_int <= data_in[10];
					27: sda_int <= data_in[9];
					28: sda_int <= data_in[8];
					29: sda_int <= 1'b1;
					
					30: sda_int <= data_in[7];
					31: sda_int <= data_in[6];
					32: sda_int <= data_in[5];
					33: sda_int <= data_in[4];
					34: sda_int <= data_in[3];
					35: sda_int <= data_in[2];
					36: sda_int <= data_in[1];
					37: sda_int <= data_in[0];
					38: sda_int <= 1'b1;
					
					39: begin
						sda_int <= 1'b0;
						sck_force <= 1'b0;
					end
					
					40: sck_force <= 1'b1;
					41: sda_int <= 1'b1;
					
					default: begin
						sda_int <= 1'b1;
						sck_force <= 1'b1;
					end
					
				endcase
			end
		end
	end
	
endmodule
