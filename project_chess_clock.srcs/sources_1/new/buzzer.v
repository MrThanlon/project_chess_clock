module buzzer(input clk_1k, input enable, output reg buzz);
    always@(clk_1k or enable) begin
        if (enable) begin
            buzz = clk_1k;
        end
        else begin
            buzz = 0;
        end
    end
endmodule