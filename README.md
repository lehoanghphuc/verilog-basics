# Verilog Basics

Small RTL design exercises in Verilog/SystemVerilog, each with a
self-checking testbench. Simulated with Icarus Verilog.

## Projects

| Folder | Description |
|---|---|
| `counter/` | 4-bit counter with synchronous reset and enable. Wraps from 15 to 0. |
| `fsm_traffic/` | 3-state traffic light FSM (RED -> GREEN -> YELLOW) with synchronous reset and enable. |
| `fifo/` | 8-entry, 8-bit synchronous FIFO with directed and 500-cycle seeded-random scoreboard tests. |

Each testbench prints `PASS` or `FAIL` for every check, so no waveform
inspection is needed to see whether the design is correct.

## Run

Run every project's testbench from the repository root:

    python3 run_tests.py

Or run one project's testbench manually:

    cd counter        # or fsm_traffic
    iverilog -g2012 -o sim design.v tb.v && vvp sim

The test runner uses temporary directories for simulation outputs and exits
with a nonzero status if compilation fails or a testbench reports `FAIL`.

## Tools

- Icarus Verilog 12 (`iverilog`, `vvp`)
- WaveTrace extension for VS Code (waveform viewing from `dump.vcd`)