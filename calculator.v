module calculator(
    input clk,
    input [3:0] key,
    input key_valid,
    output reg signed [31:0] display_value = 0,
    output reg [2:0] display_mode = 3'd0,
    output reg [1:0] decimal_places = 2'd0
    );

    reg signed [31:0] num1 = 0;
    reg signed [31:0] num2 = 0;
    reg [1:0] op = 0;
    reg entering_second = 1'b0;
    reg num1_started = 1'b0;
    reg num2_started = 1'b0;
    reg num1_negative = 1'b0;
    reg num2_negative = 1'b0;
    reg key_busy = 1'b0;
    reg [18:0] release_counter = 0;

    always @(posedge clk) begin
        if (key_valid) begin
            release_counter <= 19'd250000;
            if (!key_busy) begin
                key_busy <= 1'b1;

                if (key <= 4'd9) begin
                    display_mode <= 3'd0;
                    decimal_places <= 2'd0;
                    if (!entering_second) begin
                        num1_started <= 1'b1;
                        if (num1_negative) begin
                            num1 <= (num1 * 10) - key;
                            display_value <= (num1 * 10) - key;
                        end
                        else begin
                            num1 <= (num1 * 10) + key;
                            display_value <= (num1 * 10) + key;
                        end
                    end
                    else begin
                        num2_started <= 1'b1;
                        if (num2_negative) begin
                            num2 <= (num2 * 10) - key;
                            display_value <= (num2 * 10) - key;
                        end
                        else begin
                            num2 <= (num2 * 10) + key;
                            display_value <= (num2 * 10) + key;
                        end
                    end
                end
                else if (key == 4'hA) begin
                    op <= 2'd0;
                    entering_second <= 1'b1;
                    num2 <= 0;
                    num2_started <= 1'b0;
                    num2_negative <= 1'b0;
                    display_mode <= 3'd1;
                    decimal_places <= 2'd0;
                end
                else if (key == 4'hB) begin
                    if (!entering_second && !num1_started) begin
                        num1_negative <= ~num1_negative;
                        display_value <= 0;
                        display_mode <= num1_negative ? 3'd0 : 3'd5;
                        decimal_places <= 2'd0;
                    end
                    else if (entering_second && !num2_started) begin
                        num2_negative <= ~num2_negative;
                        display_value <= 0;
                        display_mode <= num2_negative ? 3'd0 : 3'd5;
                        decimal_places <= 2'd0;
                    end
                    else begin
                        op <= 2'd1;
                        entering_second <= 1'b1;
                        num2 <= 0;
                        num2_started <= 1'b0;
                        num2_negative <= 1'b0;
                        display_mode <= 3'd2;
                        decimal_places <= 2'd0;
                    end
                end
                else if (key == 4'hC) begin
                    op <= 2'd2;
                    entering_second <= 1'b1;
                    num2 <= 0;
                    num2_started <= 1'b0;
                    num2_negative <= 1'b0;
                    display_mode <= 3'd3;
                    decimal_places <= 2'd0;
                end
                else if (key == 4'hD) begin
                    op <= 2'd3;
                    entering_second <= 1'b1;
                    num2 <= 0;
                    num2_started <= 1'b0;
                    num2_negative <= 1'b0;
                    display_mode <= 3'd4;
                    decimal_places <= 2'd0;
                end
                else if (key == 4'hF) begin
                    display_mode <= 3'd0;
                    case (op)
                        2'd0: begin
                            num1 <= num1 + num2;
                            display_value <= num1 + num2;
                            num1_negative <= ((num1 + num2) < 0);
                            decimal_places <= 2'd0;
                        end
                        2'd1: begin
                            num1 <= num1 - num2;
                            display_value <= num1 - num2;
                            num1_negative <= ((num1 - num2) < 0);
                            decimal_places <= 2'd0;
                        end
                        2'd2: begin
                            num1 <= num1 * num2;
                            display_value <= num1 * num2;
                            num1_negative <= ((num1 * num2) < 0);
                            decimal_places <= 2'd0;
                        end
                        2'd3: begin
                            num1 <= (num2 != 0) ? ((num1 * 100) / num2) : 0;
                            display_value <= (num2 != 0) ? ((num1 * 100) / num2) : 0;
                            num1_negative <= ((num2 != 0) ? (((num1 * 100) / num2) < 0) : 1'b0);
                            decimal_places <= (num2 != 0) ? 2'd2 : 2'd0;
                        end
                    endcase

                    num2 <= 0;
                    entering_second <= 1'b0;
                    num1_started <= 1'b1;
                    num2_started <= 1'b0;
                    num2_negative <= 1'b0;
                end
                else if (key == 4'hE) begin
                    num1 <= 0;
                    num2 <= 0;
                    op <= 0;
                    entering_second <= 1'b0;
                    num1_started <= 1'b0;
                    num2_started <= 1'b0;
                    num1_negative <= 1'b0;
                    num2_negative <= 1'b0;
                    display_value <= 0;
                    display_mode <= 3'd0;
                    decimal_places <= 2'd0;
                end
            end
        end
        else if (release_counter != 0)
            release_counter <= release_counter - 1;
        else
            key_busy <= 1'b0;
    end

endmodule
