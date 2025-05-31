module simple_fsm_tb;

    reg clk, rst, in;
    wire [1:0] state;

    // Instantiate the FSM
    simple_fsm uut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .state(state)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Dump the waveform to a vcd file for GTKWave
        $dumpfile("ctl_tb.vcd");
        $dumpvars(0, simple_fsm_tb);
        // Display headers
        $display("Time\tReset\tIn\tState");
        $monitor("%g\t%b\t%b\t%b", $time, rst, in, state);

        // Initialize signals
        rst = 1; in = 0;
        #10 rst = 0;

        // Stimulus pattern
        #10 in = 1;
        #10 in = 1;
        #10 in = 0;
        #10 in = 1;
        #10 $finish;
    end

endmodule
