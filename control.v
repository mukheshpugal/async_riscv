module control(
	input trigger,
	input done,
	input maxCount,
	output clk,
	output finish
	);

	reg clk, planB, doneReset;
	wire planBreset;
	wire doneActual;
	reg [31:0] instructionCounter;

	delay d(
		.in1(planB),
		.in2(~doneActual),
		.out(planBreset)
		);

	assign doneActual = done | doneReset;
	assign finish = (instructionCounter >= maxCount);

	always @(posedge planBreset or negedge doneActual) begin
		#1 clk <= 1;
		#2 planB <= 0;
	end

	always @(negedge trigger) begin
		doneReset = 0;
	end

	always @(posedge clk) begin
		instructionCounter = instructionCounter + 1;
		#6 clk <= 0;
	end

	always @(negedge clk) begin
		#2 planB <= 1;
	end

	initial begin
		clk = 0;
		planB = 0;
		doneReset = 1;
		instructionCounter = 0;
	end

endmodule
