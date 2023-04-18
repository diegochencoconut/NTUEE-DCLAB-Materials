module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,
	input i_key_1,
	input i_key_2,
	input i_sw_0,
	input i_sw_1,
	input i_sw_2,
	input i_sw_3,
	// input [3:0] i_speed, // design how user can decide mode on your own
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr

	output[35:0]	o_gpio;
);

// design the FSM and states as you like
parameter S_IDLE       = 3'd0;
parameter S_I2C        = 3'd1;
parameter S_RECD_IDLE  = 3'd2;
parameter S_RECD       = 3'd3;
parameter S_RECD_PAUSE = 3'd4;
parameter S_PLAY_IDLE  = 3'd5;
parameter S_PLAY       = 3'd6;
parameter S_PLAY_PAUSE = 3'd7;

logic [2:0] state_r, state_w;

logic i2c_oen, i2c_sdat;
logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;

wire i2c_finish;
wire [19:0] recd_len;

// === Input Delay ===
logic d_key_0_r, d_key_0_w;
logic d_key_1_r, d_key_1_w;
logic d_key_2_r, d_key_2_w;

logic d_sw_0_r, d_sw_0_w;
logic d_sw_1_r, d_sw_1_w;
logic d_sw_2_r, d_sw_2_w;
logic d_sw_3_r, d_sw_3_w;

// === Play Mode Logic ===
parameter M_RECD = 1'd0;
parameter M_PLAY = 1'd1;

logic mode_r, mode_w;

logic recd_start_r, recd_start_w;
logic recd_pause_r, recd_pause_w;
logic recd_stop_r, recd_stop_w;

logic play_start_r, play_start_w;
logic play_pause_r, play_pause_w;
logic play_stop_r, play_stop_w;

wire  player_en;

assign player_en = (mode_r == M_PLAY);

// === Play Speed Logic ===
parameter SM_NORM   = 2'd0;
parameter SM_FAST   = 2'd1;
parameter SM_SLOW_0 = 2'd2;
parameter SM_SLOW_1 = 2'd3;

logic [2:0] speed_mode_r, speed_mode_w;
logic [2:0] speed_r, speed_w;
logic [2:0] fast_speed_r, fast_speed_w;
logic [2:0] slow_speed_r, slow_speed_w;

logic speed_up_r, speed_up_w;
logic speed_down_r, speed_down_w;

wire  [2:0] speed;
wire        fast;
wire        slow_0;
wire        slow_1;

assign speed  = (speed_mode_r == SM_NORM) ? 2'b0 : (
			        (speed_mode_r == SM_FAST) ? fast_speed_r : slow_speed_r
			    );
assign fast   = (speed_mode_r == SM_FAST);
assign slow_0 = (speed_mode_r == SM_SLOW_0);
assign slow_1 = (speed_mode_r == SM_SLOW_1);

// === IO Assignment ===
assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

// GPIO ports
assign o_gpio[0] = i_key_0;
assign o_gpio[1] = i_key_1;
assign o_gpio[2] = i_key_2;
assign o_gpio[3] = i_sw_0;
assign o_gpio[4] = i_sw_1;
assign o_gpio[5] = i_sw_2;
assign o_gpio[6] = i_sw_3;
assign o_gpio[7] = i_clk;
assign o_gpio[10:8] = state_r;
assign o_gpio[13:11] = speed;
assign o_gpio[16:14] = speed_mode_r;
assign o_gpio[17] = recd_start_r;
assign o_gpio[18] = recd_pause_r;
assign o_gpio[19] = recd_stop_r;
assign o_gpio[20] = i_clk_100k;
assign o_gpio[21] = o_sdat;
assign o_gpio[22] = o_sclk;
assign o_gpio[23] = o_SRAM_WE_N;
assign o_gpio[24] = i_AUD_ADCDAT;
assign o_gpio[35:25] = addr_record[10:0];



// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	// .i_start(),
	.o_finished(i2c_finish),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
// AudDSP dsp0(
// 	.i_rst_n(i_rst_n),
// 	.i_clk(i_AUD_BCLK),
// 	.i_start(play_start_r),
// 	.i_pause(play_pause_r),
// 	.i_stop(play_stop_r),
// 	.i_speed(speed),
// 	.i_fast(fast),
// 	.i_slow_0(slow_0), // constant interpolation
// 	.i_slow_1(slow_1), // linear interpolation
// 	.i_daclrck(i_AUD_DACLRCK),
// 	.i_sram_data(data_play),
// 	.o_dac_data(dac_data),
// 	.o_sram_addr(addr_play)
// );

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
// AudPlayer player0(
// 	.i_rst_n(i_rst_n),
// 	.i_bclk(i_AUD_BCLK),
// 	.i_daclrck(i_AUD_DACLRCK),
// 	.i_en(player_en), // enable AudPlayer only when playing audio, work with AudDSP
// 	.i_dac_data(dac_data), //dac_data
// 	.o_aud_dacdat(o_AUD_DACDAT)
// );

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(recd_start_r),
	.i_pause(recd_pause_r),
	.i_stop(recd_stop_r),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record),
	.o_recd_len(recd_len)
);

always_comb begin
	state_w      = state_r;

	d_key_0_w    = i_key_0;
	d_key_1_w    = i_key_1;
	d_key_2_w    = i_key_2;

	mode_w       = i_sw_0;
	recd_start_w = recd_start_r;
	recd_pause_w = recd_pause_r;
	recd_stop_w  = recd_stop_r;
	play_start_w = play_start_r;
	play_pause_w = play_pause_r;
	play_stop_w  = play_stop_r;

	// play button state
	if (recd_start_r) recd_start_w = 0;
	else              recd_start_w = (state_r == S_RECD_IDLE || state_r == S_RECD_PAUSE)
									 && (i_key_1 && i_key_1 != d_key_1_r);
	if (recd_pause_r) recd_pause_w = 0;
	else              recd_pause_w = (state_r == S_RECD)
									 && (i_key_1 && i_key_1 != d_key_1_r);
	if (recd_stop_r)  recd_stop_w  = 0;
	else              recd_stop_w  = (state_r == S_RECD || state_r == S_RECD_PAUSE)
									 && (i_key_0 && i_key_0 != d_key_0_r)
	                                 || (i_sw_0 != mode_r);

	if (play_start_r) play_start_w = 0;
	else              play_start_w = (state_r == S_PLAY_IDLE || state_r == S_PLAY_PAUSE)
									 && (i_key_1 && i_key_1 != d_key_1_r);
	if (play_pause_r) play_pause_w = 0;
	else              play_pause_w = (state_r == S_PLAY)
									 && (i_key_1 && i_key_1 != d_key_1_r);
	if (play_stop_r)  play_stop_w  = 0;
	else              play_stop_w  = (state_r == S_PLAY || state_r == S_PLAY_PAUSE)
									 && (i_key_0 && i_key_0 != d_key_0_r)
	                                 || (i_sw_0 != mode_r);

	// state transition
	case (state_r)
		S_IDLE: begin
			state_w = S_I2C;
		end
		S_I2C: begin
			if (i2c_finish) begin
				state_w = S_RECD_IDLE;
			end
		end
		S_RECD_IDLE: begin
			if (mode_r == M_PLAY) begin
				state_w = S_PLAY_IDLE;
			end
			else if (recd_start_r) begin
				state_w = S_RECD;
				// TODO
			end
		end
		S_RECD: begin
			if (recd_pause_r) begin
				state_w = S_RECD_PAUSE;
				// TODO
			end
			else if (recd_stop_r) begin
				state_w = S_RECD_IDLE;
				// TODO
			end
		end
		S_RECD_PAUSE: begin
			if (recd_start_r) begin
				state_w = S_RECD;
				// TODO
			end
			else if (recd_stop_r) begin
				state_w = S_RECD_IDLE;
				// TODO
			end
		end

		S_PLAY_IDLE: begin
			if (mode_r == M_RECD) begin
				state_w = S_RECD_IDLE;
			end
			else if (play_start_r) begin
				state_w = S_PLAY;
				// TODO
			end
		end
		S_PLAY: begin
			if (play_pause_r) begin
				state_w = S_PLAY_PAUSE;
				// TODO
			end
			else if (play_stop_r) begin
				state_w = S_PLAY_IDLE;
				// TODO
			end
		end
		S_PLAY_PAUSE: begin
			if (play_start_r) begin
				state_w = S_PLAY;
				// TODO
			end
			else if (play_stop_r) begin
				state_w = S_PLAY_IDLE;
				// TODO
			end
		end
	endcase

	speed_mode_w = speed_mode_r;
	speed_w      = speed_r;
	fast_speed_w = fast_speed_r;
	slow_speed_w = slow_speed_r;

	speed_up_w   = speed_up_r;
	speed_down_w = speed_down_r;

	// speed mode state
	if (i_sw_1 == 0) begin
		speed_mode_w = SM_NORM;
	end
	else begin
		if (i_sw_2 == 0) begin
			speed_mode_w = SM_FAST;
		end
		else begin
			if (i_sw_3 == 0) speed_mode_w = SM_SLOW_0;
			else             speed_mode_w = SM_SLOW_1;
		end
	end

	// speed button state
	if (speed_up_r)   speed_up_w   = 0;
	else              speed_up_w   = (state_r == S_PLAY_IDLE)
									 && (i_key_0 && i_key_0 != d_key_0_r);
	if (speed_down_r) speed_down_w = 0;
	else              speed_down_w = (state_r == S_PLAY_IDLE)
									 && (i_key_2 && i_key_2 != d_key_2_r);

	// speed transition
	if (speed_mode_r == SM_FAST) begin
		if (speed_up_r && fast_speed_r < 3'd7) begin
			fast_speed_w = fast_speed_r + 3'd1;
		end
		else if (speed_down_r && fast_speed_r > 3'd0) begin
			fast_speed_w = fast_speed_r - 3'd1;
		end

		speed_w = fast_speed_w;
	end
	else if (speed_mode_r == SM_SLOW_0 || speed_mode_r == SM_SLOW_1) begin
		if (speed_down_r && slow_speed_r < 3'd7) begin
			slow_speed_w = slow_speed_r + 3'd1;
		end
		else if (speed_up_r && slow_speed_r > 3'd0) begin
			slow_speed_w = slow_speed_r - 3'd1;
		end

		speed_w = slow_speed_w;
	end
	else begin
		speed_w = 3'd0;
	end
end

always_ff @(posedge i_AUD_BCLK or posedge i_rst_n or posedge i_key_0 or posedge i_key_1 or posedge i_sw_0 or negedge i_sw_0) begin
	if (!i_rst_n) begin
		state_r      <= S_RECD_IDLE;

		d_key_0_r <= 0;
		d_key_1_r <= 0;
		d_key_2_r <= 0;

		d_sw_0_r  <= 0;
		d_sw_1_r  <= 0;
		d_sw_2_r  <= 0;
		d_sw_3_r  <= 0;

		mode_r       <= 0;
		recd_start_r <= 0;
		recd_pause_r <= 0;
		recd_stop_r  <= 0;
		play_start_r <= 0;
		play_pause_r <= 0;
		play_stop_r  <= 0;

		speed_mode_r <= SM_NORM;
		speed_r      <= 0;
		fast_speed_r <= 0;
		slow_speed_r <= 0;

		speed_up_r   <= 0;
		speed_down_r <= 0;
	end
	else if (i_AUD_BCLK) begin
		state_r      <= state_w;

		d_key_0_r <= d_key_0_w;
		d_key_1_r <= d_key_1_w;
		d_key_2_r <= d_key_2_w;
		
		d_sw_0_r  <= d_sw_0_w;
		d_sw_1_r  <= d_sw_1_w;
		d_sw_2_r  <= d_sw_2_w;
		d_sw_3_r  <= d_sw_3_w;

		mode_r       <= mode_w;
		recd_start_r <= recd_start_w;
		recd_pause_r <= recd_pause_w;
		recd_stop_r  <= recd_stop_w;
		play_start_r <= play_start_w;
		play_pause_r <= play_pause_w;
		play_stop_r  <= play_stop_w;

		speed_mode_r <= speed_mode_w;
		speed_r      <= speed_w;
		fast_speed_r <= fast_speed_w;
		slow_speed_r <= slow_speed_w;

		speed_up_r   <= speed_up_w;
		speed_down_r <= speed_down_w;
	end

end

endmodule