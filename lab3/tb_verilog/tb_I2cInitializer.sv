`timescale 1ns/100ps
module tb;

localparam CLK = 10;
localparam HCLK = CLK / 2;

logic clk, start, reset;
logic en, SDA, SCL, finished;

I2cInitializer test (
    .i_rst_n(reset),
    .i_clk(clk),
	.i_start(start),
	.o_finished(finished),
	.o_sclk(SCL),
	.o_sdat(SDA),
	.o_oen(en) // you are outputing (you are not outputing only when you are "ack"ing.)
);

initial begin
    $dumpfile("lab3_i2cinitializer.vcd");
    $dumpvars;
    clk = 0;
    start = 0;
    reset = 1;

    #10;
    reset = 0;

    #10;
    reset = 1;

    #100;
    start = 1;
    $display("started");

    #10;
    start = 0;

end

initial begin
    #(500000*CLK)
    $display("Too slow, abort.");
    $finish;
end

always_ff @(posedge finished) begin
    $finish;
end

always #HCLK clk = ~clk;

endmodule