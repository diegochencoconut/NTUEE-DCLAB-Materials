module tb;

logic reset, clk, start, pause, stop, fast, slow_0, slow_1, daclrck;
logic [3:0] speed;
logic [15:0] data, output_data;
logic [19:0] output_address;

parameter data0 = 16'b0000000000000000;
parameter data1 = 16'b1010101010101010;
parameter data2 = 16'b1111111111111111;
parameter data3 = 16'b0110110111101101;
parameter data4 = 16'b0000000011111111;

AudDSP dsp0(
	.i_rst_n(reset),
	.i_clk(clk),
	.i_start(start),
	.i_pause(pause),
	.i_speed(speed),
	.i_stop(stop),
	.i_fast(fast),
	.i_slow_0(slow_0),
	.i_slow_1(slow_1),
	.i_daclrck(daclrck),
	.i_sram_data(data),
 
 	// input [3:0] i_speed, // design how user can decide mode on your own
	
	.o_dac_data(output_data),
	.o_sram_addr(outupt_address)
);

initial begin
    $dumpfile("lab3_AudDSP.vcd");
    $dumpvars;
    reset = 1;
    clk = 0;
    start = 0;
    pause = 0;
    stop = 0;
    fast = 0;
    slow_0 = 0;
    slow_1 = 0;
    daclrck = 0;
    speed = 4'd0;
    data = data0;

    #10
    reset = 0;

    #20
    reset = 1;

    #100;
    data = 1;

    #100;
    start = 1;
    #20;
    start = 0;

    #1000;
    stop = 1;
    #20;
    stop = 0;

    #100;
    pause = 1;
    #20;
    pause = 0;

    #100;
    start = 1;
    #20;
    start = 0;

    #300;
    data = data1;

    #400;
    data = data2;

    #300;
    data = data3;

    #300;
    stop = 1;
    #20;
    stop = 0;

    $finish;
end

always #5 clk = ~clk;
always #200 daclrck = ~daclrck;

endmodule