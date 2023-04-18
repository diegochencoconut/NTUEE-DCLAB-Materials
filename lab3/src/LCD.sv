// module LCD (
//     input        i_clk_800k,
// 	inout  [7:0] o_LCD_DATA,
// 	output       o_LCD_EN,
// 	output       o_LCD_RS,
// 	output       o_LCD_RW,
// 	output       o_LCD_ON,
// 	output       o_LCD_BLON
// );

// LCDWriteLine lcdWriteLine (
// 	.i_clk_800k(i_clk_800k),
// 	.o_LCD_DATA(o_LCD_DATA),
// 	.o_LCD_EN(o_LCD_EN),
// 	.o_LCD_RS(o_LCD_RS),
// 	.o_LCD_RW(o_LCD_RW),
// 	.o_LCD_ON(o_LCD_ON),
// 	.o_LCD_BLON(o_LCD_BLON)
// );

// endmodule

module LCDInitializer (
    input          i_clk_800k,
	inout  [7:0]   o_LCD_DATA,
	output         o_LCD_EN,
	output         o_LCD_RS,
	output         o_LCD_RW,
	output         o_LCD_ON,
	output         o_LCD_BLON
);


endmodule

module LCDWriteLine (
    input          i_clk_800k,
	input  [127:0] i_line_data,
	input  [7:0]   i_addr_base,
	inout  [7:0]   o_LCD_DATA,
	output         o_LCD_EN,
	output         o_LCD_RS,
	output         o_LCD_RW,
	output         o_LCD_ON,
	output         o_LCD_BLON
);

LCDWriteChar lcdWriteChar (
	.i_clk_800k(i_clk_800k),
	.i_data(),
	.i_addr(),
	.o_LCD_DATA(o_LCD_DATA),
	.o_LCD_EN(o_LCD_EN),
	.o_LCD_RS(o_LCD_RS),
	.o_LCD_RW(o_LCD_RW),
	.o_LCD_ON(o_LCD_ON),
	.o_LCD_BLON(o_LCD_BLON)
);

endmodule

module LCDWriteChar (
    input        i_clk_800k,
	input  [7:0] i_data,
	input  [7:0] i_addr,
	inout  [7:0] o_LCD_DATA,
	output       o_LCD_EN,
	output       o_LCD_RS,
	output       o_LCD_RW,
	output       o_LCD_ON,
	output       o_LCD_BLON
);

LCDInstruction lcdInstruction (
	.i_clk_800k(i_clk_800k),
	.o_LCD_DATA(o_LCD_DATA),
	.o_LCD_EN(o_LCD_EN),
	.o_LCD_RS(o_LCD_RS),
	.o_LCD_RW(o_LCD_RW),
	.o_LCD_ON(o_LCD_ON),
	.o_LCD_BLON(o_LCD_BLON)
);

endmodule

module LCDInstruction (
    input        i_clk_800k,
	inout  [7:0] o_LCD_DATA,
	output       o_LCD_EN,
	output       o_LCD_RS,
	output       o_LCD_RW,
	output       o_LCD_ON,
	output       o_LCD_BLON
);

parameter LCD_ON   = 1'b0;
parameter LCD_BLON = 1'b1;

logic en_r, en_w;
logic rs_r, rs_w;
logic rw_r, rw_w;

assign o_LCD_EN = en_r;
assign o_LCD_EN = rc_r;
assign o_LCD_EN = rw_r;
assign o_LCD_EN = LCD_ON;
assign o_LCD_EN = LCD_BLON;

parameter I_CLEAR_DISPLAY  = 5'd0;
parameter I_ENTRY_MODE_SET = 5'd1;
parameter I_DISPLAY_ON     = 5'd2;
parameter I_FUNCTION_SET   = 5'd3;
parameter I_READ_BF        = 5'd3;
parameter I_SET_ADDRESS    = 5'd3;
parameter I_WRITE_CHAR     = 5'd3;

parameter S_

endmodule