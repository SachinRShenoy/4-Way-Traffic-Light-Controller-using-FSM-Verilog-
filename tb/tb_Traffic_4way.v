`timescale 1ns/1ps

module tb_Traffic_4way;

    reg clk;
    reg reset;
    wire [2:0] North, South, East, West;

    // DUT: aggressively scaled timing
    Traffic_4way #(
        .CLK_FREQ(10)   // VERY small for fast simulation
    ) dut (
        .clk(clk),
        .reset(reset),
        .North(North),
        .South(South),
        .East(East),
        .West(West)
    );

    // Fast clock: 100 ns period (10 MHz)
    initial clk = 0;
    always #50 clk = ~clk;

    initial begin
        // Dump waves
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_Traffic_4way);

        // --- RESET SEQUENCE 1 ---
        reset = 1;
        #200;            // hold reset for a few cycles
        reset = 0;

        // Let FSM run for some time
        #5_000;

        // --- RESET SEQUENCE 2 (mid-operation reset) ---
        reset = 1;
        #100;
        reset = 0;

        // Let FSM run again
        #10_000;

        // --- RESET SEQUENCE 3 (very short glitch) ---
        reset = 1;
        #50;
        reset = 0;

        // Run long enough to see many full rotations
        #20_000;

        $finish;
    end

endmodule
