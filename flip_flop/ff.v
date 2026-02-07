// File : d_ff.v
module d_ff (clk, resetn, q, d);

	input clk;
	input resetn;
	input reg[2:0] d;
	output q;

	reg q;

	always @ (posedge clk)
		if (! resetn)
			q <= 0;
		else
			q <= d;
        // $display("t=%0t | q=%b", $time, q);

endmodule