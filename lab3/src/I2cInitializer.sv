module I2cInitializer (
    input i_rst_n,
	input i_clk,
	// input i_start,
	output o_finished,
	output o_sclk,
	output o_sdat,
	output o_oen // you are outputing (you are not outputing only when you are "ack"ing.)
);

logic       state_finished;
logic       state_start_w, state_start_r;
logic[23:0] data_w, data_r;

logic       finished;
assign o_finished = finished;

I2cController i2ccontroller(
    .i_data(data_r),
    .i_clk(i_clk),
    .i_start(state_start_r),
    .i_rst_n(i_rst_n),
    .o_en(o_oen),
    .o_SDA(o_sdat),
    .o_SCL(o_sclk),
    .o_finished(state_finished)
);


// for data_state
parameter IDLE          = 3'd0;
parameter RESET         = 3'd1;
parameter ANALOGUE      = 3'd2;
parameter DIGITALPATH   = 3'd3;
parameter POWERDOWN     = 3'd4;
parameter DIGITALAUDIO  = 3'd5;
parameter SAMPLING      = 3'd6;
parameter ACTIVE        = 3'd7;

// for data_val, refer to course slides
parameter RESET_DATA        = 24'b001101000001111000000000;
parameter ANALOGUE_DATA     = 24'b001101000000100000010101;
parameter DIGITALPATH_DATA  = 24'b001101000000101000000000;
parameter POWERDOWN_DATA    = 24'b001101000000110000000000;
parameter DIGITALAUDIO_DATA = 24'b001101000000111001000010;
parameter SAMPLING_DATA     = 24'b001101000001000000011001;
parameter ACTIVE_DATA       = 24'b001101000001001000000001;

logic[2:0] data_state_r, data_state_w;

parameter NOTLOADED     = 2'd0;
parameter DATALOADED    = 2'd1;
parameter RUNNING       = 2'd2;

logic[1:0] loaded_r, loaded_w;

always_comb begin
    data_w = data_r;
    state_start_w = 1'b0;
    data_state_w = data_state_r;
    loaded_w = loaded_r;
    finished = 1'b0;

    case (data_state_r)
        IDLE: begin
            data_w = 24'b0;
            state_start_w = 1'b0;
        end

        RESET: begin
            case (loaded_r)
            NOTLOADED: begin
                data_w = RESET_DATA;
                loaded_w = DATALOADED;
                state_start_w = 1'b0;
            end
            DATALOADED: begin
                state_start_w = 1'b1;
                loaded_w = RUNNING;
            end
            RUNNING: begin
                if (state_finished) begin
                    state_start_w = 1'b0;
                    loaded_w = NOTLOADED;
                    data_state_w = ANALOGUE;
                end
            end
            endcase
        end

        ANALOGUE: begin
            case (loaded_r)
            NOTLOADED: begin
                data_w = ANALOGUE_DATA;
                loaded_w = DATALOADED;
                state_start_w = 1'b0;
            end
            DATALOADED: begin
                state_start_w = 1'b1;
                loaded_w = RUNNING;
            end
            RUNNING: begin
                if (state_finished) begin
                    state_start_w = 1'b0;
                    loaded_w = NOTLOADED;
                    data_state_w = DIGITALPATH;
                end
            end
            endcase
        end
                
        DIGITALPATH: begin
            case (loaded_r)
            NOTLOADED: begin
                data_w = DIGITALPATH_DATA;
                loaded_w = DATALOADED;
                state_start_w = 1'b0;
            end
            DATALOADED: begin
                state_start_w = 1'b1;
                loaded_w = RUNNING;
            end
            RUNNING: begin
                if (state_finished) begin
                    state_start_w = 1'b0;
                    loaded_w = NOTLOADED;
                    data_state_w = POWERDOWN;
                end
            end
            endcase
        end
                
        POWERDOWN: begin
            case (loaded_r)
            NOTLOADED: begin
                data_w = POWERDOWN_DATA;
                loaded_w = DATALOADED;
                state_start_w = 1'b0;
            end
            DATALOADED: begin
                state_start_w = 1'b1;
                loaded_w = RUNNING;
            end
            RUNNING: begin
                if (state_finished) begin
                    state_start_w = 1'b0;
                    loaded_w = NOTLOADED;
                    data_state_w = DIGITALAUDIO;
                end
            end
            endcase
        end
                
        DIGITALAUDIO: begin
            case (loaded_r)
            NOTLOADED: begin
                data_w = DIGITALAUDIO_DATA;
                loaded_w = DATALOADED;
                state_start_w = 1'b0;
            end
            DATALOADED: begin
                state_start_w = 1'b1;
                loaded_w = RUNNING;
            end
            RUNNING: begin
                if (state_finished) begin
                    state_start_w = 1'b0;
                    loaded_w = NOTLOADED;
                    data_state_w = SAMPLING;
                end
            end
            endcase
        end
                
        SAMPLING: begin
            case (loaded_r)
            NOTLOADED: begin
                data_w = SAMPLING_DATA;
                loaded_w = DATALOADED;
                state_start_w = 1'b0;
            end
            DATALOADED: begin
                state_start_w = 1'b1;
                loaded_w = RUNNING;
            end
            RUNNING: begin
                if (state_finished) begin
                    state_start_w = 1'b0;
                    loaded_w = NOTLOADED;
                    data_state_w = ACTIVE;
                end
            end
            endcase
        end
                
        ACTIVE: begin
            case (loaded_r)
            NOTLOADED: begin
                data_w = ACTIVE_DATA;
                loaded_w = DATALOADED;
                state_start_w = 1'b0;
            end
            DATALOADED: begin
                state_start_w = 1'b1;
                loaded_w = RUNNING;
            end
            RUNNING: begin
                if (state_finished) begin
                    state_start_w = 1'b0;
                    loaded_w = NOTLOADED;
                    data_state_w = IDLE;
                    finished = 1'b1;
                end
            end
            endcase
        end
    endcase


end

// always_ff @(negedge i_rst_n or posedge i_clk or posedge i_start) begin
always_ff @(negedge i_rst_n or posedge i_clk) begin
    if (!i_rst_n) begin
        data_r <= RESET_DATA;
        state_start_r <= 1'b0;
        data_state_r <= RESET;
        loaded_r <= DATALOADED;
    end
    // if (i_start) begin
    //     data_r <= RESET_DATA;
    //     state_start_r <= 1'b0;
    //     data_state_r <= RESET;
    //     loaded_r <= DATALOADED;
    // end
    else begin
        data_r <= data_w;
        state_start_r <= state_start_w;
        data_state_r <= data_state_w;
        loaded_r <= loaded_w;
    end
end

endmodule