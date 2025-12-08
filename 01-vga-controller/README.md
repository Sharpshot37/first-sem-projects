# VGA Display Controller

FPGA-based VGA controller implemented in Verilog, generating 640x480@60Hz video output with color display capabilities.

## Overview

This project implements a VGA display controller on the Digilent Basys 3 FPGA board (Xilinx Artix-7). The controller generates proper VGA timing signals and displays color patterns on a standard VGA monitor.

## Current Status

- Working VGA signal generation at 640x480@60Hz
- Proper horizontal and vertical sync timing
- Color pattern display capability
- IN PROGRESS: Image display from block RAM (in progress)

## Technical Implementation

- **Clock Management**: 100 MHz system clock divided to 25.175 MHz pixel clock
- **Timing Generator**: Dual counter architecture for horizontal (800 pixels) and vertical (525 lines) timing
- **Sync Signals**: Generates hsync and vsync pulses meeting VGA specification
- **Color Output**: 12-bit RGB color (4 bits per channel)

### VGA Timing Specifications

| Parameter | Value |
|-----------|-------|
| Resolution | 640x480 |
| Refresh Rate | 60 Hz |
| Pixel Clock | 25.175 MHz |
| Horizontal Total | 800 pixels |
| Vertical Total | 525 lines |

## Hardware

- Digilent Basys 3 FPGA Board (Artix-7 XC7A35T)
- VGA cable
- VGA monitor

## Tools

- Xilinx Vivado Design Suite
- Verilog HDL
- Basys 3 constraints file (.xdc)

## What I Learned

- Clock domain management and clock division techniques
- Meeting strict hardware timing constraints
- VGA protocol and display timing specifications
- State machine design for video signal generation
- FPGA synthesis and implementation workflow

## Next Steps

- [ ] Implement block RAM for image storage
- [ ] Add ability to display bitmap images
- [ ] Optimize memory access patterns
- [ ] Add pattern generation modes

## Project Context

This is my first FPGA project as I transition from Mechanical Engineering to Electrical Engineering at UT Austin. I'm focusing on digital design and hardware acceleration, with goals in FPGA development for high-frequency trading systems and semiconductor design.

---

[LinkedIn](linkedin.com/lakshay--yadav) | Transitioning ME → ECE @ UT Austin
