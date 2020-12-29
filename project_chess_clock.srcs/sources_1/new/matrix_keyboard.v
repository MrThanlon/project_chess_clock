module matrix_keyboard(
    input clk,
    input [3:0] col,
    output [3:0] row,
    output reg key_down,
    output reg [3:0] key
);
    wire clk_1k;
    divclk mtxbtn_div1(clk, 1000, clk_1k);

    // scan rows
    reg [3:0] row_step = 0;
    reg [3:0] sum_col = 0;
    assign row[0] = ~row_step[0] & ~row_step[1];
    assign row[1] = row_step[0] & ~row_step[1];
    assign row[2] = ~row_step[0] & row_step[1];
    assign row[3] = row_step[0] & row_step[1];

    wire [3:0] log2_sum;
    assign log2_sum[0] = sum_col[1] | sum_col[3];
    assign log2_sum[1] = sum_col[2] | sum_col[3];
    
    reg [3:0] row_target = 0;

    always@(posedge clk_1k) begin
        if (row_step == 5) begin
            // trig signal
            if (sum_col > 0)
                key_down = 1;
            else
                key_down = 0;
            row_step = 0;
            sum_col = 0;
        end
        else if (row_step == 4) begin
            if (sum_col > 0) begin
                // pressed
                key = row_target * 4 + log2_sum;
            end
            row_step = row_step + 1;
        end
        else begin
            if (col > 0) begin
                row_target = row_step;
            end
            sum_col = sum_col | col;
            row_step = row_step + 1;
        end
    end

endmodule