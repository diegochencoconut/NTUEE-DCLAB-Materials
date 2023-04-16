`timescale 1ns/100ps

module tb();

logic[15:0]     data;
logic           reset, bclk, daclrck, en;
logic           dacdat;

localparam CLK = 10;
localparam HCLK = CLK / 2;

AudPlayer player0(
    .i_rst_n(reset),
    .i_bclk(bclk),
    .i_daclrck(daclrck),
    .i_en(en),
    .i_dac_data(data),
    .o_aud_dacdat(dacdat)
);

initial begin
    $dumpfile("lab3_audplayer.vcd");
    $dumpvars;

    data = 16'b1010101010101010;
    reset = 1'b1;
    bclk = 1'b0;
    daclrck = 1'b1;
    en = 1'b0;

    #10;
    reset = 1'b0;

    #20;
    reset = 1'b1;

    #50;
    en = 1'b1;

    #1000;
    data = 16'b1111111111111111;

    #1000;
    data = 16'b1001001011001110;

    #1000;
    en = 1'b0;

    #50;
    data = 16'b0101010101010101;
end


initial begin
    #(50000*CLK)
    $finish;
end

always #HCLK bclk = ~bclk;
always #200 daclrck = ~daclrck;

endmodule