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
    input wire clk,          // 100 MHz clock
    input wire reset,        // Reset button
    output reg [15:0] led    // 16 LED outputs
);

reg [28:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        led <= 16'h0000;
    end
    else if(counter[27]) begin          // Pulse enable
        led <= ~counter[18:3];          // Animated pattern
        counter <= counter + 1;
    end else begin
        led <= 16'h0000;                // LEDs off
        counter <= counter + 1;
    end
end

endmodule
```

## Design Evolution

This was my third iteration. Previous attempts taught me:

**Version 1**: Used counter[35:20] - too slow, pattern barely visible
**Version 2**: Attempted explicit timing with 25M count - overcomplicated, had syntax errors
**Version 3 (Final)**: Elegant solution using single bit as enable, faster update rate

*Kept commented-out versions in source to document learning process.*

## Build Instructions

1. Open Vivado 2023.2
2. Create new project targeting Basys 3 board
3. Add `led_blinker.v` as design source
4. Add constraints file with pin mappings (see `constraints/basys3.xdc`)
5. Run Synthesis → Implementation → Generate Bitstream
6. Program device via USB

## Constraints
```tcl
## Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 [get_ports clk]

## Reset Button (Center)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## LEDs [15:0]
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
# ... [full LED mappings in constraints file]
```

## What I Learned

1. **Hardware timing is different**: A 100 MHz clock means things happen FAST. Bit 27 of counter = ~1.34s, bit 20 = ~10ms
2. **Simulation before synthesis**: Would have caught my V2 bugs immediately
3. **Keep it simple**: V3 is 10 lines vs V2's complexity, and works better
4. **Visual feedback is powerful**: Seeing LEDs respond to code is incredibly satisfying
5. **Reset is critical**: Clean initialization prevents weird startup states

## Next Steps

Moving on to VGA display controller to learn:
- Precise timing constraints (nanosecond-level)
- Multi-module hierarchical design
- External interface protocols
- More complex state machines

## Tools Used

- Xilinx Vivado 2023.2
- Verilog HDL
- Digilent Basys 3 board

---

**Date**: October 2024  
**Status**: ✅ Working  
**Build Time**: ~2 hours (including learning Vivado workflow)

Add LED blinker - first working FPGA project

- Implements pulsing LED pattern using 29-bit counter
- Uses bit 27 as enable for rhythmic effect
- Displays inverted counter bits [18:3] on LEDs
- Clean synchronous design with async reset
- Validated on Basys 3 hardware
