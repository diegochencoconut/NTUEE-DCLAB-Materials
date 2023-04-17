module gpio (
    input i_rst_n,
    input i_clk,
    output o_gpio
);

logic state_r, state_w;
logic[26:0] counter_r, counter_w;

parameter timelength = 27'd50000000;        //50000000
assign o_gpio = state_r;

always_comb begin
    state_w = state_r;
    counter_w = counter_r;

    if (counter_r < timelength) begin
        state_w = state_r;
        counter_w = counter_r + 27'd1;
    end
    else if (counter_r == timelength) begin
        state_w = ~state_r;
        counter_w = 27'd0;
    end

end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state_r <= 1'b0;
        counter_r <= 27'b0;
    end
    else begin
        state_r <= state_w;
        counter_r <= counter_w;
    end
end

endmodule