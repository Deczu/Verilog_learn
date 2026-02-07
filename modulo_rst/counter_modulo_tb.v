`timescale 1ns/1ps

module counter_modulo_tb;

    reg clk;
    reg rst_n;
    wire [3:0] count;
    wire tick;
    wire [3:0] data_in;
    wire [7:0] buffer_out;
    wire [7:0] circular_buffer [0:15];

    // Ustawiamy małe MODULO, żeby symulacja była krótka
    localparam MODULO_TB = 5;

    // Instancja modułu testowanego
    counter_modulo #(
        .MODULO(MODULO_TB),
        .WIDTH(4)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count),
        .tick(tick),
        .data_in(data_in),
        .buffer_out(buffer_out),
        .circular_buffer(circular_buffer)
    );
    initial begin
        $dumpfile("wave.vcd");
    end

    // Generowanie zegara 50 MHz → okres 20 ns
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Reset + przebieg symulacji
    initial begin
        $display("Start symulacji");
        rst_n = 0;
        #50; // trzymamy reset przez 50 ns
        rst_n = 1;
        #500; //tutaj sobie leci symulacja w sensie czas symualcji
        $display("Koniec symulacji");
        $finish;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, counter_modulo_tb);
    end
    // Monitorowanie zmian
    initial begin
        $monitor("t=%0t | count=%0d | tick=%b", $time, count, tick);
    end

endmodule
