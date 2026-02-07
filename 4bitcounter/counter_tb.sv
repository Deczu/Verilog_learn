// File : tb_top.sv
module tb_top ();
// module counter (
//     input logic clk,
//     input logic rst,
//     input logic enable,
//     output logic [3:0] count
// );
	reg clk;
	reg rst;
	reg enable;
	wire [3:0] count;

	// Instantiate the design
	counter counter0 (	.clk (clk),
		       		.rst (rst),
		       		.enable (enable),
		       		.count (count));

	// Create a clock
	initial clk = 0;
	always #10 clk = ~clk;

	initial begin
		rst = 0;
		enable = 0;

		#10 rst = 1;
		#10 enable = 1;
		#100;
        #10 enable = 0;
        #100;
		$finish;
	end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end
	initial begin
		$monitor("t=%0t | count=%b", $time, count);
	end
endmodule