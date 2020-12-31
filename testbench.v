`timescale 1ns/1ps

module testbench();

	reg reset;
    wire clk, done;
    wire [31:0] iaddr, idata, daddr, drdata, dwdata;
    wire [3:0] dwe;

    // To check reg values
    integer i, s, fail, log_file, exp_file;
    reg [31:0] dtmp, exp_reg;

    control u0(
        .reset(reset),
        .done(done),
        .clk(clk)
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
    	$dumpfile("testbench.vcd");
    	$dumpvars(0, testbench);
        reset = 1;
        #100
        reset = 0;
        log_file = $fopen("cpu_tb.log", "a");
        exp_file = $fopen({`TESTDIR,"/expout.txt"}, "r");

        @(posedge clk);
        for (i=0; i<200; i=i+1) begin
            @(posedge clk);
        end

        $display("RUNNING TEST FROM ", `TESTDIR);
        fail = 0;
        // Dump top dmem
        for (i=0; i<32; i=i+1) begin
            s = $fscanf(exp_file, "%d\n", exp_reg);
            dtmp = {u3.mem3[i], u3.mem2[i], u3.mem1[i], u3.mem0[i]};
            if(exp_reg !== dtmp) begin
                $display("FAIL: Expected Reg[%d] = %x vs. Got Reg[%d] = %x", i, $signed(exp_reg), i, dtmp);
                fail = fail + 1;
            end 
        end

        if(fail != 0) begin
            $display("FAILED. %d registers do not match.\n", fail);
        end
    	$finish;
    end

endmodule
