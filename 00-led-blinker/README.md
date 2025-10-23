# LED Blinker - First FPGA Project

My first working FPGA design on the Basys 3 board. A simple yet effective introduction to hardware description language and FPGA development workflow.

## Demo

https://youtube.com/shorts/3799ZVqMtzU?feature=share

## What It Does

Creates a pulsing LED pattern that:
- Displays a 16-bit animated pattern across all LEDs
- Pulses on/off using bit 27 of the counter as an enable signal
- Shows bits [18:3] of the counter (inverted) when active
- Creates a visually interesting scanning effect

At 100 MHz clock:
- Full pulse cycle: ~1.34 seconds (2^27 clock cycles)
- LED pattern updates continuously within each pulse
- All LEDs turn off between pulses for rhythmic effect

## Technical Implementation

**Core Design:**
- 29-bit counter for timing
- Conditional logic using counter bit 27 as pulse enable
- Inverted bit slice [18:3] creates the LED pattern
- Synchronous reset for clean initialization

**Key Concepts Learned:**
- Synchronous logic design with always blocks
- Clock domain understanding (100 MHz system clock)
- Reset handling (asynchronous reset, synchronous logic)
- Bit manipulation and slicing
- Conditional assignments in sequential logic

## Hardware

- **Board**: Digilent Basys 3 (Artix-7 FPGA)
- **Clock**: 100 MHz onboard oscillator
- **Inputs**: Center button (reset)
- **Outputs**: 16 LEDs

## Code Structure
```verilog

module led_blinker(
    input wire clk,
    input wire reset,
    output reg [15:0] led
);

reg [28:0] counter;
reg [15:0] on;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <=0;
        led <=16'h000;
    end
    else if(counter[27]) begin
        led<=~counter[18:3];
        counter<=counter+1;
    end else begin
        led<=16'h000;
        counter<=counter +1;
    end
    end
endmodule

```
