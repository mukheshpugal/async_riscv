module block(
	input trigger,
	input done,
	output control
	);

	reg control;
	reg planB;
	wire planBreset;

	delay d(
		.in1(planB),
		.in2(~done),
		.out(planBreset)
		);

	always @(posedge trigger or posedge planBreset or negedge done) begin
		#1 control <= 1;
		#2 planB <= 0;
	end

	always @(posedge control) begin
		#6 control <= 0;
	end

	always @(negedge control) begin
		#2 planB <= 1;
	end

	initial begin
		control = 0;
		planB = 0;
	end

endmodule
