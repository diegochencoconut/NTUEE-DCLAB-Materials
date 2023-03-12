module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

	// ===== Registers & Wires =====
	logic [3:0] o_random_out_r, o_random_out_w;
	logic slower_clk;

	LFSR LFSR1(.i_clk(i_clk), .slower_clk(slower_clk), .i_rst_n(i_rst_n), .i_start(i_start), .result(o_random_out_w));
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
	input 			i_clk,
	input           slower_clk,
	input 			i_rst_n,
	input			i_start,
	output [3:0]	result
);

	logic [15:0] seed_r, seed_w, processing, processing_shift;
	logic [3:0]  result_w, result_r;
	logic newComer;

	assign result_w = processing[3:0];
	assign result = result_r;

	always_comb begin
		// Default Values
		seed_w 		= seed_r + 15'd1;
		if(i_start) begin
			newComer = seed_r[15];
			processing_shift = seed_r[14:0];
		end
		else begin
			newComer = processing[0] ^ processing[7] ^ processing[4] ^ processing[9];
			processing_shift = processing >> 1;
		end
	end

	always_ff @(posedge slower_clk or negedge i_rst_n) begin
		
		// reset
		if (!i_rst_n) begin
			result_r <= 4'd0;
		end

		else begin
			result_r	<= result_w;
		end
	end
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		
		// reset
		if (!i_rst_n) begin
			seed_r 		<= 15'd0;
			processing	<= 15'd0;
		end

		else begin
			seed_r 		<= seed_w;
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
	
	STATE state_r, state_w;
	logic [27:0] count_r, count_w;
	logic slower_clk_w, slower_clk_r;
	
	assign slower_clk = slower_clk_w;

	always_comb begin
		// // Default Values
		// if (i_start) begin
		//  	state_w = STATE0;
		// end
		// else begin
		// 	state_w = state_r;
		// end

		case (state_r)
			IDLE: begin
				slower_clk_w = 1'd0;
				count_w = 28'd0;
				if (i_start) begin
					state_w = STATE0;
				end
				else begin
					state_w = state_r;
				end
			end
			STATE0: begin // 1000000
				if (count_r == 28'd2000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd4000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE1;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE1: begin // 3000000
				if (count_r == 28'd2000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd4000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE2;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE2: begin // 5000000
				if (count_r == 28'd2000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd4000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE3;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE3: begin // 7000000
				if (count_r == 28'd4000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd8000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE4;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE4: begin // 9000000
				if (count_r == 28'd4000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd8000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE5;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE5: begin // 11000000
				if (count_r == 28'd4000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd8000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE6;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE6: begin // 13000000
				if (count_r == 28'd8000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd16000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE7;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE7: begin // 15000000
				if (count_r == 28'd16000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd32000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE8;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE8: begin // 17000000
				if (count_r == 28'd16000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd32000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE9;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE9: begin // 19000000
				if (count_r == 28'd16000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd32000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE10;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE10: begin // 21000000
				if (count_r == 28'd20000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd40000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE11;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE11: begin // 23000000
				if (count_r == 28'd20000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd40000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE12;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE12: begin // 25000000
				if (count_r == 28'd30000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd60000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE13;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE13: begin // 27000000
				if (count_r == 28'd30000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd60000000) begin
					slower_clk_w = 1'd0;
					state_w = STATE14;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			STATE14: begin // 29000000
				if (count_r == 28'd40000000) begin
					slower_clk_w = 1'd1;
					count_w = count_r + 28'd1;
					state_w = state_r;
				end
				else if (count_r == 28'd80000000) begin
					slower_clk_w = 1'd0;
					state_w = IDLE;
					count_w = 28'd0;
				end
				else begin
					count_w = count_r + 28'd1;
					slower_clk_w = slower_clk_r;
					state_w = state_r;
				end
			end
			default: begin
				slower_clk_w = slower_clk_r;
				count_w = 28'd0;
				state_w = state_r;
			end
		endcase
	end

	always_ff @(posedge i_clk or negedge i_rst_n or posedge i_start) begin
		
		// reset
		if (!i_rst_n) begin
			count_r <= 28'd0;
			state_r	<= IDLE;
			slower_clk_r <= 1'd0;
		end
		else if (i_start) begin
			count_r <= 28'd0;
			state_r	<= STATE0;
			slower_clk_r <= 1'd0;
		end
		else begin
			count_r 	 <= count_w;
			state_r 	 <= state_w;
			slower_clk_r <= slower_clk_w;
		end
		
	end
endmodule