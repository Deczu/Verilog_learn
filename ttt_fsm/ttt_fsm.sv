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

    // 3x3 plansza
    logic [1:0] game_state      [0:2][0:2];
    logic [1:0] game_state_next [0:2][0:2];

    logic [1:0] current_player, current_player_next;
    logic [1:0] winner_next;
    logic       stop_game_next;

    logic [1:0] win_p;
    logic       win_f;
    logic       full;

    // FSM
    typedef enum logic [1:0] {
        S_IDLE,
        S_WAIT_MOVE,
        S_CHECK
    } state_t;

    state_t state, state_next;

    // ------------------------------------------------------------
    // FSM next state
    // ------------------------------------------------------------
    always_comb begin
        state_next = state;

        unique case (state)
            S_IDLE:
                if (enable)
                    state_next = S_WAIT_MOVE;

            S_WAIT_MOVE:
                state_next = S_CHECK;

            S_CHECK:
                state_next = S_WAIT_MOVE;

            default:
                state_next = S_IDLE;
        endcase
    end

    // ------------------------------------------------------------
    // Logika gry
    // ------------------------------------------------------------
    always_comb begin
        // domyślne wartości
        for (int y = 0; y < 3; y++)
            for (int x = 0; x < 3; x++)
                game_state_next[y][x] = game_state[y][x];

        current_player_next = current_player;
        winner_next         = winner;
        stop_game_next      = stop_game;

        win_p = 3;
        win_f = 0;
        full  = 1;

        case (state)

            // ----------------------------------------------------
            // Odczyt ruchu + walidacja + zapis
            // ----------------------------------------------------
            S_WAIT_MOVE: begin
                if (!stop_game) begin
                    if ((player == 0 || player == 1) &&
                        player != current_player &&
                        data_in_x < 3 && data_in_y < 3 &&
                        game_state[data_in_y][data_in_x] == 3) begin

                        game_state_next[data_in_y][data_in_x] = player;
                        current_player_next = player;
                    end
                end
            end

            // ----------------------------------------------------
            // Sprawdzenie wygranej / remisu
            // ----------------------------------------------------
            S_CHECK: begin
                // wiersze
                for (int y = 0; y < 3; y++)
                    if (game_state_next[y][0] == game_state_next[y][1] &&
                        game_state_next[y][1] == game_state_next[y][2] &&
                        game_state_next[y][0] != 3) begin
                        win_p = game_state_next[y][0];
                        win_f = 1;
                    end

                // kolumny
                for (int x = 0; x < 3; x++)
                    if (game_state_next[0][x] == game_state_next[1][x] &&
                        game_state_next[1][x] == game_state_next[2][x] &&
                        game_state_next[0][x] != 3) begin
                        win_p = game_state_next[0][x];
                        win_f = 1;
                    end

                // przekątne
                if (game_state_next[0][0] == game_state_next[1][1] &&
                    game_state_next[1][1] == game_state_next[2][2] &&
                    game_state_next[0][0] != 3) begin
                    win_p = game_state_next[0][0];
                    win_f = 1;
                end

                if (game_state_next[0][2] == game_state_next[1][1] &&
                    game_state_next[1][1] == game_state_next[2][0] &&
                    game_state_next[0][2] != 3) begin
                    win_p = game_state_next[0][2];
                    win_f = 1;
                end

                // pełna plansza?
                full = 1;
                for (int y = 0; y < 3; y++)
                    for (int x = 0; x < 3; x++)
                        if (game_state_next[y][x] == 3)
                            full = 0;

                // ustaw winner/stop_game
                if (win_f) begin
                    winner_next    = win_p;
                    stop_game_next = 1;
                end else if (full) begin
                    winner_next    = 3;
                    stop_game_next = 1;
                end
            end

            default: begin
                // S_IDLE – nic nie robimy
            end
        endcase
    end

    // ------------------------------------------------------------
    // Rejestry
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            state          <= S_IDLE;
            stop_game      <= 0;
            winner         <= 3;
            current_player <= 3;

            for (int y = 0; y < 3; y++)
                for (int x = 0; x < 3; x++)
                    game_state[y][x] <= 3;

        end else begin
            state          <= state_next;
            stop_game      <= stop_game_next;
            winner         <= winner_next;
            current_player <= current_player_next;

            for (int y = 0; y < 3; y++)
                for (int x = 0; x < 3; x++)
                    game_state[y][x] <= game_state_next[y][x];
        end
    end

endmodule
