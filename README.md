# 16-bit Carry-Lookahead Adder

## Project Overview
This project implements a 16-bit Carry-Lookahead Adder (CLA) designed to address the delay issues in traditional adder designs. The CLA significantly improves performance by reducing carry propagation delay through parallel generation and propagation of carry bits. This repository contains the complete implementation including RTL design, verification testbenches, and synthesis files.

## Institution
Bangladesh University of Engineering and Technology (BUET)  
Department of Electrical and Electronic Engineering

## Course Details
- **Course**: EEE 468 - VLSI Circuit and Design Laboratory (July 2024)
- **Section**: G3
- **Group**: 03

## Instructors
- Nafis Sadik, Lecturer, EEE, BUET
- Rafid Hassan Palash, Part-Time Lecturer, EEE, BUET

## Team Members and Contributions

| Name | ID | Contribution |
|------|----|----|
| Anindya Kishore Choudhury | 1906081 | - Coordination<br>- Literature Review<br>- RTL Architecture Selection<br>- RTL Design Code<br>- Directed Testbench Code<br>- Self-Checking Testbench Code<br>- Parameterized Layered Testbench<br>- Testbench Coverage Data Analysis<br>- Report Preparation |
| MD. Toky Tazwar | 1906174 | - Synthesis File Generation<br>- Power, Area and Timing reports generation from Genus<br>- Troubleshooting<br>- Changing SDC file according to our design<br>- TCL file generation<br>- Verifying coherence of RTL design with synthesized design<br>- Report Preparation |
| Akif Hamid | 1906192 | - Design Iterations<br>- Troubleshooting<br>- Verifying different architectures<br>- Modifying Floorplan to increase density<br>- Modifying Pin Planning<br>- Finding optimal power rail placement<br>- Data Analysis for control parameters in Genus |
| Nusrat Jahan Anila | 1906193 | - Core Implementation<br>- Ensuring proper CTS without errors<br>- Changing SDC file to cater to our design<br>- Ensuring proper DRC results for initial design flow<br>- Generating necessary reports such as density, area and timing from Innovus |

## Project Description

The Carry-Lookahead Adder (CLA) addresses a fundamental challenge in digital arithmetic: the carry propagation delay. In traditional adder designs like the Ripple Carry Adder, each bit's calculation depends on the carry from the previous stage, creating a sequential chain that slows down the operation. The CLA improves performance by calculating all carries simultaneously through the parallel generation of carry bits.

Our implementation divides the 16-bit adder into four 4-bit modules, balancing speed and hardware complexity. This hierarchical structure was chosen after careful consideration of fan-in requirements and optimization equations.

The project involved comprehensive verification through:
- Directed testbench for basic verification
- Self-checking testbench with automated comparison
- Layered testbench with SystemVerilog for thorough coverage analysis

We conducted detailed Power, Performance, and Area (PPA) optimization through architectural changes, parameter analysis in Genus, and physical design optimization during Place and Route.

## Key Components

### RTL Design
- Modular approach with separate generate-propagate, base4-carry, and summation units
- SystemVerilog implementation with type declarations for improved readability
- Hierarchical organization for simplified debugging and verification

### Verification Strategy
- Progressive transaction scaling from 5 to 240,000 transactions
- 1024-bin coverage model for comprehensive input space verification
- Detailed analysis of corner cases including zero-input and overflow conditions

### Synthesis and Implementation
- Optimization for multiple frequencies (1MHz to 1GHz)
- Parameter sweeps for input/output delays
- Physical design with optimized floorplanning and pin placement

## Results

The implementation successfully demonstrates the advantages of the Carry-Lookahead Adder architecture. Key metrics include:
- Positive slack time for both setup and hold analysis
- Design density of 23.96%
- Total area of 169 μm²
- Final slack time of 8.541 ns

Our verification approach achieved comprehensive coverage across the input space, with statistical analysis confirming proper operation across all possible scenarios.

## Project Structure

- `/rtl` - RTL design files
- `/testbench` - Verification testbenches
- `/synthesis` - Synthesis scripts and reports
- `/implementation` - Place and Route files
- `/docs` - Documentation and reports

## References

1. G. B. Rosenberger, "Simultaneous Carry Adder". US Patent 2966305, 27 December 1960.
2. N. H. E. W. a. D. M. Harris, CMOS VLSI design: a circuits and systems perspective, Noida: Pearson, 2015.
3. E. D. a. LangT, Digital arithmetic, San Francisco: Morgan Kaufmann Publishers, 2004.
4. P. B. a. D. L. Maskell, "A New Carry Look-Ahead Adder Architecture Optimized for Speed and Energy," in Electronics, Sep. 2024.
