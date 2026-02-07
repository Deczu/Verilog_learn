module counter (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [3:0] count
);

    // Internal logic goes here

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            count <= 0;
        end else if (enable) begin
            count <= count + 1;
        end
    end

endmodule