module tb_top;
    logic clk;
    logic reset;
    logic enable;
    logic [1:0] data_in_x;
    logic [1:0] data_in_y;
    logic [1:0] winner;
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
            // ============================================================
        // TEST: Wygrana gracza 0 (linia pozioma)
        // ============================================================
        $display("\n=== TEST: Wygrana gracza 0 ===");

        reset = 1; @(negedge clk);
        reset = 0; enable = 1;

        // Ruchy gracza 0
        player = 0; data_in_x = 0; data_in_y = 0; @(negedge clk);
        player = 1; data_in_x = 1; data_in_y = 0; @(negedge clk);
        player = 0; data_in_x = 0; data_in_y = 1; @(negedge clk);
        player = 1; data_in_x = 1; data_in_y = 1; @(negedge clk);
        player = 0; data_in_x = 0; data_in_y = 2; @(negedge clk);

        $display("game_state\n| %0d %0d %0d \n| %0d %0d %0d \n| %0d %0d %0d",
            dut.game_state[0][0], dut.game_state[0][1], dut.game_state[0][2],
            dut.game_state[1][0], dut.game_state[1][1], dut.game_state[1][2],
            dut.game_state[2][0], dut.game_state[2][1], dut.game_state[2][2]
        );

        if (winner == 0)
            $display("OK: Gracz 0 wygrał poprawnie");
        else
            $error("BŁĄD: Oczekiwano zwycięstwa gracza 0, winner=%0d", winner);


        // ============================================================
        // TEST: Wygrana gracza 1 (przekątna)
        // ============================================================
        $display("\n=== TEST: Wygrana gracza 1 ===");

        reset = 1; @(negedge clk);
        reset = 0; enable = 1;

        // Ruchy prowadzące do wygranej gracza 1
        player = 0; data_in_x = 0; data_in_y = 1; @(negedge clk);
        player = 1; data_in_x = 0; data_in_y = 0; @(negedge clk);
        player = 0; data_in_x = 1; data_in_y = 0; @(negedge clk);
        player = 1; data_in_x = 1; data_in_y = 1; @(negedge clk);
        player = 0; data_in_x = 2; data_in_y = 0; @(negedge clk);
        player = 1; data_in_x = 2; data_in_y = 2; @(negedge clk);

        $display("game_state\n| %0d %0d %0d \n| %0d %0d %0d \n| %0d %0d %0d",
            dut.game_state[0][0], dut.game_state[0][1], dut.game_state[0][2],
            dut.game_state[1][0], dut.game_state[1][1], dut.game_state[1][2],
            dut.game_state[2][0], dut.game_state[2][1], dut.game_state[2][2]
        );

        if (winner == 1)
            $display("OK: Gracz 1 wygrał poprawnie");
        else
            $error("BŁĄD: Oczekiwano zwycięstwa gracza 1, winner=%0d", winner);


        // ============================================================
        // TEST: Remis
        // ============================================================
        $display("\n=== TEST: Remis ===");

        reset  = 1; @(negedge clk);
        reset  = 0; enable = 1;

        // X O X
        // X X O
        // O X O
        player = 0; data_in_x = 0; data_in_y = 0; @(negedge clk); // (0,0) = 0
        player = 1; data_in_x = 1; data_in_y = 0; @(negedge clk); // (0,1) = 1
        player = 0; data_in_x = 2; data_in_y = 0; @(negedge clk); // (0,2) = 0

        player = 1; data_in_x = 0; data_in_y = 1; @(negedge clk); // (1,0) = 1
        player = 0; data_in_x = 2; data_in_y = 1; @(negedge clk); // (1,2) = 0
        player = 1; data_in_x = 1; data_in_y = 1; @(negedge clk); // (1,1) = 1

        player = 0; data_in_x = 0; data_in_y = 2; @(negedge clk); // (2,0) = 0
        player = 1; data_in_x = 2; data_in_y = 2; @(negedge clk); // (2,2) = 1
        player = 0; data_in_x = 1; data_in_y = 2; @(negedge clk); // (2,1) = 0

        $display("game_state\n| %0d %0d %0d \n| %0d %0d %0d \n| %0d %0d %0d",
            dut.game_state[0][0], dut.game_state[0][1], dut.game_state[0][2],
            dut.game_state[1][0], dut.game_state[1][1], dut.game_state[1][2],
            dut.game_state[2][0], dut.game_state[2][1], dut.game_state[2][2]
        );

        if (winner == 3 && stop_game == 1)
            $display("OK: Remis wykryty poprawnie");
        else
            $error("BŁĄD: Oczekiwano remisu, winner=%0d stop_game=%0d", winner, stop_game);



        $finish; // Kończymy symulację po pierwszym cyklu, żeby zobaczyć tylko "Enabled!"
    end    
    // =========================
    // WAVES
    // =========================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end






endmodule