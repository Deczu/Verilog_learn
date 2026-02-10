module tttv2 (
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,
    input  logic [1:0] data_in_x,
    input  logic [1:0] data_in_y,
    input  logic [1:0] player,
    output logic [1:0] winner,
    output logic       stop_game
);

    // 3x3 plansza, 2 bity na pole:
    // 0 – gracz 0
    // 1 – gracz 1
    // 3 – puste
    logic [1:0] game_state      [0:2][0:2];
    logic [1:0] game_state_next [0:2][0:2];

    logic [1:0] current_player, current_player_next;
    logic [1:0] winner_next;
    logic       stop_game_next;
    logic [1:0] win_p;
    logic       win_f;
    logic       full;

    // ------------------------------------------------------------
    // Kombinacyjna logika next_state
    // ------------------------------------------------------------
    always_comb begin
        // domyślnie: brak zmian
        for (int y = 0; y < 3; y++)
            for (int x = 0; x < 3; x++)
                game_state_next[y][x] = game_state[y][x];

        current_player_next = current_player;
        winner_next         = winner;
        stop_game_next      = stop_game;
        win_p = 3;
        win_f = 0;
        full  = 1;
        // jeśli reset aktywny synchronicznie – obsłużymy w always_ff
        // tutaj tylko logika gry, gdy nie ma resetu
        if (enable && !stop_game) begin
            // walidacja gracza
            if ((player == 0 || player == 1) && player != current_player) begin
                // walidacja ruchu
                if (data_in_x < 3 && data_in_y < 3 &&
                    game_state[data_in_y][data_in_x] == 3) begin

                    // wykonaj ruch w next_state
                    game_state_next[data_in_y][data_in_x] = player;
                    current_player_next = player;

                    // sprawdź wygraną na game_state_next

                    // wiersze
                    for (int y = 0; y < 3; y++) begin
                        if (game_state_next[y][0] == game_state_next[y][1] &&
                            game_state_next[y][1] == game_state_next[y][2] &&
                            ~game_state_next[y][0][1]) begin
                            win_p = game_state_next[y][0];
                            win_f = 1;
                        end
                    end

                    // kolumny
                    for (int x = 0; x < 3; x++) begin
                        if ((game_state_next[0][x] == game_state_next[1][x]) &&
                            (game_state_next[1][x] == game_state_next[2][x]) &&
                            game_state_next[0][x] != 3) begin
                            win_p = game_state_next[0][x];
                            win_f = 1;
                        end
                    end

                    // przekątna 1
                    if (game_state_next[0][0] == game_state_next[1][1] &&
                        game_state_next[1][1] == game_state_next[2][2] &&
                        ~game_state_next[0][0][1]) begin
                        win_p = game_state_next[0][0];
                        win_f = 1;
                    end

                    // przekątna 2
                    if (game_state_next[0][2] == game_state_next[1][1] &&
                        game_state_next[1][1] == game_state_next[2][0] &&
                        game_state_next[0][2] inside {0,1}) begin
                        win_p = game_state_next[0][2];
                        win_f = 1;
                    end

                    // pełna plansza?
                    for (int y = 0; y < 3; y++)
                        for (int x = 0; x < 3; x++)
                            if (game_state_next[y][x] == 3)
                                full = 0;

                    // ustaw winner/stop_game na podstawie next_state
                    if (win_f) begin
                        winner_next    = win_p;
                        stop_game_next = 1;
                    end else if (full) begin
                        winner_next    = 3; // remis
                        stop_game_next = 1;
                    end
                end
            end
        end
    end

    // ------------------------------------------------------------
    // Sekwencyjna część – rejestry
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            stop_game      <= 0;
            winner         <= 3;
            current_player <= 3;

            for (int y = 0; y < 3; y++)
                for (int x = 0; x < 3; x++)
                    game_state[y][x] <= 3;

        end else begin
            stop_game      <= stop_game_next;
            winner         <= winner_next;
            current_player <= current_player_next;

            for (int y = 0; y < 3; y++)
                for (int x = 0; x < 3; x++)
                    game_state[y][x] <= game_state_next[y][x];
        end
    end

endmodule
