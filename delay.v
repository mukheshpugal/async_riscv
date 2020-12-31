module delay 
	#(parameter length=9)
	(
	input in1,
	input in2,
	output reg out
	);

	reg [length-1:0] inter;
	genvar i;

	always @(in1, in2) begin
		#5 inter[0] = in1 & in2;
	end

	generate
		for (i=1; i < length; i = i + 1) begin
			always @(inter[i-1], in2) begin
				#5 inter[i] = inter[i-1] & in2;
			end
		end
	endgenerate

	always @(inter[length-1], in2) begin
		#5 out = inter[length-1] & in2;
	end

	initial begin
		inter = 0;
		out = 0;
	end

endmodule
