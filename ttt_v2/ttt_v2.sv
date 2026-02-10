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
    logic [2:0][2:0][1:0] game_state;
    logic [1:0]           current_player;

    // ------------------------------------------------------------
    // Funkcje pomocnicze
    // ------------------------------------------------------------

    function logic player_valid(input logic [1:0] p, input logic [1:0] current_player);
        return (p == 0 || p == 1) && current_player != p;
    endfunction

    function logic move_valid(
        input logic [1:0] x,
        input logic [1:0] y,
        input logic [1:0] game_state_cell
    );
        return (x < 3 && y < 3 && game_state_cell == 3);
    endfunction

    // Zwraca 1 jeśli ktoś wygrał, ustawia winner
    function logic check_win(input logic [2:0][2:0][1:0] gs, output logic [1:0] win_player);
        win_player = 3;

        // wiersze
        for (int i = 0; i < 3; i++) begin
            if (gs[i][0] == gs[i][1] &&
                gs[i][1] == gs[i][2] &&
                gs[i][0] != 3) begin
                win_player = gs[i][0];
                return 1;
            end
        end

        // kolumny
        for (int i = 0; i < 3; i++) begin
            if (gs[0][i] == gs[1][i] &&
                gs[1][i] == gs[2][i] &&
                gs[0][i] != 3) begin
                win_player = gs[0][i];
                return 1;
            end
        end

        // przekątna lewogóra -> prawo dół
        if (gs[0][0] == gs[1][1] &&
            gs[1][1] == gs[2][2] &&
            gs[0][0] != 3) begin
            win_player = gs[0][0];
            return 1;
        end

        // przekątna lewodół -> prawo góra
        if (gs[0][2] == gs[1][1] &&
            gs[1][1] == gs[2][0] &&
            gs[0][2] != 3) begin
            win_player = gs[0][2];
            return 1;
        end

        return 0;
    endfunction

    // Zwraca 1 jeśli plansza pełna (brak pól == 3)
    function logic board_full(input logic [2:0][2:0][1:0] gs);
        for (int y = 0; y < 3; y++)
            for (int x = 0; x < 3; x++)
                if (gs[y][x] == 3)
                    return 0;
        return 1;
    endfunction

    // ------------------------------------------------------------
    // Logika sekwencyjna
    // ------------------------------------------------------------

    always_ff @(posedge clk) begin
        if (reset) begin
            stop_game      <= 0;
            winner         <= 3;
            current_player <= 3;

            for (int y = 0; y < 3; y++)
                for (int x = 0; x < 3; x++)
                    game_state[y][x] <= 3;

        end else if (enable && !stop_game && player_valid(player, current_player)) begin

            if (move_valid(data_in_x, data_in_y, game_state[data_in_y][data_in_x])) begin
                // przygotuj next state
                logic [2:0][2:0][1:0] game_state_next;
                logic [1:0]           win_player;
                game_state_next = game_state;

                // wykonaj ruch w kopii
                game_state_next[data_in_y][data_in_x] = player;

                // sprawdź wygraną na zaktualizowanej planszy
                if (check_win(game_state_next, win_player)) begin
                    winner    <= win_player;
                    stop_game <= 1;
                end else if (board_full(game_state_next)) begin
                    // remis
                    winner    <= 3;
                    stop_game <= 1;
                end

                // zarejestruj nowy stan
                game_state      <= game_state_next;
                current_player  <= player;

                $display("Enabled! Player %0d moves to (%0d, %0d)", player, data_in_x, data_in_y);
            end
        end
    end

endmodule
