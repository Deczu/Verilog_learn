module ttt (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    input  logic [2:0] data_in_x,
    input  logic [2:0] data_in_y,
    output logic winner,
    output logic player,
    output logic [17:0] board   // 3x3 = 9 komórek, każda 2 bity
);

    // wewnętrzna plansza (NORMALNA, wygodna)
    logic [1:0] board_i [2:0][2:0];

    integer x, y;
    function logic check_winner(logic player);
        // Check rows
        $info("Player to check %d", player);
        for (y = 0; y < 3; y++) begin
            if (board_i[y][0] == player && board_i[y][1] == player && board_i[y][2] == player) begin
                $info("Row %d is a win for player %d", y, player);
                return 1;
            end
        end

        // Check columns
        for (x = 0; x < 3; x++) begin
            if (board_i[0][x] == player && board_i[1][x] == player && board_i[2][x] == player) begin
                $info("Col %d is a win for player %d", x, player);
                return 1;
            end
        end

        // Check diagonals
        if (board_i[0][0] == player && board_i[1][1] == player && board_i[2][2] == player) begin
            $info("diag 1 is a win for player %d", player);
            return 1;
        end
        if (board_i[0][2] == player && board_i[1][1] == player && board_i[2][0] == player) begin
            $info("diag 2 is a win for player %d", player);
            return 1;
        end
        return 0;
    endfunction



    always_ff @(posedge clk) begin
        if (reset) begin
            winner <= 0;
            player <= 0;
            for (y = 0; y < 3; y++)
                for (x = 0; x < 3; x++)
                    board_i[y][x] <= 2;
        end
        else if (enable) begin
            if (data_in_x < 3 && data_in_y < 3)  board_i[data_in_y][data_in_x] <= player + 1;  // 1 lub 2
            $info("Player %d moves to (%d, %d)", player, data_in_x, data_in_y);
            if (check_winner(player)) winner <= 1;  // sprawdzaj dla player+1
            player <= ~player; // toggle player
        end else begin
            player <= player;
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
