module AudRecorder (
	input         i_rst_n,
	input         i_clk,
	input         i_lrc,
	input         i_start,
	input         i_pause,
	input         i_stop,
	input         i_data,    // I2S incoming data
	output [19:0] o_address, // address of SRAM to save
	output [15:0] o_data,    // byte data to be saved
	output [19:0] o_recd_len
);

// === Input Delay ===
logic d_lrc_r, d_lrc_w;

// === State Logic ===
parameter n = 5'd16;      // WM8731 resolution

parameter S_IDLE    = 3'd0; // before start
parameter S_PREPARE = 3'd1; // waiting for LRC rising
parameter S_FETCH   = 3'd2; // fetching I2S data
parameter S_PAUSE   = 3'd3; // recording paused

logic [2:0]  state_r, state_w;           // state register
logic [19:0] recd_len_r, recd_len_w; // keep record length

logic [19:0] address_r, address_w;       // SRAM address
logic [15:0] data_r, data_w;             // SRAM write data

logic [15:0] data_reg_r, data_reg_w;     // shift register for I2S data
logic [4:0]  counter_r, counter_w;       // counter for I2S

assign o_address  = address_r;
assign o_data     = data_r;
assign o_recd_len = recd_len_r;

always_comb begin

	d_lrc_w = i_lrc;

	state_w = state_r;
	recd_len_w = recd_len_r;
	address_w = address_r;
	data_w = data_r;
	data_reg_w = data_reg_r;
	counter_w = counter_r;

	case (state_r)

		// wait for start
		S_IDLE: begin
			if (i_start) begin
				state_w      = S_PREPARE;
				recd_len_w = 20'b0;
				address_w    = 20'b0;
				data_w       = 16'b0;
				data_reg_w   = 16'b0;
				counter_w    = 5'b0;
			end
		end
		// wait for LRC
		S_PREPARE: begin
			if (i_lrc && i_lrc != d_lrc_r) begin
				state_w = S_FETCH;
			end
			else if (i_pause) begin
				state_w = S_PAUSE;
			end
			else if (i_stop) begin
				state_w = S_IDLE;
			end
		end
		// start fetching I2S data
		S_FETCH: begin
			if (i_pause) begin
				state_w = S_PAUSE;
			end
			else if (i_stop) begin
				state_w = S_IDLE;
			end
			else begin
				counter_w = counter_r + 5'd1;
				if (counter_r < n - 5'd1) begin
					data_reg_w = { data_reg_r[14:0], i_data };
				end
				// flush word from shift register to SRAM
				else if (counter_r < n) begin
					data_w = { data_reg_r[14:0], i_data };
				end
				else if (counter_r == n) begin
					// pull up CE and WE
				end
				// increment SRAM address and prepare for next word
				else if (counter_r == n + 5'd1) begin
					state_w   = S_PREPARE;
					address_w = address_r + 20'd1;
					// update record length
					if (address_r == recd_len_r) begin
						recd_len_w = address_r + 20'd1;
					end
					data_reg_w = 16'b0;
					counter_w  = 5'b0;
				end
			end
		end

		S_PAUSE: begin
			if (i_start) begin
				state_w    = S_PREPARE;
				data_reg_w = 16'b0;
				counter_w  = 5'b0;
			end
			else if (i_stop) begin
				state_w = S_IDLE;
			end
		end

	endcase
end

always_ff @(negedge i_rst_n or posedge i_clk) begin
	if (!i_rst_n) begin
		d_lrc_r      <= 0;

		state_r      <= S_IDLE;
		recd_len_r <= 20'b0;
		address_r    <= 20'b0;
		data_r       <= 16'b0;
		data_reg_r   <= 16'b0;
		counter_r    <= 5'b0;
	end
	else if (i_clk) begin
		d_lrc_r      <= d_lrc_w;

		state_r      <= state_w;
		recd_len_r <= recd_len_w;
		address_r    <= address_w;
		data_r       <= data_w;
		data_reg_r   <= data_reg_w;
		counter_r    <= counter_w;
	end
end

endmodule