module control(
	input reset,
	input done,
	output clk
	);

	reg clk, planB, doneReset;
	wire planBreset;
	wire doneActual;

	delay d(
		.in1(planB),
		.in2(~doneActual),
		.out(planBreset)
		);

	assign doneActual = done | doneReset;

	always @(posedge planBreset or negedge doneActual) begin
		#1 clk <= 1;
		#2 planB <= 0;
	end

	always @(negedge reset) begin
		#2 doneReset = 0;
	end

	always @(posedge clk) begin
		#6 clk <= 0;
	end

	always @(negedge clk) begin
		#2 planB <= 1;
	end

	always @(reset) begin
		clk = 0;
		planB = 0;
		doneReset = 1;
	end

endmodule
