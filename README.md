# Verilog_learn
iverilog -g2012 -o sim.out 8bit.sv 8bit_tb.sv | vvp sim.out
gtkwave wave.vcd 

verilator --prefix Vsim --binary --build-jobs 0 '--build' '--trace' '--build' '-Wno-fatal' '--timescale' '1ns/1ns' ttt_v2.sv ttt_tb_v2.sv  && obj_dir/Vsim