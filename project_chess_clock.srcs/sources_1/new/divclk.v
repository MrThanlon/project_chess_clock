module divclk(input clk_in, input [31:0] freq, output reg clk_out);

    reg[31:0] cnt = 0; // counter          
    // reg clk_out = 0;
    wire [31:0] cnt_max = 50000000 / freq / 2 - 1;
    always@(posedge clk_in)
    begin
        if(cnt >= cnt_max)
        begin
            clk_out = ~clk_out;
            cnt = 0;
        end
        else
        begin
            cnt = cnt + 1;
        end
    end
endmodule
