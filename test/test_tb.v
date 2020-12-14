`timescale 1ns/1ns

module test_tb();

	reg trigger;
	reg done;
	wire ctrl;

	// Functional
	block b(
		.trigger(trigger),
		.done(done),
		.control(ctrl)
		);

	initial begin
		$dumpfile("test_tb.vcd");
		$dumpvars(0, test_tb);
		trigger = 0;
		done = 1;
		#100
		done = 0;
		#80
		done = 1;
		#6
		done = 0;
		#300

		$finish;
	end

endmodule
