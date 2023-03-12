module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

	// ===== Registers & Wires =====
	logic [3:0] o_random_out_r, o_random_out_w;
	logic slower_clk;

	LFSR LFSR1(.slower_clk(slower_clk), .i_rst_n(i_rst_n), .i_start(i_start), .result(o_random_out_w));
	clk_counter clk_counter1(.i_clk(i_clk), .i_rst_n(i_rst_n), .i_start(i_start), .slower_clk(slower_clk));

	// ===== Output Assignments =====
	assign o_random_out = o_random_out_r;

	always_ff @(posedge slower_clk or negedge i_rst_n) begin

		// reset
		if (!i_rst_n) begin
			o_random_out_r 	<= 4'd0;
		end
		else begin
			o_random_out_r <= o_random_out_w;
		end

	end

endmodule

module LFSR (
	input 			slower_clk,
	input 			i_rst_n,
	input			i_start,
	output [3:0]	result
);

	logic [15:0] seed_r, seed_w, processing, processing_shift;
	logic [3:0]  result_w, result_r;
	logic newComer;

	assign result = processing[3:0];

	always_comb begin
		// Default Values
		newComer = processing[0] ^ processing[7] ^ processing[4] ^ processing[9];
		processing_shift = processing >> 1;
		if(i_start) begin
			newComer = seed_w[15];
			processing_shift = seed_w[14:0];
		end
	end

	always_ff @(posedge slower_clk or negedge i_rst_n) begin
		
		// reset
		if (!i_rst_n) begin
			seed_r 		<= 15'd0;
			seed_w		<= 15'd0;
			processing	<= 15'd0;
		end

		else begin
			seed_w 		<= seed_r + 15'd1;
			seed_r 		<= seed_w;
			result_r	<= result_w;
			processing[14:0] <= processing_shift[14:0];
			processing[15] <= newComer;
		end
		
	end

endmodule

// module cycle_modulator(
// 	input i_clk,
// 	input i_rst_n,
// 	output [2:0] state
// );
// 	logic [2:0] state_r, state_r_nxt;

// 	always_ff @(posedge i_clk or negedge i_rst_n) begin
// 		if (!i_rst_n) begin
// 			state_r <= 4'd0;
// 		end
// 	end
// endmodule

module clk_counter(
	input i_clk,
	input i_rst_n,
	input i_start,
	output slower_clk
);
	typedef enum bit [3:0] { IDLE, STATE0, STATE1, STATE2, STATE3, STATE4, STATE5, STATE6, STATE7, STATE8, STATE9, STATE10, STATE11, STATE12, STATE13, STATE14} STATE;
	
	STATE [3:0] state_r, state_w;
	logic [27:0] count_r, count_w;

	always_comb begin
		// Default Values
		if(i_start) begin
			state_w = STATE0;
		end
		case (state_r)
			IDLE: begin
				slower_clk <= 1'd0;
				count_w = 28'd0;
			end
			STATE0: begin // 5000000
				if (count_r == 28'd2500000) begin
					slower_clk = 1'd1;
					count_w = count_r + 28'd1;
				end
				else if (count_r == 28'd5000000) begin
					slower_clk = 1'd0;
					state_w = STATE1;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
				end
			end
			STATE1: begin // 15000000
				if (count_r == 28'd7500000) begin
					slower_clk = 1'd1;
					count_w = count_r + 28'd1;
				end
				else if (count_r == 28'd15000000) begin
					slower_clk = 1'd0;
					state_w = STATE2;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
				end
			end
			STATE2: begin // 25000000
				if (count_r == 28'd12500000) begin
					slower_clk = 1'd1;
					count_w = count_r + 28'd1;
				end
				else if (count_r == 28'd25000000) begin
					slower_clk = 1'd0;
					state_w = STATE3;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
				end
			end
			STATE3: begin // 35000000
				if (count_r == 28'd17500000) begin
					slower_clk = 1'd1;
					count_w = count_r + 28'd1;
				end
				else if (count_r == 28'd35000000) begin
					slower_clk = 1'd0;
					state_w = STATE4;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
				end
			end
			STATE4: begin // 45000000
				if (count_r == 28'd22500000) begin
					slower_clk = 1'd1;
					count_w = count_r + 28'd1;
				end
				else if (count_r == 28'd45000000) begin
					slower_clk = 1'd0;
					state_w = IDLE;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
				end
			end
		endcase
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin
		
		// reset
		if (!i_rst_n) begin
			count_r <= 28'd0;
			state_r	<= IDLE;
		end
		else begin
			count_r 	<= count_w;
			state_r 	<= state_w;
		end
		
	end
endmodule