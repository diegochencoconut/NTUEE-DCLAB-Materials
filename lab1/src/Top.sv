module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE = 1'b0;
parameter S_PROC = 1'b1;

// ===== Registers & Wires =====
logic [3:0] o_random_out_r, o_random_out_w;
logic state_r, state_w;

LFSR LFSR1(.i_clk(i_clk), .i_rst_n(i_rst_n), .i_start(i_start), .state_r(state_r), .result(o_random_out_w));

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

always_comb begin
	state_w        = state_r;
end

always_ff @(posedge i_clk or negedge i_rst_n) begin

	// reset
	if (!i_rst_n) begin
		o_random_out_r 	<= 4'd0;
		state_r			<= S_IDLE;
	end
	else begin
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
	end

end

endmodule

module LFSR (
	input 			i_clk,
	input 			i_rst_n,
	input			i_start,
	input			state_r,
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

always_ff @(posedge i_clk or negedge i_rst_n) begin
	
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
