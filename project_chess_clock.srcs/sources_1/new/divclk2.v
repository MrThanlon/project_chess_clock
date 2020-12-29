module divclk2(input clk_in, input [31:0] cnt_max, output reg clk_out);

    reg[31:0] cnt = 0; // counter          
    // reg clk_out = 0;
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
