module seg7_control(
    input clk,
    input signed [31:0] value,
    input [2:0] display_mode,
    input [1:0] decimal_places,
    output reg [3:0] an,
    output reg [6:0] seg,
    output reg dp
    );

    reg [19:0] refresh_counter = 0;
    reg [1:0] digit_select = 0;
    reg [25:0] scroll_counter = 0;
    reg [2:0] scroll_index = 0;
    reg [1:0] start_pause = 0;
    reg [6:0] current_seg;
    reg current_dp;

    reg negative;
    reg signed [31:0] abs_value;
    reg [31:0] temp_value;
    reg [3:0] digits [0:9];
    reg [3:0] total_digits;
    reg [3:0] window_start;
    reg [3:0] frac_digits;
    integer i;

    reg [6:0] slot0;
    reg [6:0] slot1;
    reg [6:0] slot2;
    reg [6:0] slot3;
    reg slot0_dp;
    reg slot1_dp;
    reg slot2_dp;
    reg slot3_dp;

    function [6:0] encode_digit;
        input [3:0] digit;
        begin
            case (digit)
                4'h0: encode_digit = 7'b1000000;
                4'h1: encode_digit = 7'b1111001;
                4'h2: encode_digit = 7'b0100100;
                4'h3: encode_digit = 7'b0110000;
                4'h4: encode_digit = 7'b0011001;
                4'h5: encode_digit = 7'b0010010;
                4'h6: encode_digit = 7'b0000010;
                4'h7: encode_digit = 7'b1111000;
                4'h8: encode_digit = 7'b0000000;
                4'h9: encode_digit = 7'b0010000;
                default: encode_digit = 7'b1111111;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        digit_select <= refresh_counter[16:15];
        scroll_counter <= scroll_counter + 1;
        if (scroll_counter == 26'd25_000_000) begin
            scroll_counter <= 0;
            if (display_mode == 3'd0) begin
                if (negative) begin
                    if (total_digits > 3) begin
                        if ((scroll_index == 0) && (start_pause != 2'd2))
                            start_pause <= start_pause + 1'b1;
                        else begin
                            start_pause <= 0;
                            scroll_index <= (scroll_index == (total_digits - 3)) ? 0 : (scroll_index + 1'b1);
                        end
                    end
                    else begin
                        scroll_index <= 0;
                        start_pause <= 0;
                    end
                end
                else begin
                    if (total_digits > 4) begin
                        if ((scroll_index == 0) && (start_pause != 2'd2))
                            start_pause <= start_pause + 1'b1;
                        else begin
                            start_pause <= 0;
                            scroll_index <= (scroll_index == (total_digits - 4)) ? 0 : (scroll_index + 1'b1);
                        end
                    end
                    else begin
                        scroll_index <= 0;
                        start_pause <= 0;
                    end
                end
            end
            else begin
                scroll_index <= 0;
                start_pause <= 0;
            end
        end
    end

    always @(*) begin
        slot0 = 7'b1111111;
        slot1 = 7'b1111111;
        slot2 = 7'b1111111;
        slot3 = 7'b1111111;
        slot0_dp = 1'b1;
        slot1_dp = 1'b1;
        slot2_dp = 1'b1;
        slot3_dp = 1'b1;
        negative = 1'b0;
        abs_value = 0;
        temp_value = 0;
        total_digits = 1;
        window_start = 0;

        if (display_mode == 3'd1) begin
            slot0 = 7'b0001000; // A
            slot1 = 7'b0100001; // d
            slot2 = 7'b0100001; // d
        end
        else if (display_mode == 3'd2) begin
            slot0 = 7'b0010010; // S
            slot1 = 7'b1000001; // U
            slot2 = 7'b0000011; // b
        end
        else if (display_mode == 3'd3) begin
            slot0 = 7'b0101011; // m approximation
            slot1 = 7'b1000001; // U
            slot2 = 7'b1000111; // L
        end
        else if (display_mode == 3'd4) begin
            slot0 = 7'b0100001; // d
            slot1 = 7'b1111001; // I
            slot2 = 7'b1100011; // V approximation
        end
        else if (display_mode == 3'd5) begin
            slot0 = 7'b0111111; // -
        end
        else begin
            negative = (value < 0);
            abs_value = negative ? -value : value;
            temp_value = abs_value;

            for (i = 0; i < 10; i = i + 1)
                digits[i] = 4'd0;

            if (temp_value == 0) begin
                digits[0] = 4'd0;
                total_digits = 1;
            end
            else begin
                total_digits = 0;
                for (i = 0; i < 10; i = i + 1) begin
                    if (temp_value != 0) begin
                        digits[i] = temp_value % 10;
                        temp_value = temp_value / 10;
                        total_digits = total_digits + 1'b1;
                    end
                end
            end

            if (negative) begin
                frac_digits = decimal_places;
                window_start = (total_digits > (3 + frac_digits)) ? ((total_digits - 3) - scroll_index) : 0;
                slot0 = 7'b0111111;
                if ((window_start + 2) < total_digits)
                    slot1 = encode_digit(digits[window_start + 2]);
                if ((window_start + 1) < total_digits)
                    slot2 = encode_digit(digits[window_start + 1]);
                if (window_start < total_digits)
                    slot3 = encode_digit(digits[window_start]);

                if (decimal_places != 0) begin
                    if ((window_start + 2) == decimal_places)
                        slot1_dp = 1'b0;
                    else if ((window_start + 1) == decimal_places)
                        slot2_dp = 1'b0;
                    else if (window_start == decimal_places)
                        slot3_dp = 1'b0;
                end
            end
            else begin
                frac_digits = decimal_places;
                window_start = (total_digits > 4) ? ((total_digits - 4) - scroll_index) : 0;
                if ((window_start + 3) < total_digits)
                    slot0 = encode_digit(digits[window_start + 3]);
                else
                    slot0 = 7'b1111111;
                if ((window_start + 2) < total_digits)
                    slot1 = encode_digit(digits[window_start + 2]);
                else
                    slot1 = 7'b1111111;
                if ((window_start + 1) < total_digits)
                    slot2 = encode_digit(digits[window_start + 1]);
                else
                    slot2 = 7'b1111111;
                if (window_start < total_digits)
                    slot3 = encode_digit(digits[window_start]);
                else
                    slot3 = 7'b1111111;

                if (decimal_places != 0) begin
                    if ((window_start + 3) == decimal_places)
                        slot0_dp = 1'b0;
                    else if ((window_start + 2) == decimal_places)
                        slot1_dp = 1'b0;
                    else if ((window_start + 1) == decimal_places)
                        slot2_dp = 1'b0;
                    else if (window_start == decimal_places)
                        slot3_dp = 1'b0;
                end
            end
        end
    end

    always @(*) begin
        case (digit_select)
            2'b00: begin an = 4'b0001; current_seg = slot0; current_dp = slot0_dp; end
            2'b01: begin an = 4'b0010; current_seg = slot1; current_dp = slot1_dp; end
            2'b10: begin an = 4'b0100; current_seg = slot2; current_dp = slot2_dp; end
            default: begin an = 4'b1000; current_seg = slot3; current_dp = slot3_dp; end
        endcase
    end

    always @(*) begin
        seg = current_seg;
        dp = current_dp;
    end

endmodule
