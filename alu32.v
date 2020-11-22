module alu32(
    input [5:0] op,      // some input encoding of your choice
    input [31:0] rv1,    // First operand
    input [31:0] rv2,    // Second operand
    output reg [31:0] rvout  // Output value
);
	always @(rv1, rv2, op) begin
		case(op[2:0])
			3'b000	: rvout = (op[4:3] == 2'b11) ? rv1 - rv2 : rv1 + rv2;
			3'b010 	: rvout = ($signed(rv1) < $signed(rv2)) ? 1 : 0;
			3'b011 	: rvout = (rv1 < rv2) ? 1 : 0;
			3'b100 	: rvout = rv1 ^ rv2;
			3'b110 	: rvout = rv1 | rv2;
			3'b111 	: rvout = rv1 & rv2;
			3'b001 	: rvout = rv1 << rv2[4:0];
			3'b101 	: rvout = (op[4]) ? $signed(rv1) >>> rv2[4:0] : rv1 >> rv2[4:0];
			default	: rvout = 0;
		endcase // op
	end

endmodule
