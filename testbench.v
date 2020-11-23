`timescale 1ns/1ps

module testbench ();
	reg reset;
	wire clk, done, finish;
    wire [31:0] iaddr, idata, daddr, drdata, dwdata;
    wire [3:0] dwe;
    integer i, s, fail, log_file, exp_file;
    reg [31:0] maxCount;

    control u0(
    	.done(done),
    	.reset(reset),
    	.maxCount(maxCount),
    	.clk(clk),
    	.finish(finish)
	);

    cpu u1(
        .clk(clk),
        .reset(reset),
        .iaddr(iaddr),
        .idata(idata),
        .daddr(daddr),
        .drdata(drdata),
        .dwdata(dwdata),
        .dwe(dwe),
        .done(done)
    );

    imem u2(
        .iaddr(iaddr),
        .idata(idata)
    );

    dmem u3(
        .clk(clk),
        .daddr(daddr),
        .drdata(drdata),
        .dwdata(dwdata),
        .dwe(dwe)
    );

    initial begin
    	$dumpfile("cpu_tb.vcd");
    	$dumpvars(0, cpu_tb);
    	maxCount = 10000;
    	reset = 1;
    	#100
    	reset = 0;
    	@posedge(finish)
    	$finish
