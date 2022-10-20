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

module ov13850_4k_regs(
	input wire			clock,
	input wire			clock_en,
	input wire	[8:0]	address,
	output reg	[23:0]	data
);
	
	always@(clock)begin
		if(clock_en)begin
			case(address)
				9'h0: data <= 24'h010301; //software reset
				9'h1: data <= 24'h030a00;
				9'h2: data <= 24'h300f11; //MIPI 10 bit mode
				9'h3: data <= 24'h301003; //MIPI PHY
				9'h4: data <= 24'h301176; //MIPI PHY
				9'h5: data <= 24'h301241; //MIPI 4 lane
				9'h6: data <= 24'h301312;
				9'h7: data <= 24'h301411;
				9'h8: data <= 24'h301f03;
				9'h9: data <= 24'h310600;
				9'ha: data <= 24'h321047;
				9'hb: data <= 24'h350000;
				9'hc: data <= 24'h3501b0;
				9'hd: data <= 24'h350200;
				9'he: data <= 24'h350600;
				9'hf: data <= 24'h35070a;
				9'h10: data <= 24'h350800;
				9'h11: data <= 24'h350910;
				9'h12: data <= 24'h350a00;
				9'h13: data <= 24'h350ba0;
				9'h14: data <= 24'h350e00;
				9'h15: data <= 24'h350fa0;
				9'h16: data <= 24'h360040;
				9'h17: data <= 24'h3601fc;
				9'h18: data <= 24'h360202;
				9'h19: data <= 24'h360348;
				9'h1a: data <= 24'h3604a5;
				9'h1b: data <= 24'h36059f;
				9'h1c: data <= 24'h360700;
				9'h1d: data <= 24'h360a40;
				9'h1e: data <= 24'h360b91;
				9'h1f: data <= 24'h360c49;
				9'h20: data <= 24'h360f8a;
				9'h21: data <= 24'h361110;
				9'h22: data <= 24'h361311;
				//wait
				9'h30: data <= 24'h361508;
				9'h31: data <= 24'h364102;
				9'h32: data <= 24'h366082;
				9'h33: data <= 24'h366854;
				9'h34: data <= 24'h366940;
				9'h35: data <= 24'h3667a0;
				9'h36: data <= 24'h370240;
				9'h37: data <= 24'h370344;
				9'h38: data <= 24'h37042c;
				9'h39: data <= 24'h370524;
				9'h3a: data <= 24'h370650;
				9'h3b: data <= 24'h370744;
				9'h3c: data <= 24'h37083c;
				9'h3d: data <= 24'h37091f;
				9'h3e: data <= 24'h370a26;
				9'h3f: data <= 24'h370b3c;
				9'h40: data <= 24'h372066;
				9'h41: data <= 24'h372284;
				9'h42: data <= 24'h372840;
				9'h43: data <= 24'h372a00;
				9'h44: data <= 24'h372f90;
				9'h45: data <= 24'h371028;
				9'h46: data <= 24'h371603;
				9'h47: data <= 24'h371810;
				9'h48: data <= 24'h371908;
				9'h49: data <= 24'h371cfc;
				9'h4a: data <= 24'h376013;
				9'h4b: data <= 24'h376134;
				9'h4c: data <= 24'h376724;
				9'h4d: data <= 24'h376806;
				9'h4e: data <= 24'h376945;
				9'h4f: data <= 24'h376c23;
				9'h50: data <= 24'h3d8400;
				9'h51: data <= 24'h3d8517;
				9'h52: data <= 24'h3d8c73;
				9'h53: data <= 24'h3d8dbf;
				9'h54: data <= 24'h380000;
				9'h55: data <= 24'h380108;
				9'h56: data <= 24'h380200;
				9'h57: data <= 24'h380304;
				9'h58: data <= 24'h380410;
				9'h59: data <= 24'h380597;
				9'h5a: data <= 24'h38060c;
				9'h5b: data <= 24'h38074b;
				9'h5c: data <= 24'h380808;
				9'h5d: data <= 24'h380996;
				9'h5e: data <= 24'h380a08;
				9'h5f: data <= 24'h380b70;
				9'h60: data <= 24'h380c25;
				9'h61: data <= 24'h380d80;
				9'h62: data <= 24'h380e06;
				9'h63: data <= 24'h380f80;
				9'h64: data <= 24'h381000;
				9'h65: data <= 24'h381104;
				9'h66: data <= 24'h381200;
				9'h67: data <= 24'h381302;
				9'h68: data <= 24'h381431;
				9'h69: data <= 24'h381531;
				9'h6a: data <= 24'h382002;
				9'h6b: data <= 24'h382105; //mirror off
				9'h6c: data <= 24'h383400;
				9'h6d: data <= 24'h38351c;
				9'h6e: data <= 24'h383608;
				9'h6f: data <= 24'h383702;
				9'h70: data <= 24'h4000f1;
				9'h71: data <= 24'h400100;
				9'h72: data <= 24'h400b0c;
				9'h73: data <= 24'h401100;
				9'h74: data <= 24'h401a00;
				9'h75: data <= 24'h401b00;
				9'h76: data <= 24'h401c00;
				9'h77: data <= 24'h401d00;
				9'h78: data <= 24'h402000;
				9'h79: data <= 24'h4021e4;
				9'h7a: data <= 24'h402207;
				9'h7b: data <= 24'h40235f;
				9'h7c: data <= 24'h402408;
				9'h7d: data <= 24'h402544;
				9'h7e: data <= 24'h402608;
				9'h7f: data <= 24'h402747;
				9'h80: data <= 24'h402800;
				9'h81: data <= 24'h402902;
				9'h82: data <= 24'h402a04;
				9'h83: data <= 24'h402b08;
				9'h84: data <= 24'h402c02;
				9'h85: data <= 24'h402d02;
				9'h86: data <= 24'h402e0c;
				9'h87: data <= 24'h402f08;
				9'h88: data <= 24'h403d2c;
				9'h89: data <= 24'h403f7f;
				9'h8a: data <= 24'h450082;
				9'h8b: data <= 24'h450138;
				9'h8c: data <= 24'h460104;
				9'h8d: data <= 24'h460222;
				9'h8e: data <= 24'h460301;
				9'h8f: data <= 24'h483719;
				9'h90: data <= 24'h480004;
				9'h91: data <= 24'h480242;
				9'h92: data <= 24'h481a00;
				9'h93: data <= 24'h481b1c;
				9'h94: data <= 24'h482612;
				9'h95: data <= 24'h4d0004;
				9'h96: data <= 24'h4d0142;
				9'h97: data <= 24'h4d02d1;
				9'h98: data <= 24'h4d0390;
				9'h99: data <= 24'h4d0466;
				9'h9a: data <= 24'h4d0565;
				9'h9b: data <= 24'h50000e;
				9'h9c: data <= 24'h500103;
				9'h9d: data <= 24'h500207;
				9'h9e: data <= 24'h501340;
				9'h9f: data <= 24'h501c00;
				9'ha0: data <= 24'h501d10;
				9'ha1: data <= 24'h524200;
				9'ha2: data <= 24'h5243b8;
				9'ha3: data <= 24'h524400;
				9'ha4: data <= 24'h5245f9;
				9'ha5: data <= 24'h524600;
				9'ha6: data <= 24'h5247f6;
				9'ha7: data <= 24'h524800;
				9'ha8: data <= 24'h5249a6;
				9'ha9: data <= 24'h5300fc;
				9'haa: data <= 24'h5301df;
				9'hab: data <= 24'h53023f;
				9'hac: data <= 24'h530308;
				9'had: data <= 24'h53040c;
				9'hae: data <= 24'h530510;
				9'haf: data <= 24'h530620;
				9'hb0: data <= 24'h530740;
				9'hb1: data <= 24'h530808;
				9'hb2: data <= 24'h530908;
				9'hb3: data <= 24'h530a02;
				9'hb4: data <= 24'h530b01;
				9'hb5: data <= 24'h530c01;
				9'hb6: data <= 24'h530d0c;
				9'hb7: data <= 24'h530e02;
				9'hb8: data <= 24'h530f01;
				9'hb9: data <= 24'h531001;
				9'hba: data <= 24'h540000;
				9'hbb: data <= 24'h540161;
				9'hbc: data <= 24'h540200;
				9'hbd: data <= 24'h540300;
				9'hbe: data <= 24'h540400;
				9'hbf: data <= 24'h540540;
				9'hc0: data <= 24'h540c05;
				9'hc1: data <= 24'h5b0000;
				9'hc2: data <= 24'h5b0100;
				9'hc3: data <= 24'h5b0201;
				9'hc4: data <= 24'h5b03ff;
				9'hc5: data <= 24'h5b0402;
				9'hc6: data <= 24'h5b056c;
				9'hc7: data <= 24'h5b0902;
				9'hc8: data <= 24'h5e0000; //test pattern off
				9'hc9: data <= 24'h5e101c;
				9'hca: data <= 24'h381304;
				9'hcb: data <= 24'h381411;
				9'hcc: data <= 24'h381511;
				9'hcd: data <= 24'h382004;
				9'hce: data <= 24'h382104; //mirror off
				9'hcf: data <= 24'h383604;
				9'hd0: data <= 24'h383701;
				9'hd1: data <= 24'h48370a;
				9'hd2: data <= 24'h482612;
				9'hd3: data <= 24'h540171;
				9'hd4: data <= 24'h540580;
				9'hd5: data <= 24'h361207;
				9'hd6: data <= 24'h030000;
				9'hd7: data <= 24'h030100;
				9'hd8: data <= 24'h030220;
				9'hd9: data <= 24'h030300;
				9'he0: data <= 24'h48370d;
				9'he1: data <= 24'h370a24;
				9'he2: data <= 24'h372a04;
				9'he3: data <= 24'h372fa0;
				9'he4: data <= 24'h380001;
				9'he5: data <= 24'h38014c;
				9'he6: data <= 24'h380202;
				9'he7: data <= 24'h38038c;
				9'he8: data <= 24'h380410;
				9'he9: data <= 24'h380553;
				9'hf0: data <= 24'h38060b;
				9'hf1: data <= 24'h380703;
				9'hf2: data <= 24'h38080f;
				9'hf3: data <= 24'h380900;
				9'hf4: data <= 24'h380a08;
				9'hf5: data <= 24'h380b70;
				9'hf6: data <= 24'h380c1a; //HTS MSB
				9'hf7: data <= 24'h380d90; //HTS LSB
				9'hf8: data <= 24'h380e0b; //VTS MSB
				9'hf9: data <= 24'h380fb0; //VTS LSB
				9'h100: data <= 24'h381000;
				9'h101: data <= 24'h381104;
				9'h102: data <= 24'h381200;
				9'h103: data <= 24'h381304;
				9'h104: data <= 24'h383604;
				9'h105: data <= 24'h383701;
				9'h106: data <= 24'h402000;
				9'h107: data <= 24'h4021e6;
				9'h108: data <= 24'h40220e;
				9'h109: data <= 24'h40231e;
				9'h10a: data <= 24'h40240f;
				9'h10b: data <= 24'h402500;
				9'h10c: data <= 24'h40260f;
				9'h10d: data <= 24'h402706;
				9'h10e: data <= 24'h010001;
				default: data <= 24'h000000;
			endcase
		end
	end
	
endmodule
