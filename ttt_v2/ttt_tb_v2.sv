module tb_top;
    logic clk;
    logic reset;
    logic enable;
    logic [2:0] data_in_x;
    logic [2:0] data_in_y;
    logic winner;
    logic [1:0] player;
    logic stop_game;

    // =========================
    // DUT
    tttv2 dut (
        .clk       (clk),
        .reset     (reset),
        .enable    (enable),
        .data_in_x (data_in_x),
        .data_in_y (data_in_y),
        .winner    (winner),
        .player    (player),
        .stop_game (stop_game)
    );

    // =========================
    // CLOCK
    initial clk = 0;
    always #5 clk = ~clk;
    // =========================
    // TEST SEQUENCE
    initial begin
        // INIT
        reset     = 1;
        enable    = 0;
        player    = 0;
        @(negedge clk);
        reset = 0;
        enable = 1;
        data_in_x = 0;
        data_in_y = 0;
        @(negedge clk);
        data_in_x = 0;
        data_in_y = 1;
        assert (dut.game_state[0][1] == 3)
            $info("game_state[0][1] is still empty as expected");
        else
            $error("Test failed: expected game_state[0][1] to be updated, but got %0d",
                dut.game_state[0][1]);
        @(negedge clk);
        data_in_x = 0;
        data_in_y = 1;
        player    = 1;
        @(negedge clk);
        $display("game_state\n| %0d %0d %0d \n| %0d %0d %0d \n| %0d %0d %0d",
        dut.game_state[0][0], dut.game_state[0][1], dut.game_state[0][2],
        dut.game_state[1][0], dut.game_state[1][1], dut.game_state[1][2],
        dut.game_state[2][0], dut.game_state[2][1], dut.game_state[2][2]
    );

        $finish; // Kończymy symulację po pierwszym cyklu, żeby zobaczyć tylko "Enabled!"
    end    
    // =========================
    // WAVES
    // =========================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(2, tb_top);
    end






endmodule