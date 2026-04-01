# FPGA Keypad Calculator on Artix-7

A Verilog-based calculator implemented on an Artix-7 FPGA board using a 4x4 keypad and onboard 4-digit 7-segment display.

## Features

- Multi-digit input
- `A` = Add
- `B` = Subtract
- `C` = Multiply
- `D` = Divide
- `#` = Show result
- `*` = Reset
- Negative number support
- Decimal-point support for division
- Scrolling for values longer than 4 digits
- Operator display (`ADD`, `SUB`, `MUL`, `DIV`)

## Files

- `top.v` - Top-level module
- `decoder.v` - Keypad scanning and decoding
- `calculator.v` - Arithmetic and control logic
- `seg7_control.v` - 7-segment display control
- `xdc.xdc` - Pin constraints

## Example

- `12 A 34 #` -> `46`
- `5 C 5 #` -> `25`
- `13 D 4 #` -> `3.25`

## Hardware

- Artix-7 FPGA development board
- 4x4 matrix keypad
- 4-digit 7-segment display

## Notes

The keypad is scanned using row-column scanning.  
The calculator performs arithmetic in hardware, and the result is shown on the multiplexed 7-segment display.

## Author

Manoj
