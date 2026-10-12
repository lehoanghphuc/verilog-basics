# Verilog Basics

Small RTL design exercises in Verilog/SystemVerilog, each with a
self-checking testbench. Simulated with Icarus Verilog.

## Projects

| Folder | Description |
|---|---|
| `counter/` | 4-bit counter with synchronous reset and enable. Wraps from 15 to 0. |
| `fsm_traffic/` | 3-state traffic light FSM (RED -> GREEN -> YELLOW) with synchronous reset and enable. |

Each testbench prints `PASS` or `FAIL` for every check, so no waveform
inspection is needed to see whether the design is correct.

## Run

    cd counter        # or fsm_traffic
    iverilog -g2012 -o sim design.v tb.v && vvp sim

Expected output: only `PASS` lines. Any `FAIL` line means a mismatch.

## Tools

- Icarus Verilog 12 (`iverilog`, `vvp`)
- WaveTrace extension for VS Code (waveform viewing from `dump.vcd`)