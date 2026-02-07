module counter_modulo #(                    // Deklaracja modułu counter_modulo z parametrami
    parameter integer MODULO = 14,      // Parametr: wartość maksymalna licznika (0..MODULO-1)
    parameter integer WIDTH  = 4        // Parametr: szerokość licznika w bitach
)(                                      // Początek portu
    input  wire clk,                    // Port wejściowy: sygnał zegara
    input  wire rst_n,                  // Port wejściowy: sygnał resetu aktywny w stanie niskim
    output reg [WIDTH-1:0] count,       // Port wyjściowy: wartość licznika (rejestr)
    output wire tick,                   // Port wyjściowy: impuls przy przepełnieniu licznika
    output reg [WIDTH-1:0] data_in,     // Port wyjściowy: dane wejściowe do bufora
    output reg [7:0] circular_buffer [0:15],   // Deklaracja tablicy: bufor kołowy 16 elementów po 8 bitów
    output reg [7:0] buffer_out         // Port wyjściowy: aktualna wartość z bufora

);                                      // Koniec portu
    assign tick = (count == MODULO-1);  // Logika kombinacyjna: tick=1 gdy licznik osiągnie MODULO-1
    always @(posedge clk or negedge rst_n) begin  // Blok sekwencyjny: wyzwalany na zboczu rosnącym zegara lub spadaniu resetu
        if (!rst_n) begin                          // Jeśli reset jest aktywny (rst_n=0)
            count <= 0;                            // Resetuj licznik na 0
            data_in <= 0;                          // Resetuj dane_in na 0
            buffer_out <= 0;                        // Resetuj buffer_out na 0
            
            
        end else begin                             // W innym przypadku (reset nieaktywny)
            $display("t=%0t | count=%0d", $time, count);  // Wyświetl czas i aktualną wartość licznika
            if (tick)                              // Jeśli licznik osiągnął maksimum
                count <= 0;                        // Resetuj licznik do 0 (przepełnienie)
                                               // W innym przypadku
            circular_buffer[count] <= data_in; // Zapisz data_in do bufora na pozycji count
            buffer_out <= circular_buffer[count]; // Odczytaj wartość z bufora na pozycji count
            count <= count + 1;
            data_in <= data_in + 1;                // Zwiększ data_in o 1
        end                                        // Koniec bloku else
    end                                            // Koniec bloku always

endmodule                                          // Koniec modułu
