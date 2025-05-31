module simple_fsm (
    input clk,
    input rst,
    input in,
    output reg [1:0] state
);

    localparam IDLE = 2'b00;
    localparam S1   = 2'b01;
    localparam S2   = 2'b10;

    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE:  next_state = in ? S1 : IDLE;
            S1:    next_state = in ? S2 : IDLE;
            S2:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        state = current_state;
    end

endmodule
