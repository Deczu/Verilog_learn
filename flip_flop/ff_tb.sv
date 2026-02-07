// File : tb_top.sv
module tb_top ();

	reg clk;
	reg resetn;
	reg [2:0] d;
	wire q;

	// Instantiate the design
	d_ff  d_ff0 (	.clk (clk),
		       		.resetn (resetn),
		       		.d (d),
		       		.q (q));

	// Create a clock
	initial clk = 0;
	always #10 clk <= ~clk;

	initial begin
		resetn <= 0;
		d <= 0;

		#10 resetn <= 1;
		for (integer i = 0; i < 100; i = i + 1) begin
			#20 d <= 1;
			#20 d <= 0;
		end

		$finish;
	end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end
	initial begin
        $monitor("t=%0t | q=%b", $time, q);
    end
endmodule