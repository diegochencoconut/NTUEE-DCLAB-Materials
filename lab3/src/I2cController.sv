module I2cController (
    input[23:0]    i_data,          // the data sending right now
    input          i_clk,           // input 100khz clock
    input          i_rst_n,         // false if resetting
    input          i_start,         // start sending the data sent
    output         o_en,            // false only if not sending (acknowledging)
    output         o_SDA,           // output SDA state
    output         o_SCL,           // output SCL state
    output         o_finished       // the data sending now is finished
);

// for send_state
parameter S_IDLE      = 4'd0;     // The system is in idle        SDA == 1, SCL == 1

parameter S_START     = 4'd1;     // Start sending data           SDA -> 0, SCL == 1
parameter S_SETUP     = 4'd2;     // Setup SCL                    SDA -> 0, SCL -> 0
// ======= return to when datacounter < 7 ========
parameter S_RISE      = 4'd3;     // changing data                SDA -> d, SCL -> 0
parameter S_SEND      = 4'd4;     // sending data                 SDA == d, SCL -> 1
parameter S_HOLD      = 4'd5;     // holding data                 SDA == d, SCL == 1
parameter S_AFTERSEND = 4'd6;     // pull SCL down after sent     SDA == d, SCL -> 0
// ============= datacounter adding ==============
// ====== return from when datacounter < 7 =======

parameter S_CHANGEALK = 4'd7;     // clock low to send SDA -> z   SDA -> Z, SCL -> 0
parameter S_WAITALK   = 4'd8;     // wait for ALK                 SDA == Z, SCL -> 1
parameter S_HOLDALK   = 4'd9;     // hold for ALK                 SDA == Z, SCL == 1
// ============ cyclecounter adding ==============
// ====== return from when cyclecounter = 3 ======

parameter S_COOLDOWN  = 4'd10;
parameter S_STOPDOWN  = 4'd11;
parameter S_STOPSET   = 4'd12;
parameter S_STOP      = 4'd13;

logic[23:0]  data_r, data_w;
logic[3:0]   datacounter_r, datacounter_w;
logic[1:0]   cyclecounter_r, cyclecounter_w;

logic sda_r, sda_w;
logic scl_r, scl_w;
logic en_r, en_w;
logic finish_r, finish_w;

logic[3:0]  i2c_state_r, i2c_state_w;

assign o_en = en_r;
assign o_SDA = sda_r;
assign o_SCL = scl_r;
assign o_finished = finish_r;

always_comb begin
    data_w = data_r;
    datacounter_w = datacounter_w;
    sda_w = sda_r;
    scl_w = scl_r;
    en_w = en_r;
    i2c_state_w = i2c_state_r;
    finish_w = 1'b0;

    // if (i_start) begin
    //     data_w = i_data;
    //     i2c_state_w = S_START;
    //     datacounter_w = 0;
    //     cyclecounter_w = 0;
    //     en_w = 1'b1;
    // end

    case (i2c_state_r)

        S_IDLE: begin       // The system is in idle        SDA == 1, SCL == 1
            sda_w = 1'b1;
            scl_w = 1'b1;

            en_w = 1'b1;

            datacounter_w = 0;
            cyclecounter_w = 0;
        end

        S_START: begin      // Start sending new data       SDA -> 0, SCL == 1
            sda_w = 1'b0;
            scl_w = 1'b1;

            i2c_state_w = S_SETUP;
        end

        S_SETUP: begin      // Setup SCL                    SDA -> 0, SCL -> 0
            sda_w = 1'b0;
            scl_w = 1'b0;

            i2c_state_w = S_RISE;
        end

        S_RISE: begin       // changing data                SDA -> d, SCL -> 0
            sda_w = data_r[23];
            scl_w = 1'b0;

            data_w = data_r << 1;
            datacounter_w = datacounter_r + 1;

            i2c_state_w = S_SEND;
        end

        S_SEND: begin       // sending data                 SDA == d, SCL -> 1
            sda_w = sda_r;
            scl_w = 1'b1;

            i2c_state_w = S_HOLD;
        end

        S_HOLD: begin       // holding data                 SDA == d, SCL == 1
            sda_w = sda_r;
            scl_w = 1'b1;

            i2c_state_w = S_AFTERSEND;
        end

        S_AFTERSEND: begin  // pull SCL down after sent     SDA == d, SCL -> 0
            sda_w = sda_r;
            scl_w = 1'b0;

            // if datacounter < 7: keep this cycle
            // if datacounter = 7: go to next cycle
            if (datacounter_r < 4'd8) begin
                i2c_state_w = S_RISE;
            end
            else if (datacounter_r == 4'd8) begin
                i2c_state_w = S_CHANGEALK;
            end
        end

        S_CHANGEALK: begin  // clock low to send SDA -> z   SDA -> Z, SCL -> 0
            sda_w = 1'bz;
            scl_w = 1'b0;

            en_w = 1'b0;        // since it is not outputing right now

            i2c_state_w = S_WAITALK;    
        end

        S_WAITALK: begin        // wait for ALK             SDA == Z, SCL -> 1
            sda_w = 1'bz;
            scl_w = 1'b1;
            
            en_w = 1'b0;

            i2c_state_w = S_HOLDALK;

        end
        S_HOLDALK: begin       // hold for ALK              SDA == Z, SCL == 1
            sda_w = 1'bz;
            scl_w = 1'b1;

            en_w = 1'b0;

            i2c_state_w = S_COOLDOWN;
        end

        S_COOLDOWN: begin
            sda_w = sda_r;
            scl_w = 1'b0;

            en_w = 1'b1;

            cyclecounter_w = cyclecounter_r + 1;
            if (cyclecounter_r < 2'd2)  begin
                i2c_state_w = S_RISE;
                datacounter_w = 3'd0;
            end
            if (cyclecounter_r == 2'd2)  begin
                i2c_state_w = S_STOPDOWN;
            end
        end

        S_STOPDOWN: begin
            sda_w = 1'b0;
            scl_w = 1'b0;

            i2c_state_w = S_STOPSET;
        end

        S_STOPSET: begin
            sda_w = 1'b0;
            scl_w = 1'b1;

            i2c_state_w = S_STOP;
        end

        S_STOP: begin
            sda_w = 1'b1;
            scl_w = 1'b1;

            i2c_state_w = S_IDLE;
            finish_w = 1'b1;

        end

    endcase
end

always_ff @(negedge i_rst_n or posedge i_clk or posedge i_start) begin
    if (!i_rst_n) begin
        data_r <= 24'b0;
        datacounter_r <= 3'b0;
        cyclecounter_r <= 2'b0;
        sda_r <= 1'b1;
        scl_r <= 1'b1;
        en_r <= 1'b1;
        i2c_state_r <= S_IDLE;
        finish_r <= 1'b0;
    end
    else if (i_start) begin
        data_r <= i_data;
        datacounter_r <= 3'b0;
        cyclecounter_r <= 2'b0;
        sda_r <= 1'b1;
        scl_r <= 1'b1;
        en_r <= 1'b1;
        i2c_state_r <= S_START;
        finish_r <= 1'b0;
    end
    else begin
        data_r <= data_w;
        datacounter_r <= datacounter_w;
        cyclecounter_r <= cyclecounter_w;
        sda_r <= sda_w;
        scl_r <= scl_w;
        en_r <= en_w;
        i2c_state_r <= i2c_state_w;
        finish_r <= finish_w;
    end
end

endmodule