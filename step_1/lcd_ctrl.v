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

    localparam IDLE       = 4'b0000;
    localparam ADX_SU_1   = 4'b0001;
    localparam ADX_SU_2   = 4'b0010;
    localparam EN_HI_1    = 4'b0011;
    localparam EN_HI_2    = 4'b0100;
    localparam EN_HI_3    = 4'b0101;
    localparam ADX_SU_3   = 4'b0110;
    localparam ADX_SU_4   = 4'b0111;
    localparam EN_LO_1    = 4'b1000;
    localparam EN_LO_2    = 4'b1001;
    localparam EN_LO_3    = 4'b1010;
    
    reg [3:0] current_state, next_state;
    reg current_rs, next_rs;
    reg current_rw, next_rw;
    reg current_enable, next_enable;
    reg [7:0] current_data, next_data;
    reg [3:0] current_out, next_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            rs_out <= 0;
            rw_out <= 0;
            current_rs <= 0;
            current_rw <= 0;
            current_data <= 0;
            current_out <= 0;
            current_enable <= 0;
            enable <= 0;
            dataout <= 0;
        end else begin
            current_state <= next_state;
            current_rs <= next_rs;
            current_rw <= next_rw;
            current_data <= next_data;
            current_enable <= next_enable;
            current_out <= next_out;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE:  next_state = start ? ADX_SU_1 : IDLE;
            ADX_SU_1:    next_state = ADX_SU_2;
            ADX_SU_2:    next_state = EN_HI_1;
            EN_HI_1:    next_state = EN_HI_2;
            EN_HI_2:    next_state = EN_HI_3;
            EN_HI_3:    next_state = ADX_SU_3;
            ADX_SU_3:   next_state = ADX_SU_4;
            ADX_SU_4:   next_state = EN_LO_1;
            EN_LO_1:    next_state = EN_LO_2;
            EN_LO_2:    next_state = EN_LO_3;
            EN_LO_3:    next_state = IDLE;
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
            ADX_SU_2: next_enable = 1;
            EN_HI_1: next_enable = 1;
            EN_HI_2: next_enable = 1;
            ADX_SU_4: next_enable = 1;
            EN_LO_1: next_enable = 1;
            EN_LO_2: next_enable = 1;
            default: next_enable = 0;
        endcase

        case (current_state)
            IDLE:  next_data = start ? datain : current_data;
            default: next_data = current_data;
        endcase

        case (current_state)
            ADX_SU_2: next_out = current_data[7:4];
            ADX_SU_4: next_out = current_data[3:0];
            default: next_out = current_out;
        endcase
    end

    always @(*) begin
        rs_out = current_rs;
        rw_out = current_rw;
        enable = current_enable;
        dataout = next_out;
    end

endmodule
