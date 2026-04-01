module top(
    input clk_50MHz,
    input [3:0] rows,
    output [3:0] cols,
    output [3:0] an,
    output [6:0] seg,
    output dp
);

    wire [3:0] key;
    wire key_valid;
    wire signed [31:0] display_value;
    wire [2:0] display_mode;
    wire [1:0] decimal_places;

    decoder d(
        .clk_50MHz(clk_50MHz),
        .row(rows),
        .col(cols),
        .dec_out(key),
        .key_valid(key_valid)
    );

    calculator calc(
        .clk(clk_50MHz),
        .key(key),
        .key_valid(key_valid),
        .display_value(display_value),
        .display_mode(display_mode),
        .decimal_places(decimal_places)
    );

    seg7_control display(
        .clk(clk_50MHz),
        .value(display_value),
        .display_mode(display_mode),
        .decimal_places(decimal_places),
        .an(an),
        .seg(seg),
        .dp(dp)
    );

endmodule
