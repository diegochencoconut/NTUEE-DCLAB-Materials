`timescale 1ns/100ps
module tb;

localparam CLK = 10;
localparam HCLK = CLK / 2;

logic [23:0] data;
logic clk, start, reset;
logic en, SDA, SCL, finished;

I2cController test (
    .i_data(data),
    .i_clk(clk),
    .i_start(start),
    .i_rst_n(reset),
    .o_en(en),
    .o_SDA(SDA),
    .o_SCL(SCL),
    .o_finished(finished)
);

initial begin
    $dumpfile("lab3_i2ccontroller.vcd");
    $dumpvars;
    data = 24'b101010101010101010101010;
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