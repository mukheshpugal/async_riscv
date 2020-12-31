module cpu (
    input clk, 
    input reset,
    output reg [31:0] iaddr,
    input [31:0] idata,
    output [31:0] daddr,
    input [31:0] drdata,
    output [31:0] dwdata,
    output [3:0] dwe,
    output done
);
    // Wires for ALU
    wire [4:0] rs1, rs2, rd;
    wire [5:0] op;
    wire [31:0] rv1, rv2, r_rv2, rvout, rvout_alu;
    wire regWe, regClk;

    // ALU Modules
    alu32 u1(
        .op(op),
        .rv1(rv1),
        .rv2(rv2),
        .rvout(rvout_alu)
    );

    regfile u2(
        .clk(regClk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .we(regWe),
        .wdata(rvout),
        .rv1(rv1),
        .rv2(r_rv2)
    );

    // Decoder for ALU instructions
    assign rs1 = idata[19:15];
    assign rs2 = idata[24:20];
    assign rd = idata[11:7];

    assign op[5:4] = idata[31:30];
    assign op[3] = idata[5];
    assign op[2:0] = idata[14:12];

    assign #5 rv2 = (idata[5]) ? r_rv2 : {{20{idata[31]}}, idata[31:20]};
    assign #10 regWe = ((idata[6:3] == 4'b0000) || (idata[6:3] == 4'b0010) || (idata[6:3] == 4'b0110) || ({idata[6:4], idata[2]} == 4'b1101));
    assign regClk = clk & ~reset;

    // Wires for Load and Store instructions
    wire [11:0] imm;
    wire [31:0] rvout_ld;
    wire [7:0] lb;
    wire [15:0] lh;

    // Decoder for Load and Store instructions
    assign imm[11:5] = idata[31:25];
    assign #5 imm[4:0] = (idata[5]) ? idata[11:7] : idata[24:20];
    assign #10 rvout = (idata[4:2] == 3'b101) ? {idata[31:12], {12{1'b0}}} + ((idata[5]) ? 0 : iaddr) :
                   (idata[6])                ? rvout_jl  :
                   (idata[4])                ? rvout_alu :
                   rvout_ld;
    assign #5 daddr = rv1 + {{20{imm[11]}}, imm[11:0]};
    assign #10 dwdata = (idata[14:12] == 3'b000) ? {4{r_rv2[7:0]}}  :
                    (idata[14:12] == 3'b001) ? {2{r_rv2[15:0]}} :
                    r_rv2;

    // Load and Store functionality
    assign #10 dwe = (idata[6:4] != 3'b010)  ? 4'b0000 :
                 (idata[13:12] == 2'b00) ? (4'b0001<<daddr[1:0]) :
                 (idata[13:12] == 2'b01) ? (4'b0011<<daddr[1:0]) :
                 (idata[13:12] == 2'b10) ? 4'b1111 :
                 0;
    assign #10 lb = (daddr[1:0] == 2'b00) ? drdata[ 7: 0] :
                (daddr[1:0] == 2'b01) ? drdata[15: 8] :
                (daddr[1:0] == 2'b10) ? drdata[23:16] :
                drdata[31:24];
    assign #7 lh = (daddr[1] == 1'b0) ? drdata[15:0] :
                drdata[31:16];
    assign #10 rvout_ld = (idata[13:12] == 2'b00) ? ((idata[14]) ? $unsigned(lb) : $signed(lb)) :
                      (idata[13:12] == 2'b01) ? ((idata[14]) ? $unsigned(lh) : $signed(lh)) :
                      (idata[13:12] == 2'b10) ? drdata :
                      0;

    // Wires for jump instructions
    wire isJump;
    wire [31:0] rvout_jl;
    wire [31:0] jaddr;

    // Decoder for jump
    assign #10 isJump = (idata[6:4] != 3'b110)      ? 0 :
                    (idata[2])                  ? 1 :
                    (idata[14:12] == 3'b000)    ? (rv1 == r_rv2) :
                    (idata[14:12] == 3'b001)    ? (rv1 != r_rv2) :
                    (idata[14:12] == 3'b100)    ? ($signed(rv1) < $signed(r_rv2))  :
                    (idata[14:12] == 3'b101)    ? ($signed(rv1) >= $signed(r_rv2)) :
                    (idata[14:12] == 3'b110)    ? ($unsigned(rv1) < $unsigned(r_rv2))  :
                    (idata[14:12] == 3'b111)    ? ($unsigned(rv1) >= $unsigned(r_rv2)) :
                    0;
    assign #10 rvout_jl = iaddr + 4;
    assign #10 jaddr = (idata[3:2] == 2'b00) ? iaddr + ({{21{idata[31]}}, idata[7], idata[30:25], idata[11:8]} << 1) :
                   (idata[3:2] == 2'b01) ? rv1 + {{20{idata[31]}}, idata[31:20]} :
                   (idata[3:2] == 2'b11) ? iaddr + ({{13{idata[31]}}, idata[19:12], idata[20], idata[30:21]} << 1) :
                   0;

    // Logic for detecting end of instruction
    reg jmpDone, stDone, aluDone;
    reg match, jmpMatch, stMatch, aluMatch;

    // Detecting changes
    always @(rd, rvout) begin
        if (match == aluMatch)
            aluDone <= 1;
        #6 aluDone <= 0;
    end
    always @(daddr, dwdata, dwe) begin
        if (match == stMatch)
            stDone <= 1;
        #6 stDone <= 0;
    end
    always @(jaddr, isJump) begin
        if (match == jmpMatch)
            jmpDone <= 1;
        #6 jmpDone <= 0;
    end

    // Choosing done signal based on instruction type
    assign done = (idata[6:4] == 3'b110) ? jmpDone :
                  (idata[6:4] == 3'b010) ? stDone :
                  (regWe) ? aluDone :
                  0;

    // To make sure done signals for previous instruction don't mess with the current instruction
    always @(posedge clk) begin
        #20 jmpMatch = jmpMatch + 1;
    end
    always @(jmpMatch) begin
        stMatch = stMatch + 1;
    end
    always @(jmpMatch) begin
        #15 aluMatch = aluMatch + 1;
    end

    always @(reset) begin
        iaddr <= -4;
        jmpDone = 0;
        stDone = 0;
        aluDone = 0;
        match = 0;
        jmpMatch = 0;
        stMatch = 0;
        aluMatch = 0;
    end

    always @(posedge clk) begin
        match = match + 1;
        if (isJump)
            iaddr <= jaddr;
        else
            iaddr <= iaddr + 4;
    end

endmodule
