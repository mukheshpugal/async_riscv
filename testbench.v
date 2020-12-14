`timescale 1ns/1ps

module testbench ();

	reg reset, trigger;
    wire clk, done, finish;
    wire [31:0] iaddr, idata, daddr, drdata, dwdata, maxCount;
    wire [3:0] dwe;

    // To check reg values
    integer i, s, fail, log_file, exp_file;
    reg [31:0] dtmp, exp_reg;

    control u0(
        .trigger(trigger),
        .done(done),
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
        $display("RUNNING TEST FROM ", `TESTDIR);
    	maxCount = 10000;
        #100
        trigger = 1;
        #2
        trigger = 0;
    	@posedge(finish);


        log_file = $fopen("cpu_tb.log", "a");
        exp_file = $fopen({`TESTDIR,"/expout.txt"}, "r");
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
            $fwrite(log_file, "FAIL\n");
        end else begin
            $fwrite(log_file, "PASS\n");
        end
    	$finish
    end

endmodule
