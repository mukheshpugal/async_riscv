`timescale 1ns/1ns

module test_tb();

	reg req;
	reg ack;

	// Functional
	always @(posedge req) begin
		ack <= 1;
	end
	always @(posedge ack) begin
		#20 ack <= 0;
	end

	initial begin
		$dumpfile("test_tb.vcd");
		$dumpvars(0, test_tb);
		ack = 0;
		req = 0;
		#10
		req = 1;
		#10
		req = 0;
		#50

		$finish;
	end

endmodule
