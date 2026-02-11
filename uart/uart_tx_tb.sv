`timescale 1ns/1ps

module uart_tx_tb;

    logic clk;
    logic reset;
    logic tx_start;
    logic [7:0] data_in;
    logic tx_out;
    logic busy;

    // instancja DUT
    uart_tx dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx_out(tx_out),
        .busy(busy)
    );

    // zegar 50 MHz
    always #10 clk = ~clk;

    // zmienne pomocnicze
    logic [9:0] expected_frame;
    logic [9:0] received_frame;
    int i;

    // TASK zgodny z Verilatorem
    task send_and_check(input [7:0] data_byte);
        begin
            // budujemy ramkę UART
            expected_frame[0]   = 0;          // start
            expected_frame[9]   = 1;          // stop
            expected_frame[8:1] = data_byte;  // dane LSB-first

            $display("\n=== TEST: Wysyłam bajt %b ===", data_byte);

            // wyzwolenie transmisji
            data_in  = data_byte;
            tx_start = 1;

            // czekamy aż UART zacznie transmisję
            wait (busy == 1);
            tx_start = 0;

            // *** KLUCZOWA ZMIANA ***
            // Czekamy aż UART wejdzie w START (start bit ustawiony)
            wait (dut.state == dut.START);
            @(posedge dut.baud_tick);
            for (i = 0; i < 10; i++) begin
                @(posedge dut.baud_tick);
                received_frame[i] = tx_out;
                $display("[%0t ns] Odebrano bit %0d = %b", $time, i, tx_out);
            end

            // porównanie
            if (received_frame === expected_frame) begin
                $display(">>> PASS: Odebrana ramka poprawna: %b", received_frame);
            end else begin
                $display(">>> FAIL: Oczekiwano %b, otrzymano %b",
                         expected_frame, received_frame);
            end

        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        data_in = 0;

        #100 reset = 0;

        // testy
        send_and_check(8'b11110000);
        send_and_check(8'b10101010);
        send_and_check(8'b00000000);
        send_and_check(8'b11111111);

        $finish;
    end

endmodule
