`timescale 1ns / 1ps

module decoder(
    input clk_50MHz,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] dec_out,
    output reg key_valid
    );

    parameter LAG = 10;

    reg [19:0] scan_timer = 0;
    reg [1:0] col_select = 0;

    // 50 MHz -> 1 ms scan per column
    always @(posedge clk_50MHz)
        if (scan_timer == 49_999) begin
            scan_timer <= 0;
            col_select <= col_select + 1;
        end
        else
            scan_timer <= scan_timer + 1;

    always @(posedge clk_50MHz) begin
        key_valid <= 1'b0;

        case (col_select)
            2'b00: begin
                col <= 4'b0111;
                if (scan_timer == LAG)
                    case (row)
                        4'b0111: begin dec_out <= 4'h1; key_valid <= 1'b1; end
                        4'b1011: begin dec_out <= 4'h4; key_valid <= 1'b1; end
                        4'b1101: begin dec_out <= 4'h7; key_valid <= 1'b1; end
                        4'b1110: begin dec_out <= 4'hE; key_valid <= 1'b1; end
                    endcase
            end

            2'b01: begin
                col <= 4'b1011;
                if (scan_timer == LAG)
                    case (row)
                        4'b0111: begin dec_out <= 4'h2; key_valid <= 1'b1; end
                        4'b1011: begin dec_out <= 4'h5; key_valid <= 1'b1; end
                        4'b1101: begin dec_out <= 4'h8; key_valid <= 1'b1; end
                        4'b1110: begin dec_out <= 4'h0; key_valid <= 1'b1; end
                    endcase
            end

            2'b10: begin
                col <= 4'b1101;
                if (scan_timer == LAG)
                    case (row)
                        4'b0111: begin dec_out <= 4'h3; key_valid <= 1'b1; end
                        4'b1011: begin dec_out <= 4'h6; key_valid <= 1'b1; end
                        4'b1101: begin dec_out <= 4'h9; key_valid <= 1'b1; end
                        4'b1110: begin dec_out <= 4'hF; key_valid <= 1'b1; end
                    endcase
            end

            2'b11: begin
                col <= 4'b1110;
                if (scan_timer == LAG)
                    case (row)
                        4'b0111: begin dec_out <= 4'hA; key_valid <= 1'b1; end
                        4'b1011: begin dec_out <= 4'hB; key_valid <= 1'b1; end
                        4'b1101: begin dec_out <= 4'hC; key_valid <= 1'b1; end
                        4'b1110: begin dec_out <= 4'hD; key_valid <= 1'b1; end
                    endcase
            end
        endcase
    end

endmodule
