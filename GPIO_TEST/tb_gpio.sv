`timescale 1ns/100ps

module tb();
parameter CLK = 10;
parameter HCLK = CLK / 2;

logic clk, gpio, reset;

gpio test(
    .i_rst_n(reset),
    .i_clk(clk),
    .o_gpio(gpio)
);

initial begin
    $dumpfile("gpiotest.vcd");
    $dumpvars;
    clk = 0;
    reset = 1;

    #10
    reset = 0;

    #10
    reset = 1;

end

initial begin
    #(5000*CLK)
    $finish;
end

always #HCLK clk = ~clk;

endmodule