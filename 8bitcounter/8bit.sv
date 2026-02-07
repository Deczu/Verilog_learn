module counter_8bit (clk, reset, enable, dir, count);

	input logic clk;
	input wire reset;
    input wire enable;
    input wire dir;
    output logic [7:0] count;

    function logic [7:0] indec(input logic [7:0] count, input dir);
        if (dir) begin
            return count + 1;
        end else begin
            return count - 1;
        end      
    endfunction


	always_ff @ (posedge clk) begin
        if (reset) begin
			count <= 0;
        end else if (enable) begin
            count <= indec(count, dir);
        end else begin
            count <= count;
        end
    end

endmodule
