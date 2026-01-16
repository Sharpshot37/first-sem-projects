# Hardware & Embedded Systems Portfolio

**Lakshay Yadav | Electrical & Computer Engineering @ UT Austin**

Building high-performance systems at the intersection of hardware, embedded software, and real-time computing. Focused on FPGA development, sensor fusion, and low-latency applications for autonomous systems.

[LinkedIn](https://linkedin.com/in/lakshay--yadav/) | [GitHub](github.com/lakshayyadav) | lakshayyadav003@gmail.com

---

## About Me

**Current:** ECE Student at UT Austin

**Focus Areas:**
- FPGA development for hardware acceleration
- Real-time embedded systems
- Sensor fusion and state estimation

**Previous:** Furnace Improvement Services (refinery operations, CAD modeling, CNC machining), Abraham Professional Services TMT division

---

## Featured Projects

### 1. FPGA Bitonic Sorting Network
**[View Project →](./03-sort-network)**

8-element hardware sorting network on Basys 3 FPGA demonstrating parallel comparison architecture for deterministic, low-latency sorting.

**Key Achievement:** Complete 6-stage bitonic sort with guaranteed O(log²n) depth - sorts any input permutation in exactly 6 clock cycles.

**Technical Highlights:**
- 24 parallel comparators across 6 pipeline stages
- Mathematical proof of correctness via bitonic merge algorithm
- Real-time verification LED display
- Deterministic latency (critical for HFT applications)

**What I Learned:**
- The hard way: difference between swapping inputs vs outputs in hardware
- Why 3 stages creates a bitonic sequence but doesn't fully sort (needed all 6)
- Debugging subtle bit-width mismatches that synthesis didn't catch
- How hardware algorithms either work perfectly or fail completely - no "close enough"

**Tech:** Verilog HDL, Xilinx Vivado, Basys 3 (Artix-7), Hardware acceleration concepts

**Relevance:** Direct application to orderbook management - demonstrates understanding of parallel hardware for latency-critical sorting.

---

### 2. 9-DOF Real-Time Sensor Fusion System
**[View Project →](<./9-DOF + GPS Sensor Fusion System>)**

IMU + GPS fusion on Arduino, streaming orientation and position data at 100Hz for real-time visualization and analysis.

**Key Achievement:** Implemented complementary filter achieving ±2° orientation accuracy with deterministic 100Hz update rate despite non-blocking GPS integration.

**Technical Highlights:**
- Multi-rate sensor coordination (100Hz IMU + 1-5Hz GPS)
- Complementary filter with empirically tuned 98/2 gyro/accel weighting
- Tilt-compensated magnetometer heading
- Real-time serial streaming (115200 baud, <0.1% packet loss)
- Live Python dashboard with 8-plot visualization

**What I Learned:**
- Real-time constraints mean 100Hz every single time, not "mostly 100Hz"
- Sensor fusion isn't magic - it's balancing fast-but-drifty with slow-but-accurate data
- Magnetometers are incredibly finicky (recalibrate constantly, keep away from metal)
- Non-blocking I/O design patterns for multi-rate sensors
- Serial protocol design for bandwidth-constrained streaming

**Tech:** Arduino (ATmega328P), MPU9250 IMU, ATGM336H GPS, Python (matplotlib, folium), Serial communication

**Relevance:** Foundation for autonomous/electric systems (drones, vehicles) - same sensor pipeline used in flight controllers and navigation systems for advanced projects.

---

### 3. VGA Image Display Controller
**[View Project →](./01-vga-controller)**

Hardware VGA controller generating 640x480@60Hz video with image display from FPGA block RAM.

**Key Achievement:** Met all VGA timing constraints with positive slack - demonstrates ability to meet strict real-time interface specifications.

**Technical Highlights:**
- Precise timing generation (25.175 MHz pixel clock from 100 MHz system clock)
- VGA 640x480@60Hz industry standard timing (800×525 total with blanking)
- Block RAM integration for image storage and display
- Modular Verilog architecture (clock divider, timing generator, pixel generator)
- <5% FPGA resource utilization (room for expansion)

**What I Learned:**
- Meeting non-negotiable timing constraints (every nanosecond matters)
- Clock domain management and synchronous design discipline
- Reading timing reports and understanding slack analysis
- Memory access patterns for real-time video generation
- Difference between simulation and actual hardware behavior

**Tech:** Verilog HDL, Xilinx Vivado, Basys 3 FPGA, Block RAM, VGA protocol

**Relevance:** Demonstrates mastery of precise hardware timing - essential for any high-speed interface or real-time system.

---

### 4. LED Blinker - First FPGA Project
**[View Project →](./00-led-blinker)**

My first working FPGA design - pulsing LED pattern demonstrating core HDL concepts.

**What I Learned:**
- Hardware timing is fundamentally different (100 MHz = things happen FAST)
- Keep designs simple - elegant beats complex
- Visual feedback is powerful for debugging
- Foundation concepts: synchronous logic, clock domains, reset handling

**Tech:** Verilog HDL, Basys 3 FPGA

---

## Technical Skills

### Hardware Description Languages
- **Verilog HDL:** FPGA design, state machines, timing constraints, synthesis
- **SystemVerilog:** Learning (next step for verification)

### Embedded Systems
- **Arduino (AVR):** Real-time sensor integration, serial protocols, I2C/UART/SPI
- **Programming:** C/C++ for embedded, Python for tooling/visualization
- **Real-Time:** Deterministic timing, interrupt handling, non-blocking I/O patterns

### FPGA Development
- **Tools:** Xilinx Vivado (synthesis, implementation, timing analysis)
- **Hardware:** Basys 3 (Artix-7), experience with constraints and pin planning
- **Concepts:** Parallel processing, pipelining, clock domain crossing, block RAM

### Algorithms & Math
- **Sensor Fusion:** Complementary filters, understanding of Kalman filters
- **Sorting Networks:** Bitonic sort, comparison network theory
- **Signal Processing:** Filtering, noise rejection, data fusion

### Software & Tools
- **Python:** Real-time data visualization (matplotlib), serial communication, data logging
- **Version Control:** Git, GitHub
- **CAD:** SolidWorks (from ME background), Autodesk Inventor
- **Machining:** CNC programming and operation (internship experience)

---

## Project Evolution & Learning Path

**Phase 1: FPGA Fundamentals**
1. LED Blinker → Learned HDL basics, synchronous design
2. VGA Controller → Mastered timing constraints, memory interfacing

**Phase 2: Real-Time Systems**

3. 9-DOF Sensor Fusion → Multi-sensor integration, real-time constraints
4. Bitonic Sorter → Hardware acceleration, parallel algorithms

**Next Phase: Integration**
- Porting sensor fusion to STM32 (higher performance)
- FPGA-based real-time signal processing
- High-frequency data acquisition systems

---

## Why These Projects Matter

### For High-Frequency Trading
- **Bitonic Sorter:** Demonstrates understanding of hardware acceleration for orderbook management
- **Real-Time Systems:** Experience with deterministic latency and precise timing
- **FPGA Development:** Foundation for network packet processing and market data parsing

### For Embedded Systems
- **Sensor Fusion:** Core navigation pipeline for drones and vehicles
- **Real-Time Constraints:** Meeting hard deadlines in safety-critical systems
- **Hardware/Software Integration:** Building complete embedded systems from scratch

### For Hardware Engineering
- **FPGA Expertise:** Parallel processing, timing closure, resource optimization
- **Protocol Implementation:** VGA, serial, I2C - understanding interface specifications
- **System Design:** Building complex systems from modular, testable components

---

## Engineering Philosophy

**Learn by building:** Theory matters, but you really understand when you fight with the hardware at 2 AM debugging why your magnetometer readings are garbage (spoiler: USB cable magnetic field).

**Document the struggles:** My READMEs include the bugs and wrong approaches, not just the polished final version. The learning happens in the mistakes.

**Start simple, iterate:** LED blinker → VGA controller → Sensor fusion. Each project built on the last. Trying to jump straight to complex systems just means debugging everything at once.

**Real constraints teach the most:** You learn real-time systems by missing deadlines and watching your orientation drift. You learn FPGA timing by failing timing closure and reading the reports.

---

## Current Focus

**Spring 2025:**
- Advanced digital design coursework at UT Austin
- Controls and sensor integration
- Building wireless telemetry system

---

## Projects in Progress

**STM32 Sensor Fusion Platform**
- Porting 9-DOF system to ARM Cortex-M4
- Adding Bluetooth for wireless telemetry
- Extended Kalman Filter implementation
- Target: 1000Hz update rate

**FPGA Real-Time Data Acquisition**
- High-speed ADC interfacing
- FIFO buffering and DMA
- Real-time signal processing pipeline

---

## Academic Background

**University of Texas at Austin**
- B.S. Electrical & Computer Engineering (2025-2029)
- Transferred from Mechanical Engineering after discovering passion for embedded systems and hardware
- Relevant Coursework: Digital Logic Design, Embedded Systems, Computer Architecture (planned)

**Previous Engineering Experience:**
- Furnace Improvement Services: Refinery operations, CAD modeling, CNC machining
- Abraham Professional Services: Technology, Media & Telecommunications division
- Hands-on with industrial systems before diving into embedded/hardware

---

## Beyond Engineering

**Teaching:** Lead Cinco SPARK STEM tutoring program for middle school students - explaining complex concepts simply is harder than it looks.

**Competitions:** Science and Engineering Fair of Houston - Jacobs Award for Smart Traffic Light system using ML (84% accuracy plant health monitor in another project).

**Always building something:** Current desk has Arduino, FPGA board, half-disassembled sensors, and an oscilloscope I'm still learning to use properly.

---

## Contact

**Email:** lakshayyadav003@gmail.com

**LinkedIn:** [linkedin.com/in/lakshay--yadav](https://linkedin.com/in/lakshay--yadav/)

**GitHub:** [github.com/lakshayyadav](github.com/lakshayyadav)

**Location:** Austin, Texas

**Status:** Open to internship opportunities (Summer 2025) in FPGA development, embedded systems, hardware acceleration, or HFT infrastructure.

---

## Repository Structure
```
portfolio/
├── bitonic-sorter/           # FPGA sorting network
├── 9dof-sensor-fusion/       # IMU + GPS real-time system
├── vga-controller/           # VGA display hardware
├── led-blinker/              # First FPGA project
└── README.md                 # This file
```

---

**Last Updated:** January 2025

**Built with:** Verilog, C/C++, Python, determination, and a lot of debugging.

**Next:** More FPGA projects, higher-performance embedded systems, and diving deeper into hardware acceleration for real-time applications.
