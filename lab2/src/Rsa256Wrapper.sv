module Rsa256Wrapper (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

// for ip address
localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// for rx and tx
localparam S_READ_WAIT = 0;
localparam S_READ_DATA = 1;
localparam S_WAIT_CALCULATE = 2;
localparam S_WRITE_WAIT = 3;
localparam S_WRITE_DATA = 4;

// for deciding which data is inputing now
localparam READ_N = 3'd0;
localparam READ_D = 3'd1;
localparam READ_ENC = 3'd2;

logic [255:0] n_r, n_w, d_r, d_w, enc_r, enc_w, dec_r, dec_w;
logic [3:0] state_r, state_w;
logic [6:0] bytes_counter_r, bytes_counter_w;
logic [4:0] avm_address_r, avm_address_w;
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;

logic rsa_start_r, rsa_start_w;
logic rsa_finished;
logic [255:0] rsa_dec;

// which data is now reading (n, e, enc, or nothing)
logic [2:0] read_state_r, read_state_w;

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = dec_r[247-:8];   // the 8 MSB of dec_r would be written

Rsa256Core rsa256_core(
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_a(enc_r),
    .i_d(d_r),
    .i_n(n_r),
    .o_a_pow_d(rsa_dec),
    .o_finished(rsa_finished)
);

task StartRead;
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

always_comb begin
    // default values to avoid latch generation
    n_w = n_r;
    d_w = d_r;
    enc_w = enc_r;
    dec_w = dec_r;
    avm_address_w = avm_address_r;
    avm_read_w = avm_read_r;
    avm_write_w = avm_write_r;
    state_w = state_r;
    bytes_counter_w = bytes_counter_r;
    rsa_start_w = rsa_start_r;

    // default values to something added (not in template)
    read_state_w = read_state_r;

    case(state_r)
    // Case S_READ_WAIT: Check rx is ready
    S_READ_WAIT: begin
        if (!avm_waitrequest) begin
            // addr = BASE + 8, readdata[7] is ready or not
            if (avm_address_r == STATUS_BASE & avm_readdata[7] == 1'b1) begin
                StartRead(RX_BASE);      //able to read data
                state_w = S_READ_DATA;
                dec_w = 255'b0;
            end
            else begin
                StartRead(STATUS_BASE);
                state_w = S_READ_WAIT;
                dec_w = 255'b0;

            end
        end
        else begin
            StartRead(STATUS_BASE);
            state_w = S_READ_WAIT;
            dec_w = 255'b0;
        end
    end

    // Case S_READ_DATA: read and save data from 
    S_READ_DATA: begin
        case (read_state_r)
        READ_N: begin
            // not enough
            if (!avm_waitrequest)   begin
                if (avm_address_r == RX_BASE & bytes_counter_r < 7'd31) begin
                        //move and store the value
                        n_w = n_w << 8;
                        n_w[7:0] = avm_readdata[7:0];
                        // add one to calc iteration
                        bytes_counter_w = bytes_counter_w + 7'd1;

                        StartRead(STATUS_BASE);
                        read_state_w = read_state_r;
                        state_w = S_READ_WAIT;
                end
                // enough, change to read e
                else if (avm_address_r == RX_BASE & bytes_counter_r == 7'd31) begin
                        //move and store the value
                        // $display("HI");
                        n_w = n_w << 8;
                        n_w[7:0] = avm_readdata[7:0];

                        // reset the iteration
                        bytes_counter_w = 7'd0;

                        StartRead(STATUS_BASE);
                        read_state_w = READ_D;
                        state_w = S_READ_WAIT;
                end
            end
        end

        READ_D: begin
            // not enough
            if (!avm_waitrequest) begin
                if (avm_address_r == RX_BASE & bytes_counter_r < 7'd31) begin
                        //move and store the value
                        d_w = d_w << 8;
                        d_w[7:0] = avm_readdata[7:0];

                        // add one to calc iteration
                        bytes_counter_w = bytes_counter_w + 7'd1;

                        StartRead(STATUS_BASE);
                        read_state_w = read_state_r;
                        state_w = S_READ_WAIT;
                end
                // enough, change to read enc
                else if (avm_address_r == RX_BASE & bytes_counter_r == 7'd31) begin
                        //move and store the value
                        d_w = d_w << 8;
                        d_w[7:0] = avm_readdata[7:0];

                        // add one to calc iteration
                        bytes_counter_w = 7'd0;

                        StartRead(STATUS_BASE);
                        read_state_w = READ_ENC;
                        state_w = S_READ_WAIT;
                end
            end
        end

        READ_ENC: begin
            // not enough
            if (!avm_waitrequest) begin
                if (avm_address_r == RX_BASE & bytes_counter_r < 7'd31) begin
                        //move and store the value
                        enc_w = enc_w << 8;
                        enc_w[7:0] = avm_readdata[7:0];

                        // add one to calc iteration
                        bytes_counter_w = bytes_counter_w + 7'd1;

                        StartRead(STATUS_BASE);
                        read_state_w = read_state_r;
                        state_w = S_READ_WAIT;
                end
                // enough, start doing RSA256
                // change read_state_w to READ_N for next iteration reading
                else if (avm_address_r == RX_BASE & bytes_counter_r == 7'd31) begin
                        //move and store the value
                        enc_w = enc_w << 8;
                        enc_w[7:0] = avm_readdata[7:0];

                        // add one to calc iteration
                        bytes_counter_w = 7'd0;

                        StartRead(STATUS_BASE);
                        read_state_w = READ_ENC;
                        state_w = S_WAIT_CALCULATE;
                end
            end
        end
        endcase
    end

    // Case S_WAIT_CALCULATE: wait RSA256 to finish its calculation
    S_WAIT_CALCULATE: begin
        // check rsa is still doing calculation
        // $display("----------- RSA WAIT CALCULATE ------------");
        // $display("enc: %x", enc_r);
        // $display("n: %x", n_r);
        // $display("d: %x", d_r);
        rsa_start_w = 1'b1;
        // RSA core raise rsa_finished to 1 if finished
        if (rsa_finished) begin
            dec_w = rsa_dec;
            rsa_start_w = 1'b0;
            // $display("");
            // $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            // $display("------------ RSA END CALCULATE ------------");
            // $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            // $display("enc: %x", enc_r);
            // $display("n: %x", n_r);
            // $display("d: %x", d_r);
            // $display("dec: %x", dec_r);
            // $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            // $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            // $display("");
            state_w = S_WRITE_WAIT;
        end
    end

    S_WRITE_WAIT: begin
        if (!avm_waitrequest) begin
            // addr = BASE + 8, readdata[6] is ready or not
            if (avm_address_r == STATUS_BASE & avm_readdata[TX_OK_BIT] == 1'b1) begin
                StartWrite(TX_BASE);      //able to read data
                state_w = S_WRITE_DATA;
            end
            else begin
                StartRead(STATUS_BASE);
                state_w = S_WRITE_WAIT;
            end
        end
        else begin
            StartRead(STATUS_BASE);
            state_w = S_WRITE_WAIT;
        end
    end

    S_WRITE_DATA: begin
        // not finished
        if (!avm_waitrequest) begin
            if (avm_address_r == TX_BASE & bytes_counter_r < 7'd30) begin
                    //move the value to correct position
                    // $display("dec: %x", dec_r);
                    dec_w = dec_r << 8;

                    // add one to calc iteration
                    bytes_counter_w = bytes_counter_w + 7'd1;

                    StartRead(STATUS_BASE);
                    state_w = S_WRITE_WAIT;
            end
            // finished, return to read wait
            else if (avm_address_r == TX_BASE & bytes_counter_r == 7'd30) begin
                    //move and store the value
                    // $display("dec: %x", dec_r);
                    dec_w = dec_r << 8;

                    // reset the iteration
                    bytes_counter_w = 7'd0;

                    StartRead(STATUS_BASE);
                    state_w = S_READ_WAIT;
            end
        end
    end

    endcase

end

always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        n_r <= 0;
        d_r <= 0;
        enc_r <= 0;
        dec_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= S_READ_WAIT;
        // bytes_counter_r <= 63;
        bytes_counter_r <= 0;
        rsa_start_r <= 0;

        // something added
        read_state_r <= READ_N;
    end 
    else begin
        n_r <= n_w;
        d_r <= d_w;
        enc_r <= enc_w;
        dec_r <= dec_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        bytes_counter_r <= bytes_counter_w;
        rsa_start_r <= rsa_start_w;

        // something added
        read_state_r <= read_state_w;
    end
end

endmodule
