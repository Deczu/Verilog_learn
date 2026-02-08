module tttv2 (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    input  logic [2:0] data_in_x,
    input  logic [2:0] data_in_y,
    input  logic [1:0] player,
    output logic winner,
    output logic stop_game

);

    logic [1:0] game_state [0:2][0:2]; // 3x3 = 9 komórek, każda 3 bity (0,1 - gracze, 2 - puste)
    logic [1:0] current_player;

    function logic player_valid(input logic [1:0] p, input logic [1:0] current_player);
        return (p == 0 || p == 1) && current_player != p;
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
            current_player <= player;
            if (data_in_x < 3 && data_in_y < 3) begin
                game_state[data_in_y][data_in_x] <= player;
            end
        end

    end


endmodule
