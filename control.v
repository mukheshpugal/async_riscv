module control(
	input done,
	input maxCount,
	input reset,
	output clk,
	output finish
);
	reg [31:0] count;
	assign clk = done;
	assign finish = (count >= maxCount);

	always @(posedge reset) begin
		clk = 1;
	end
	always @(posedge clk) begin
		count <= count + 1;
	end

endmodule