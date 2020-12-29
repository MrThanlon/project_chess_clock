`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/25 19:05:05
// Design Name: 
// Module Name: main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define TONE1_FREQ 523
`define TONE2_FREQ 587
`define TONE3_FREQ 659
`define TONE4_FREQ 698
`define TONE5_FREQ 784
`define TONE6_FREQ 880
`define TONE7_FREQ 988
`define TONE8_FREQ 1046

module main(input sw_stop,
input sw_pause,
input clk,
input [3:0] col,
output [3:0] row,
output buzz,
output led0,
output led1,
output [7:0] seg,
output [5:0] dig);
    wire buzz_clk;
    reg [31:0] buzz_freq = 200;
    reg [31:0] buzz_period = 95602;
    wire key_down;
    wire [3:0] key;
    assign led0 = key_down;
    reg [9:0] count_down_max = 100;
    reg [9:0] count_down = 100;

    wire [3:0] player_A_dig_0 = count_down > 0 ? ((player == 0 ? count_down : count_down_max) % 10) : (player ? 4'hA : 4'hB);
    wire [3:0] player_A_dig_1 = (player == 0 ? count_down : count_down_max) % 100 / 10;
    wire [3:0] player_A_dig_2 = (player == 0 ? count_down : count_down_max) / 100;
    wire [3:0] player_B_dig_0 = (player == 1 ? count_down : count_down_max) % 10;
    wire [3:0] player_B_dig_1 = (player == 1 ? count_down : count_down_max) % 100 / 10;
    wire [3:0] player_B_dig_2 = (player == 1 ? count_down : count_down_max) / 100;

    reg player = 0;
    wire is_change_tone = key <= 11 && key >= 4;

    wire clk_10;
    divclk divclk_10(clk, 10, clk_10);

    always@(posedge clk_10) begin
        if (sw_stop)
            // stop counting and reset value
            count_down <= count_down_max;
        else if (key_down && ((player == 0 && key == 0) || (player == 1 && key == 1))) begin
            count_down <= count_down_max;
            if (key == 0)
                player <= 1;
            else
                player <= 0;
        end
        else begin
            // trig by clk_10
            if (~sw_pause && count_down > 0) begin
                // pause counting
                count_down <= count_down - 1;
            end
        end
    end

    always@(posedge key_down) begin
        case(key)
        4: buzz_period <= 95602;
        5: buzz_period <= 85178;
        6: buzz_period <= 75872;
        7: buzz_period <= 71633;
        8: buzz_period <= 63775;
        9: buzz_period <= 56818;
        10: buzz_period <= 50607;
        11: buzz_period <= 47801;
        endcase

        if (key > 11) begin
            if (key == 12 && count_down_max < 950)
                count_down_max <= count_down_max + 50;
            else if (key == 13 && count_down_max < 990)
                count_down_max <= count_down_max + 10;
            else if (key == 14 && count_down_max > 10)
                count_down_max <= count_down_max - 10;
            else if (key == 15 && count_down_max > 50)
                count_down_max <= count_down_max - 50;
        end
    end

    // flash
    reg enable_flash = 0;
    wire clk_2;
    divclk divclk_2(clk, 2, clk_2);

    always@(clk_2) begin
        if (sw_stop || sw_pause || count_down >= 50)
            enable_flash = 0;
        else if (count_down < 50 && count_down > 0)
            enable_flash = clk_2;
        else if (count_down == 0)
            enable_flash = 1;
    end
    assign led1 = enable_flash;

    divclk2 divclk_buzz(clk, buzz_period, buzz_clk);
    buzzer buzz0(buzz_clk, enable_flash | (is_change_tone & key_down), buzz);
    matrix_keyboard mk1(clk, col, row, key_down, key);
    dynamic_led6 d0(clk, count_down > 0 ? 6'b000000 : 6'b111110,
        player_B_dig_2,
        player_B_dig_1,
        player_B_dig_0,
        player_A_dig_2,
        player_A_dig_1,
        player_A_dig_0, seg, dig);
endmodule
