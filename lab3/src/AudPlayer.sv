module AudPlayer(
	input       i_rst_n,
	input       i_bclk,
	input       i_daclrck,
	input       i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input[15:0] i_dac_data, //dac_data
	output      o_aud_dacdat
);

logic[15:0]     data_r, data_w, buffer_r, buffer_w;
logic           sda_r, sda_w;

assign o_aud_dacdat = i_en ? sda_r : 0;

parameter S_RIGHTIDLE = 3'd0;
parameter S_RIGHTSEND = 3'd1;

parameter S_LEFTIDLE = 3'd3;
parameter S_LEFTSEND = 3'd2;

logic[2:0] state_r, state_w;
logic[3:0] counter_r, counter_w;

always_comb begin
    data_w = i_dac_data;
    buffer_w = buffer_r;
    sda_w = sda_r;
    state_w = state_r;
    counter_w = counter_r;

    case (state_r)

    S_RIGHTIDLE: begin
        if (i_daclrck) begin     // ready to output right data
            buffer_w = data_r << 1;
            sda_w = data_r[15];
            state_w = S_RIGHTSEND;
        end
        else begin
            sda_w = 1'b0;
            state_w = S_RIGHTIDLE;
        end
    end

    S_RIGHTSEND: begin
        if (counter_r < 4'd15) begin
            buffer_w = buffer_r << 1;
            sda_w = buffer_r[15];
            state_w = S_RIGHTSEND;
            counter_w = counter_r + 1;
        end
        else if (counter_r == 4'd15) begin
            buffer_w = 16'b0;
            sda_w = 1'b0;
            state_w = S_LEFTIDLE;
            counter_w = 4'd0;
        end
        
    end

    S_LEFTIDLE: begin
        if (!i_daclrck) begin     // ready to output right data
            buffer_w = data_r << 1;
            sda_w = data_r[15];
            state_w = S_LEFTSEND;
        end
        else begin
            sda_w = 1'b0;
            state_w = S_LEFTIDLE;
        end
    end

    S_LEFTSEND: begin
        if (counter_r < 4'd15) begin
            buffer_w = buffer_r << 1;
            sda_w = buffer_r[15];
            state_w = S_LEFTSEND;
            counter_w = counter_r + 1;
        end
        else if (counter_r == 4'd15) begin
            buffer_w = 16'b0;
            sda_w = 1'b0;
            state_w = S_RIGHTIDLE;
            counter_w = 4'd0;
        end
        
    end
    endcase
end

always_ff @(negedge i_rst_n or negedge i_bclk) begin
    if (!i_rst_n)begin
        data_r <= 16'b0;
        buffer_r <= 16'b0;
        sda_r <= 1'b0;
        state_r <= S_RIGHTIDLE;
        counter_r <= 4'd0;
    end
    else begin
        data_r <= data_w;
        buffer_r <= buffer_w;
        sda_r <= sda_w;
        state_r <= state_w;
        counter_r <= counter_w;
    end
end
endmodule