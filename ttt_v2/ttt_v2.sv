module tttv2 (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    input  logic [1:0] data_in_x,
    input  logic [1:0] data_in_y,
    input  logic [1:0] player,
    output logic winner,
    output logic stop_game

);

    logic [2:0][2:0][1:0] game_state;// packed 2D array to hold the state of the game, 3 means empty, 0 and 1 for players
    logic [1:0] current_player;

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

    function logic check_if_endgame(logic [1:0] game_state [0:2][0:2]);
        return 0; // Placeholder, implementacja sprawdzania wygranej lub remisu
        
    endfunction



    always_ff @(posedge clk) begin
        if (reset) begin 
            winner <= 0;
            stop_game <= 0;
            current_player <= 3; // no player
            for (int y = 0; y < 3; y++)
                for (int x = 0; x < 3; x++)
                    game_state[y][x] <= 3; // puste
                
        end else if (enable && player_valid(player,current_player)) begin
            if (move_valid(data_in_x, data_in_y, game_state[data_in_y][data_in_x])) begin
                $display("Enabled! Player %0d moves to (%0d, %0d)", player, data_in_x, data_in_y);
                current_player <= player;
                game_state[data_in_y][data_in_x] <= player;
            end
        end

    end


endmodule
