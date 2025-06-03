module lcd_ctrl (
    input clk,
    input rst,
    input rs,
    input rw,
    input [7:0] datain,
    input start,
    output reg rs_out,
    output reg rw_out,
    output reg enable, 
    output reg [3:0] dataout
);

    localparam IDLE = 2'b00;
    localparam S1   = 2'b01;
    localparam S2   = 2'b10;
    localparam S3   = 2'b11;
    
    reg [1:0] current_state, next_state;
    reg current_rs, next_rs;
    reg current_rw, next_rw;
    reg current_enable, next_enable;
    reg [7:0] current_data, next_data;

    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            rs_out <= 0;
            rw_out <= 0;
            enable <= 0;
            dataout <= 0;
        end
        else
            current_state <= next_state;
            current_rs <= next_rs;
            current_rw <= next_rw;
            current_data <= next_data;
            current_enable <= next_enable;
    end

    always @(*) begin
        case (current_state)
            IDLE:  next_state = start ? S1 : IDLE;
            S1:    next_state = S2;
            S2:    next_state = S3;
            S3:    next_state = IDLE;
            default: next_state = IDLE;
        endcase

        case (current_state)
            IDLE:  next_rs = start ? rs : current_rs;
            default: next_rs = current_rs;
        endcase

        case (current_state)
            IDLE:  next_rw = start ? rw : current_rw;
            default: next_rw = current_rw;
        endcase 

        case (current_state)
            S2: next_enable = 1;
            default: next_enable = 0;
        endcase

        case (current_state)
            IDLE:  next_data = start ? datain : current_data;
            default: next_data = current_data;
        endcase
    end

    always @(*) begin
        state = current_state;
        rs_out = current_rs;
        rw_out = current_rw;
        enable = current_enable;
        dataout = current_data[7:4];
    end

endmodule
