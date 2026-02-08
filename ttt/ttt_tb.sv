module tb_top;

    logic clk;
    logic reset;
    logic enable;
    logic [2:0] data_in_x;
    logic [2:0] data_in_y;

    logic winner;
    logic player;

    // 18-bit packed board from DUT (9 cells x 2 bits)
    logic [17:0] board;

    // =========================
    // DUT
    // =========================
    ttt dut (
        .clk       (clk),
        .reset     (reset),
        .enable    (enable),
        .data_in_x (data_in_x),
        .data_in_y (data_in_y),
        .winner    (winner),
        .player    (player),
        .board     (board)
    );

    // =========================
    // CLOCK
    // =========================
    initial clk = 0;
    always #5 clk = ~clk;

    // =========================
    // TEST SEQUENCE
    // =========================
    initial begin
        // INIT
        reset     = 1;
        enable    = 0;
        data_in_x = 0;
        data_in_y = 0;
        @(negedge clk);
        reset = 0;
        enable = 1;
        $info("winner: %d, player: %d", winner, player);
        @(negedge clk);
        data_in_x = 1;
        data_in_y = 0;
        @(negedge clk);
        data_in_x = 1;
        data_in_y = 0;
        $info("winner: %d, player: %d", winner, player);
        @(negedge clk);
        data_in_x = 2;
        data_in_y = 0;
        @(negedge clk);
        data_in_x = 2;
        data_in_y = 0;
        @(negedge clk);
        // // =========================
        // // PRINT BOARD
        // // =========================
        $display("----- BOARD -----");
        $display("%d %d %d", board[1:0], board[3:2], board[5:4]);
        $display("%d %d %d", board[7:6], board[9:8], board[11:10]);
        $display("%d %d %d", board[13:12], board[15:14], board[17:16]);
        $display("-----------------");

        #10;
        $finish;
    end

    // =========================
    // WAVES
    // =========================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end

endmodule
