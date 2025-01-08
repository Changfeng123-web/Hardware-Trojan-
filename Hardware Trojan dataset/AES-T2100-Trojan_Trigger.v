`timescale 1ns / 1ps
module Trojan_Trigger(
    input rst,
    input [127:0] out,
    output Tj_Trig
    );

	reg [127:0] Counter;
	reg Tj_Trig;
	
	always @(rst, out)
	begin
		if (rst == 1) begin
			Counter <= 0;
		end else begin
			Counter <= Counter + 1;
		end
	end

	always @(rst, Counter)
	begin
		if (rst == 1) begin
			Tj_Trig <= 0;
		end else if (Counter == 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) begin
			Tj_Trig <= 1;
		end 
	end
	
endmodule
