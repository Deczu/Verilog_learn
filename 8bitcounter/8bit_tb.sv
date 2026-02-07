module tb_top();
    logic clk, reset, enable, dir;
    logic [7:0] count;

    // Instantiate the design
    counter_8bit  counter_8bit0 (	.clk (clk),
               		.reset (reset),
                    .enable (enable),
                    .dir (dir),
               		.count (count));

    // Create a clock
    initial clk = 0;
    always #5 clk <= ~clk;
    initial begin
        reset <= 1;
        enable <= 0;
        dir <= 1;
        @(posedge clk) $info("t=%0t | count=%d", $time, count);
        reset <= 0;  // zwolnij reset
        enable <= 1;
        // coś ciekawego
        #1;
        $info("t=%0t | count=%d", $time, count);
        repeat(20) @(posedge clk);  // czekaj 20 cykli zegara
        #1; // allow non-blocking updates to take effect before checking
        assert (count == 20)
        else   $error("Test failed: expected count to be 20, but got %d", count);
        dir <= 0;     // zmień kierunek
        repeat(20) @(posedge clk);  // czekaj dalej
        dir <= 1;
        repeat(5) @(posedge clk);    // czekaj 5 cykli
        enable <= 0;
        $finish;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end
    initial begin
        $monitor("t=%0t | count=%d", $time, count);
    end

endmodule