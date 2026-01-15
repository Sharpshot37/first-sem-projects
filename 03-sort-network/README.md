# FPGA-Based Bitonic Sorting Network

A hardware implementation of an 8-element bitonic sorting network on the Basys 3 FPGA board, demonstrating parallel sorting capabilities for low-latency applications.

## Project Overview

[Sorter Test Demo](https://youtube.com/shorts/ynG0d_Cr9hc?feature=share) 

[Sorter Switch Demo](https://youtube.com/shorts/aax7-ZTvH5Q?feature=share)

This project implements a complete 6-stage bitonic sorting network in Verilog, capable of sorting eight 3-bit numbers (0-7) in deterministic time. The design showcases hardware parallelism and serves as a foundation for understanding high-frequency trading (HFT) systems where predictable, low-latency data processing is critical.

**Key Features:**
- 8-element sorting network with 24 comparison units
- 6-stage pipeline architecture
- Deterministic O(log²n) comparison depth
- Real-time visual feedback via LED indicators
- Guaranteed correctness for all input permutations

## Hardware Requirements

- Xilinx Basys 3 FPGA Development Board
- Vivado Design Suite 2019.1 or later
- USB cable for programming

## Design Architecture

### Bitonic Sort Algorithm

The bitonic sorting network builds upon the bitonic merge algorithm, which exploits a key property: a bitonic sequence (one that monotonically increases then decreases, or vice versa) can be efficiently sorted through a series of compare-and-swap operations.

**Pipeline Stages:**
1. **Stage 1:** Create alternating ascending/descending pairs (distance 1)
2. **Stage 2:** Merge pairs into 4-element bitonic sequences (distance 2)
3. **Stage 3:** Complete 4-element sorts (distance 1)
4. **Stage 4:** Merge into 8-element bitonic sequence (distance 4)
5. **Stage 5:** Continue merge (distance 2)
6. **Stage 6:** Final sort (distance 1)

### Module Hierarchy
```
impu (Top Module)
├── bitonic (Sorting Network)
│   └── order (Comparator) × 24 instances
└── LED Output Logic
```

## Implementation Details

### Comparator Module
```verilog
module order(
    input wire [2:0] a,
    input wire [2:0] b,
    input wire clk,
    input wire reset,
    output wire [2:0] c,  // min(a, b)
    output wire [2:0] d   // max(a, b)
);
    assign c = (a < b) ? a : b;
    assign d = (a < b) ? b : a;
endmodule
```

The comparator uses combinational logic to produce min/max outputs, ensuring zero additional latency per comparison.

### Test Pattern

The default test input `[7, 2, 5, 1, 6, 3, 4, 0]` sorts to `[0, 1, 2, 3, 4, 5, 6, 7]`, with results displayed on the board's LEDs:
- **LED 15:** Sorting verification indicator (ON = correctly sorted)
- **LEDs 14-12:** Smallest number (sorted[0])
- **LEDs 11-9:** Second number (sorted[1])
- **LEDs 8-6:** Largest number (sorted[7])
- **LEDs 5-3:** Middle number (sorted[3])
- **LEDs 2-0:** Status indicators (always ON)

## Development Journey & Lessons Learned

### Challenge 1: Understanding Bitonic Sequence Construction

**Initial Mistake:** My first implementation used only 3 stages, which created a partially-ordered bitonic sequence but failed to complete the sort. The extrema (minimum and maximum) ended up in correct positions, but middle values remained scrambled.

**Learning:** Bitonic sort for 8 elements mathematically requires 6 stages (n(n+1)/2 where n=3 for 2³ elements). The algorithm has two distinct phases:
- Stages 1-3: Build the bitonic sequence
- Stages 4-6: Sort the bitonic sequence

Attempting to skip stages doesn't produce a sorted output—it's not a gradual improvement but a fundamental algorithmic requirement.

### Challenge 2: Input vs. Output Swapping

**Initial Mistake:** I attempted to create descending pairs by swapping the output connections:
```verilog
order(a, b, ..., stage[i+1], stage[i]);  // Wrong approach
```

This scrambled data placement without actually reversing the sort direction.

**Learning:** The comparator always outputs min then max. To create a descending pair, you must swap the *inputs*, not the outputs:
```verilog
order(b, a, ..., stage[i], stage[i+1]);  // Correct approach
```

This was counterintuitive at first—the key insight is that "descending" refers to how the sorting network builds the bitonic structure, not the literal order of output values. The algorithm requires specific ascending/descending patterns at each stage to maintain the bitonic property that enables efficient merging.

### Challenge 3: Bit Width Declarations

**Initial Mistake:** Declared comparator outputs as single bits instead of 3-bit buses:
```verilog
output wire c,  // Only 1 bit!
output wire d   // Only 1 bit!
```

This caused data truncation, preserving only the LSB and losing the upper 2 bits.

**Learning:** Always verify signal widths match throughout the hierarchy. Synthesis tools may not flag width mismatches as errors, leading to subtle logical bugs that manifest as incorrect results.

### Challenge 4: Wrong Stage Output

**Initial Mistake:** After implementing all 6 stages correctly, I accidentally output `stage3` instead of `stage6`:
```verilog
sout <= {stage3[...], ...};  // Outputs bitonic sequence, not sorted!
```

LED 15 remained off because I was verifying an intermediate bitonic sequence rather than the final sorted output.

**Learning:** In complex multi-stage designs, explicitly trace data flow and verify each connection. The sorting network was functionally correct—I simply wasn't observing the right signal.

### Challenge 5: Stage Connection Patterns

**Initial Mistake:** Inconsistent input/output position mappings across stages, particularly in Stage 2's bottom half where I had:
```verilog
order(..., stage2[7], stage2[5]);  // Scrambled positions
order(..., stage2[6], stage2[4]);  // Scrambled positions
```

**Learning:** Bitonic sort has a mathematically proven connection pattern. Deviating from this pattern—even if the changes seem symmetrical or logical—breaks the algorithm. The positions matter because subsequent stages expect data in specific locations to maintain the bitonic merge property.

## Key Takeaways

1. **Hardware algorithms are unforgiving:** Unlike software where you might get "close enough" results, hardware sorting networks either work perfectly or fail completely. There's no partial credit.

2. **Mathematical foundations matter:** Understanding *why* bitonic sort requires 6 stages and specific connection patterns prevented me from making arbitrary "optimizations" that would break the algorithm.

3. **Swap semantics are subtle:** The distinction between input swapping (changes sort direction) and output swapping (scrambles data) is crucial but non-obvious. This highlighted the importance of deeply understanding each component's behavior.

4. **Systematic debugging is essential:** When faced with incorrect LED patterns, I learned to:
   - Trace through each stage manually with example data
   - Verify bit widths at every connection
   - Check that output assignments reference the correct stage
   - Confirm input/output position mappings match the algorithm

5. **Verification is critical:** Even after "finishing" the implementation, verifying the output stage and testing with multiple input patterns revealed hidden issues.

## Testing & Verification

The design has been verified to correctly sort:
- Already sorted sequences
- Reverse sorted sequences  
- Random permutations
- Edge cases (all same values, binary patterns)

The 0-1 principle guarantees that if the network correctly sorts all binary sequences, it correctly sorts all sequences of any values.

## Performance Characteristics

- **Latency:** 6 clock cycles (deterministic)
- **Throughput:** 1 sort per clock cycle (pipelined)
- **Resource Usage:** 24 comparators (LUTs), pipeline registers
- **Clock Frequency:** Limited by combinational path delay through comparators

## Future Enhancements

- Implement full pipelining with registers between stages for higher throughput
- Extend to 16 or 32 elements for more practical sorting applications
- Add parameterized bit width for larger value ranges
- Interface with external memory for larger datasets
- Timing analysis and optimization for maximum clock frequency

## Applications

Bitonic sorting networks are particularly valuable in:
- **High-Frequency Trading:** Deterministic latency for order book management
- **Network Packet Processing:** Parallel packet prioritization
- **GPU Computing:** SIMD-friendly sorting for graphics pipelines
- **Real-Time Systems:** Predictable worst-case execution time

## Repository Structure
```
.
├── src/
│   ├── bitonic.v          # Main sorting network
│   ├── order.v            # Comparator module
│   └── impu.v             # Top-level module
├── constraints/
│   └── basys3.xdc         # Pin assignments
├── sim/
│   └── bitonic_tb.v       # Testbench
└── README.md
```

## Building & Running

1. Open Vivado and create new project
2. Add all source files from `src/`
3. Add constraints file from `constraints/`
4. Set `impu` as top module
5. Run Synthesis → Implementation → Generate Bitstream
6. Program FPGA via USB

## License

MIT License - Feel free to use for educational purposes

## Acknowledgments

This project was developed as part of learning FPGA design and hardware acceleration concepts. The development process involved extensive debugging and iteration to understand the subtle requirements of hardware sorting networks.

---

**Author:** Lakshay Yadav  
**Date:** January 2026  
**Board:** Basys 3 (Artix-7)  
**Tools:** Vivado 2019.1, Verilog HDL
