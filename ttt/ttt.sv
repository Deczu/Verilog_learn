module ttt (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    input  logic [2:0] data_in_x,
    input  logic [2:0] data_in_y,
    output logic winner,
    output logic player,
    output logic stop_game,
    output logic [17:0] board   // 3x3 = 9 komórek, każda 2 bity
);

    // wewnętrzna plansza (NORMALNA, wygodna)
    logic [1:0] board_i [2:0][2:0];
    
    logic last_player;
    logic move_made;

    integer x, y;
    function logic check_winner(logic player);
        // Check rows
        for (y = 0; y < 3; y++) begin
            if (board_i[y][0] == player && board_i[y][1] == player && board_i[y][2] == player) begin
                return 1;
            end
        end

        // Check columns
        for (x = 0; x < 3; x++) begin
            if (board_i[0][x] == player && board_i[1][x] == player && board_i[2][x] == player) begin
                return 1;
            end
        end

        // Check diagonals
        if (board_i[0][0] == player && board_i[1][1] == player && board_i[2][2] == player) begin
            return 1;
        end
        if (board_i[0][2] == player && board_i[1][1] == player && board_i[2][0] == player) begin
            return 1;
        end
        return 0;
    endfunction



    always_ff @(posedge clk) begin
        if (reset) begin
            winner <= 0;
            player <= 0;
            stop_game <= 0;
            move_made <= 0;
            for (y = 0; y < 3; y++)
                for (x = 0; x < 3; x++)
                    board_i[y][x] <= 2;
        end
        else if (enable && !stop_game) begin
            // Sprawdzaj zwycięstwo z POPRZEDNIEGO ruchu
            if (move_made && check_winner(last_player)) begin
                $info("Player %d wins!", last_player);
                winner <= 1;
                stop_game <= 1;
            end
            
            // Rób bieżący ruch
            if (data_in_x < 3 && data_in_y < 3) begin
                board_i[data_in_y][data_in_x] <= player;
                move_made <= 1;
                last_player <= player;
            end else begin
                move_made <= 0;
            end
            
            // Zawsze przełączaj gracza (także przy zwycięstwie)
            player <= ~player;
        end else begin
            move_made <= 0;
        end
    end

    // -------- FLATTENING --------
    // board[2*(y*3 + x) + 1 : 2*(y*3 + x)] = board_i[y][x]
    always_comb begin
        board = '0;
        for (y = 0; y < 3; y++)
            for (x = 0; x < 3; x++)
                board[2*(y*3 + x) +: 2] = board_i[y][x];
    end

endmodule
