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
    localparam INPUT_LATCH   = 4'b0001;
    localparam ADX_SETUP_HI   = 4'b0010;
    localparam EN_HI_1    = 4'b0011;
    localparam EN_HI_2    = 4'b0100;
    localparam EN_HI_3    = 4'b0101;
    localparam EN_EDGE_HI   = 4'b0110;
    localparam ADX_SETUP_LO   = 4'b0111;
    localparam EN_LO_1    = 4'b1000;
    localparam EN_LO_2    = 4'b1001;
    localparam EN_LO_3    = 4'b1010;
    localparam EN_EDGE_LO = 4'b1011;

    localparam INTER_NIBBLE = 6'b01_1000; // 32 clocks delay between high and low nibble 
    
    reg [3:0] current_state, next_state;
    reg current_rs, next_rs;
    reg current_rw, next_rw;
    reg current_enable, next_enable;
    reg [7:0] current_data, next_data;
    reg [3:0] current_out, next_out;

    reg [5:0] ticks_end_in;
    reg start_timer_in;
    wire timer_done;

    timer signal_stretch_timer (
        .clk(clk),
        .rst(rst),
        .start(start_timer_in),
        .ticks(ticks_end_in),
        .done(timer_done)
    );

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
            IDLE:  next_state = start ? INPUT_LATCH : IDLE;
            INPUT_LATCH:        next_state = ADX_SETUP_HI;
            ADX_SETUP_HI:       next_state = EN_HI_1;
            EN_HI_1:            next_state = EN_HI_2;
            EN_HI_2:            next_state = EN_HI_3;
            EN_HI_3:            next_state = EN_EDGE_HI;
            EN_EDGE_HI:         next_state = timer_done ? ADX_SETUP_LO : EN_EDGE_HI;
            ADX_SETUP_LO:       next_state = EN_LO_1;
            EN_LO_1:            next_state = EN_LO_2;
            EN_LO_2:            next_state = EN_LO_3;
            EN_LO_3:            next_state = EN_EDGE_LO;
            EN_EDGE_LO:         next_state = IDLE;
            default:            next_state = IDLE;
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
            ADX_SETUP_HI: next_enable = 1;
            EN_HI_1: next_enable = 1;
            EN_HI_2: next_enable = 1;
            ADX_SETUP_LO: next_enable = 1;
            EN_LO_1: next_enable = 1;
            EN_LO_2: next_enable = 1;
            default: next_enable = 0;
        endcase

        case (current_state)
            IDLE:  next_data = start ? datain : current_data;
            default: next_data = current_data;
        endcase

        case (current_state)
            ADX_SETUP_HI: next_out = current_data[7:4];
            ADX_SETUP_LO: next_out = current_data[3:0];
            default: next_out = current_out;
        endcase
    end

    always @(*) begin
        rs_out = current_rs;
        rw_out = current_rw;
        enable = current_enable;
        dataout = next_out;
    end

  always @(*) begin
        case (current_state)
            EN_HI_3: 
            begin
                start_timer_in = 1;
                ticks_end_in = INTER_NIBBLE;
            end
            default: 
            begin
                start_timer_in = 0;
                ticks_end_in = 6'b000000;
            end
        endcase
  end

endmodule

module timer(
    input clk,
    input rst,
    input start,
    input [5:0] ticks,
    output reg done
);

    localparam IDLE       = 2'b00;
    localparam RUNNING    = 2'b01;
    localparam DONE       = 2'b10;

    reg [1:0] timer_state;
    reg [1:0] next_timer_state;
    
    reg [5:0] current_tick;
    reg [5:0] next_current_tick;

    reg [5:0] expires_tick;
    reg [5:0] next_expires_tick;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_state <= IDLE;
            current_tick <= 0;
            next_current_tick <= 0;
            expires_tick <= 0;
            next_expires_tick <= 0;
        end else begin
            timer_state <= next_timer_state;
            expires_tick <= next_expires_tick;
            current_tick <= next_current_tick;
        end
    end

    always @(*) begin
        case (timer_state)
            IDLE: 
            begin
                next_timer_state = start ? RUNNING : IDLE;
                next_expires_tick = start ? ticks : next_expires_tick;
                next_current_tick = current_tick;
                done = 0;
            end
            RUNNING:
            begin
                next_timer_state = (current_tick + 1 == expires_tick) ? DONE : RUNNING;
                next_expires_tick = expires_tick;
                next_current_tick = current_tick + 1;
                done = 0;
            end
            DONE:
            begin
                next_timer_state = IDLE;
                done = 1;
            end
        endcase
    end


endmodule