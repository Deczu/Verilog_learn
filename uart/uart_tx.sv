module uart_tx
#(
    parameter CLK_FREQ = 50_000_000, // 50 MHz
    parameter BAUD_RATE = 115200
)
(
    input  logic       clk,
    input  logic       reset,
    input  logic       tx_start,
    input  logic [7:0] data_in,
    output logic       tx_out,
    output logic       busy

);

// zdefiniuj jakie mamy stany
typedef enum logic [1:0] { 
    IDLE,
    START,
    DATA,
    STOP
} state_t;

state_t state;

// Obliczenie dzielnika
localparam int DIV = CLK_FREQ / BAUD_RATE;

// Dzielnik zegara
logic [$clog2(DIV)-1:0] baud_cnt; // do shiftrega
logic baud_tick; // przelacznik

logic [7:0] data_buf;
logic [2:0] bit_cnt;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        $display("[%0t ns] Reset asserted, initializing baud counter", $time);
        baud_cnt  <= 0;
        baud_tick <= 0;
    end else begin
        if (baud_cnt == DIV[$clog2(DIV)-1:0] - 1) begin
            baud_cnt  <= 0;
            baud_tick <= 1;
        end else begin
            baud_cnt  <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end
end


always_ff @(posedge clk or posedge reset) begin
    if(reset) begin
        $display("[%0t ns] Reset asserted, initializing state machine", $time);
        state <= IDLE;
        tx_out <=1;
        busy <= 0;
        bit_cnt <= 0;
    end else if(baud_tick) begin
        $display("[%0t ns] State: %s, Data Buffer: %b, Bit Count: %0d", $time, state.name(), data_buf, bit_cnt);
        case(state)
            IDLE: begin
                if (tx_start) begin
                    state <= START;
                    busy <= 1;
                    data_buf <= data_in;
                end
            end
            START: begin
                tx_out <= 0; // start bit
                bit_cnt <= 0;
                state <= DATA;
            end

            DATA: begin
                $display("[%0t ns] Sending %b bit %0d:%b", $time,  data_buf,bit_cnt, data_buf[bit_cnt]);
                tx_out <= data_buf[bit_cnt]; // wysyłanie bitu
                if (bit_cnt == 7) begin
                    state <= STOP;
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end

            STOP: begin
                $display("[%0t ns] Sending STOP bit", $time);
                tx_out <= 1; // stop bit
                busy <= 0;
                state <= IDLE;
            end
        endcase
    end
    
end

endmodule