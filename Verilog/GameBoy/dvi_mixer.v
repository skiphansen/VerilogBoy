`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    15:28:43 02/07/2018 
// Design Name: 
// Module Name:    dvi_mixer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module dvi_mixer(
    input clk,
    input rst,
    // GameBoy Image Input
    input gb_hs,
    input gb_vs,
    input gb_pclk,
    input [1:0] gb_pdat,
    input gb_valid,
    // Debugger Char Input
    output [6:0] dbg_x,
    output [4:0] dbg_y,
    input [6:0] dbg_char,
    output dbg_sync,
    // DVI signal Output
    output dvi_hs,
    output dvi_vs,
    output dvi_blank,
    output reg [7:0] dvi_r,
    output reg [7:0] dvi_g,
    output reg [7:0] dvi_b
    );

    //Decoded GameBoy Input colors
    wire [7:0] gb_r;
    wire [7:0] gb_g;
    wire [7:0] gb_b;

    //Background colors
    wire [7:0] bg_r;
    wire [7:0] bg_g;
    wire [7:0] bg_b;

    //X,Y positions generated by the timing generator
    wire [10:0] dvi_x;
    wire [10:0] dvi_y;

    //VGA font
    wire [6:0] font_ascii;
    wire [3:0] font_row;
    wire [2:0] font_col;
    wire font_pixel;

    //Final pixel output
    wire [7:0] out_r;
    wire [7:0] out_g;
    wire [7:0] out_b;

    wire signal_in_gb_range = (dvi_x >= 11'd80)&&(dvi_x < 11'd560)&&(dvi_y >= 11'd24)&&(dvi_y <= 11'd456);
    assign out_r = (signal_in_gb_range) ? (gb_r) : (bg_r);
    assign out_g = (signal_in_gb_range) ? (gb_g) : (bg_g);
    assign out_b = (signal_in_gb_range) ? (gb_b) : (bg_b);

    always @(negedge clk)
    begin
      dvi_r <= out_r;
      dvi_g <= out_g;
      dvi_b <= out_b;
    end

    //Font
    assign dbg_x[6:0] = dvi_x[9:3];
    assign dbg_y[4:0] = dvi_y[8:4];
    assign font_ascii[6:0] = dbg_char[6:0];
    assign font_row[3:0] = dvi_y[3:0];
    assign font_col[2:0] = dvi_x[2:0];
    assign bg_r[7:0] = {8{font_pixel}};
    assign bg_g[7:0] = {8{font_pixel}};
    assign bg_b[7:0] = {8{font_pixel}};
    assign dbg_sync = dvi_vs;

    //Debug
    assign gb_r[7:0] = dvi_x[9:2];
    assign gb_g[7:0] = dvi_x[9:2];
    assign gb_b[7:0] = dvi_y[8:1];

    dvi_timing dvi_timing(
      .clk(clk),
      .rst(rst),
      .hs(dvi_hs),
      .vs(dvi_vs),
      .x(dvi_x),
      .y(dvi_y),
      .enable(dvi_blank),
      .address()
    );

    vga_font vga_font(
      .clk(clk),
      .ascii_code(font_ascii),
      .row(font_row),
      .col(font_col),
      .pixel(font_pixel)
    );    
    
endmodule
