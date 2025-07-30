module Uart_RX (

    input clk_3125,
    input rx,
    output reg [0:7] rx_msg,
    output reg rx_parity,
    output reg rx_complete

);

parameter START = 4'b0000, BIT0 = 4'b0001, BIT1 = 4'b0010, BIT2 = 4'b0011, BIT3 = 4'b0100, BIT4 = 4'b0101, BIT5 = 4'b0110, BIT6 = 4'b0111, BIT7 = 4'b1000, PARITY = 4'b1001, STOP = 4'b1010, IDLE = 4'b1111;

reg [3:0] state = IDLE;
reg [4:0] counter = 0;
reg [7:0] rx_prev_msg = 0;
reg rx_prev_parity = 0;
reg rx_used_here = 0;

initial begin

    rx_msg = 0;
	rx_parity = 0;
    rx_complete = 0;

end

always @(posedge clk_3125) begin

    if (rx_complete) rx_complete = 0;

    if (counter == 28) begin

        case (state)

            START: state = BIT0;

            BIT0: {state, rx_prev_msg} <= {BIT1, rx_used_here, 7'b0000000};

            BIT1: {state, rx_prev_msg} <= {BIT2, rx_prev_msg[7], rx_used_here, 6'b000000};

            BIT2: {state, rx_prev_msg} <= {BIT3, rx_prev_msg[7:6], rx_used_here, 5'b00000};

            BIT3: {state, rx_prev_msg} <= {BIT4, rx_prev_msg[7:5], rx_used_here, 4'b0000};

            BIT4: {state, rx_prev_msg} <= {BIT5, rx_prev_msg[7:4], rx_used_here, 3'b000};

            BIT5: {state, rx_prev_msg} <= {BIT6, rx_prev_msg[7:3], rx_used_here, 2'b00};

            BIT6: {state, rx_prev_msg} <= {BIT7, rx_prev_msg[7:2], rx_used_here, 1'b0};

            BIT7: {state, rx_prev_msg} <= {PARITY, rx_prev_msg[7:1], rx_used_here};

            PARITY: {state, rx_prev_parity} <= {STOP, rx_used_here};

            STOP: begin

                {state, rx_parity, rx_complete} <= {IDLE, rx_prev_parity, 1'b1};
                rx_msg <= (rx_prev_parity === (^rx_prev_msg) ? 1'b1 : 1'b0) ? rx_prev_msg : 8'h3F;

            end

            default;

        endcase

        counter = 1;

    end

    counter <= counter + 1;
	rx_used_here = rx;

    if (state == IDLE && rx == 1'b0) state = START;

end

endmodule
