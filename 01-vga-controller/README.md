# VGA Image Display Controller on FPGA

Hardware VGA controller implemented in Verilog on Xilinx Artix-7 FPGA, capable of displaying 640x480@60Hz video with stored image display from block RAM.

![VGA Demo](https://youtube.com/shorts/ESjALKSlm3E?feature=share)

## Overview

This project implements a complete VGA display system that generates proper timing signals and displays images stored in FPGA block RAM. The controller meets VGA industry timing specifications and demonstrates precise hardware timing constraints, memory management, and real-time video signal generation.

## Features

- ✅ VGA 640x480@60Hz timing generation
- ✅ 12-bit RGB color output (4096 colors)
- ✅ Block RAM image storage and retrieval
- ✅ Pixel-perfect timing synchronization
- ✅ Modular Verilog design architecture
- ✅ Image display from memory

## Technical Implementation

### System Architecture
```
100 MHz Clock → Clock Divider → 25.175 MHz Pixel Clock
                                        ↓
                                 VGA Controller
                                 /            \
                    Timing Generator      Block RAM
                    (hsync, vsync)      (Image Storage)
                                 \            /
                                  Pixel Generator
                                        ↓
                                  RGB Output
```

### Clock Management
- **Input:** 100 MHz system clock (Basys 3 board)
- **Output:** 25.175 MHz pixel clock (generated via clock divider)
- **Method:** Counter-based frequency division with enable signal

### Timing Generator
Implements precise VGA timing for 640x480@60Hz:

**Horizontal Timing (per line):**
| Region | Pixels | Timing |
|--------|--------|--------|
| Visible Area | 640 | Active video output |
| Front Porch | 16 | Pre-sync blanking |
| Sync Pulse | 96 | Hsync signal (active low) |
| Back Porch | 48 | Post-sync blanking |
| **Total** | **800** | Complete line period |

**Vertical Timing (per frame):**
| Region | Lines | Timing |
|--------|-------|--------|
| Visible Area | 480 | Active video lines |
| Front Porch | 10 | Pre-sync blanking |
| Sync Pulse | 2 | Vsync signal (active low) |
| Back Porch | 33 | Post-sync blanking |
| **Total** | **525** | Complete frame period |

**Timing calculations:**
- Pixel clock: 25.175 MHz
- Line time: 800 pixels × 39.72 ns = 31.78 μs
- Frame time: 525 lines × 31.78 μs = 16.68 ms
- Refresh rate: 1 / 16.68 ms = 59.94 Hz ≈ 60 Hz

### Block RAM Implementation

**Image Storage:**
- Stores bitmap image data in FPGA block RAM
- Addresses calculated from current pixel position (x, y)
- Memory organization: row-major format
- Data width: 12 bits (4R, 4G, 4B)

**Memory Access Pattern:**
```
address = (y_position × image_width) + x_position
rgb_data = memory[address]
```

**Advantages of Block RAM:**
- Fast access (single clock cycle read)
- Sufficient size for moderate resolution images
- On-chip storage (no external memory needed)
- Deterministic timing for video generation

### Pixel Generator

Outputs RGB values based on:
- Current pixel coordinates (from timing generator)
- Active video region flag
- Memory data (during image display)
- Blanking intervals (outputs black during sync)

## Hardware Requirements

- **FPGA Board:** Digilent Basys 3 (Xilinx Artix-7 XC7A35T)
- **Display:** VGA-compatible monitor (supports 640x480@60Hz)
- **Cable:** Standard VGA cable (DB-15 connector)
- **Programming:** USB cable for bitstream loading

## Pin Configuration

VGA output pins (12-bit RGB):
- 4-bit Red channel
- 4-bit Green channel  
- 4-bit Blue channel
- Hsync (horizontal sync)
- Vsync (vertical sync)

*(See constraints file for specific Basys 3 pin assignments)*

## Project Structure
```
vga-image-display/
├── src/
│   ├── vga_top.v              # Top-level module
│   ├── clock_divider.v         # Clock generation (100→25 MHz)
│   ├── vga_timing.v            # Timing generator (counters, sync)
│   ├── image_memory.v          # Block RAM wrapper
│   └── pixel_generator.v       # RGB output logic
├── constraints/
│   └── basys3.xdc              # Pin assignments & timing constraints
├── images/
│   └── image.mem               # Memory initialization file
├── sim/
│   └── vga_tb.v                # Testbench (optional)
└── README.md
```

## How to Build

### Prerequisites
- Xilinx Vivado Design Suite (2023.2 or later)
- Digilent Basys 3 board drivers installed

### Steps

1. **Clone repository**
```bash
git clone [your-repo-url]
cd vga-image-display
```

2. **Open in Vivado**
```bash
vivado vga_image_display.xpr
```

3. **Generate bitstream**
   - Run Synthesis
   - Run Implementation  
   - Generate Bitstream
   - Check timing report (should meet all constraints)

4. **Program FPGA**
   - Connect Basys 3 board via USB
   - Power on board
   - Open Hardware Manager in Vivado
   - Program device with generated .bit file

5. **Connect display**
   - Connect VGA cable between Basys 3 and monitor
   - Monitor should display the stored image

## Image Conversion Process

To display your own images:

1. **Prepare image**
   - Resize to fit memory (e.g., 256×256, 320×240)
   - Convert to bitmap format

2. **Convert to memory file**
   - Use Python/MATLAB to convert image to hex values
   - Format: one 12-bit RGB value per line
   - Save as `.mem` or `.coe` file

3. **Update memory initialization**
   - Reference `.mem` file in Block RAM instantiation
   - Adjust image dimensions in pixel generator
   - Re-synthesize design

*(Script for image conversion can be added as separate tool)*

## Technical Challenges & Solutions

### Challenge 1: Meeting Timing Constraints
**Problem:** VGA timing is non-negotiable - any deviation causes display issues
**Solution:** 
- Used synchronous design throughout
- Verified timing closure in implementation reports
- Added pipeline registers where needed
**Result:** All timing constraints met with positive slack

### Challenge 2: Memory Addressing
**Problem:** Calculating memory address from (x,y) coordinates in real-time
**Solution:**
- Pre-calculated address formula in combinational logic
- Ensured address generation completes within pixel clock period
- Added boundary checking to prevent invalid addresses
**Result:** Glitch-free image display

### Challenge 3: Clock Domain Management
**Problem:** System clock (100 MHz) vs. pixel clock (25 MHz)
**Solution:**
- Generated pixel clock enable signal instead of actual divided clock
- Kept all logic on single clock domain with enable
- Avoided metastability issues
**Result:** Stable, reliable operation

## What I Learned

**Hardware Design Fundamentals:**
- Meeting strict real-time timing constraints (every clock cycle matters)
- Understanding the relationship between clock frequency and video resolution
- Clock domain management and synchronous design principles
- Memory bandwidth and access pattern optimization

**FPGA Development:**
- Xilinx Vivado toolchain workflow (RTL → synthesis → implementation → bitstream)
- Reading and interpreting timing reports
- Constraints file creation for pin assignment and timing
- Block RAM instantiation and initialization
- Difference between simulation and actual hardware behavior

**VGA Protocol:**
- Raster scan display architecture and blanking intervals
- Sync signal timing and polarity requirements
- Color encoding for analog video (RGB through resistor DAC)
- How refresh rate, resolution, and pixel clock relate

**Design Methodology:**
- Modular design and separation of concerns
- Building complex systems from simple, testable components
- Importance of proper documentation and version control
- Iterative development (colors → patterns → images)

## Performance Metrics

- **Resolution:** 640×480 pixels
- **Refresh Rate:** 60 Hz
- **Pixel Clock:** 25.175 MHz
- **Memory Usage:** ~307 Kbits for full-screen image (640×480×12)
- **FPGA Resources:** <5% of Artix-7 logic (leaving room for expansion)
- **Timing Slack:** Positive on all paths (design meets timing)

## Applications & Relevance

**Real-Time Systems:**
- Foundation for understanding hardware timing constraints
- Critical for low-latency applications (HFT, embedded systems)
- Demonstrates meeting strict deterministic deadlines

**Display & Graphics:**
- Basis for more complex graphics pipelines
- Understanding of video signal generation
- Frame buffer and memory management concepts

**FPGA Development:**
- Memory interfacing and management
- High-speed synchronous design
- Meeting industry-standard protocols

## Future Enhancements

**Short Term:**
- Multiple image storage (switch between images)
- Simple sprite/overlay system
- Hardware-accelerated pattern generation modes

**Medium Term:**
- Double buffering for animation
- Hardware scrolling/panning
- Basic 2D graphics primitives (lines, rectangles)

**Long Term:**
- Frame buffer with external SDRAM
- DMA for efficient memory updates
- Video processing pipeline (scaling, filtering)
- Higher resolutions (800×600, 1024×768)

## Project Context

**Learning Goals:**
- Master FPGA development for high-performance applications
- Build expertise in hardware acceleration and real-time systems

**Why This Project:**
- VGA teaches fundamental timing discipline needed for any real-time hardware
- Memory management skills transfer to all hardware accelerator designs
- Demonstrates ability to meet strict interface specifications
- Foundation for more complex video/graphics projects

## Resources & References

**Technical Documentation:**
- [VGA Timing Standards](http://tinyvga.com/vga-timing/640x480@60Hz)
- Xilinx 7 Series FPGA Documentation
- Digilent Basys 3 Reference Manual

**Learning Resources:**
- "FPGA Prototyping by Verilog Examples" by Pong P. Chu (Chapter 13: VGA Controller)
- Nandland FPGA tutorials
- Various FPGA development communities and forums

**Tools:**
- Xilinx Vivado ML Edition 2023.2
- Hardware: Digilent Basys 3 FPGA board

## License

MIT

---

**Built by Lakshay Yadav** | ECE @ UT Austin

Interested in FPGA development for high-frequency trading, semiconductor design, and hardware acceleration.

[LinkedIn](https://www.linkedin.com/in/lakshay--yadav/) | [Portfolio](#) | [Email](lakshayyadav003@gmail.com)

*Last Updated: December 2024*
