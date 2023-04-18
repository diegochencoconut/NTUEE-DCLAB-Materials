module tb();

logic           reset, key_0, key_1, key_2, switch;
logic           clk_50;
logic[19:0]     SRAM_ADDR;
logic[15:0]     SRAM_DQ;
logic           SRAM_WE_N, SRAM_CE_N, SRAM_OE_N, SRAM_LB_N, SRAM_UB_N;

logic           clk_100k;
logic           I2C_SCLK;
logic           I2C_SDAT;

logic           AUD_ADCDAT;
logic           AUD_ADCLRCK;
logic           bclk;
logic           AUD_DACLRCK;
logic           AUD_DACDAT;

Top top0(
    .i_rst_n(reset),
    .i_clk(clk_50),
    .i_key_0(key_0),
    .i_key_1(key_1),
    .i_key_2(key_2),
    .i_sw_0(switch),

    .o_SRAM_ADDR(SRAM_ADDR),
    .io_SRAM_DQ(SRAM_DQ),
    .o_SRAM_WE_N(SRAM_WE_N),
    .o_SRAM_CE_N(SRAM_CE_N),
    .o_SRAM_OE_N(SRAM_OE_N),
    .o_SRAM_LB_N(SRAM_LB_N),
    .o_SRAM_UB_N(SRAM_UB_N),

    .i_clk_100k(clk_100k),
    .o_I2C_SCLK(I2C_SCLK),
    .io_I2C_SDAT(I2C_SDAT),

    .i_AUD_ADCDAT(AUD_ADCDAT),
    .i_AUD_ADCLRCK(AUD_ADCLRCK),
    .i_AUD_BCLK(bclk),
    .i_AUD_DACLRCK(AUD_DACLRCK),
    .o_AUD_DACDAT(AUD_DACDAT)
);

initial begin
    $dumpfile("lab3_buttontest.vcd");
    $dumpvars;
    reset = 1;
    key_0 = 0;
    key_1 = 0;
    key_2 = 0;
    switch = 0;

    clk_50 = 0;
    SRAM_DQ = 1'bz;

    clk_100k = 0;
    I2C_SDAT = 1'bz;

    AUD_ADCDAT = 0;
    AUD_ADCLRCK = 0;
    bclk = 0;
    AUD_DACLRCK = 0;

    #100;
    reset = 0;

    #50;
    reset = 1;

    #100;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start record

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause record

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // continue record

    #1000;
    key_0 = 1;      
    #30;
    key_0 = 0;      // stop record

    #100;
    switch = 1;     // go to play set

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_0 = 1;      
    #30;
    key_0 = 0;      // stop play

    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 2x
    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 3x

    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 4x

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 3x

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 4x
    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 5x

    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 6x

    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 7x
    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 8x

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_0 = 1;      
    #30;
    key_0 = 0;      // stop play
    
    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 7x
    
    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 6x
    
    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 5x

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 4x
    
    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 3x

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 2x

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1x

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1/2
    
    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1/3
    
    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1/4

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1/5
    
    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1/6

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1/7

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1/8

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_0 = 1;      
    #30;
    key_0 = 0;      // stop play

    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 1/7
    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 1/6

    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 1/5

    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 1/4

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 1/3
    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 1/2

    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 1x

    
    #100;
    key_0 = 1;      
    #30;
    key_0 = 0;      // go to 2x

    
    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #500;
    key_2 = 1;
    #30;
    key_2 = 0;      // go to 1x

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // stop play

    #500;
    switch = 0;     // go to record mode

    #100;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start record

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause record

    #500;
    key_1 = 1;      
    #30;
    key_1 = 0;      // continue record

    #1000;
    key_0 = 1;      
    #30;
    key_0 = 0;      // stop record

    #100;
    switch = 1;     // go to play set

    #100;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #500;
    switch = 0;     // go to record mode

    #100;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start record

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause record

    #100;
    switch = 1;     // go to play set

    #100;
    key_1 = 1;      
    #30;
    key_1 = 0;      // start play

    #1000;
    key_1 = 1;      
    #30;
    key_1 = 0;      // pause play

    #1000;
    reset = 1;

    #30;
    reset = 0;

    $finish;
end

always #25      bclk = ~bclk;           // 12MHz
always #6       clk_50 = ~clk_50;             // 50MHz
always #3000    clk_100k = ~clk_100k;   // 100kHz

endmodule