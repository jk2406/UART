

# N-Digit 7-Segment Display with UART Communication (Nexys 4 DDR, SystemVerilog)

This project implements an **N-digit seven-segment display controller** with **UART communication** on the **Nexys 4 DDR FPGA board** using **SystemVerilog**.
It allows characters (`0–9`, `A–Z`) to be received over UART and displayed across 8 seven-segment digits through multiplexing.

Both **Vivado** (for FPGA synthesis/implementation) and **Verilator** (for simulation and verification) have been used in development.

---

## Features

* **UART Transmitter (TX) & Receiver (RX):**

  * Baud rate configurable (default: `57600`)
  * Implements full UART protocol (start bit, 8 data bits, stop bit).
* **8-Digit Seven-Segment Display Driver:**

  * Multiplexed refresh logic with persistence of vision.
  * Character-to-7-segment decoding (supports `0–9` and `A–Z`).
* **Modular & Scalable:**

  * Top module parameterized (`N_DIGITS`, default = 8).
  * Clean separation: UART, display driver, message sender, RX handler, character decoder.
* **Simulation & FPGA Deployment:**

  * Fully tested in **Verilator** testbenches.
  * Runs on **Nexys 4 DDR** board with Vivado flow.

---

##  Project Structure

```
├── NDigitDisplay.sv       # Top module: UART + 7-seg controller
├── uart_tx.sv             # UART transmitter
├── uart_rx.sv             # UART receiver
├── rxlogic_handle.sv      # Stores received characters into display digits
├── send_message.sv        # Simple message sender (predefined char)
├── ssdDisplay.sv          # Package: ASCII → 7-segment patterns
├── tb_uart_tx.sv          # Verilator testbench for uart_tx
├── nexys4ddr.xdc          # Nexys 4 DDR constraints file
```

---

##  Module Descriptions


* `NDigitDisplay` → top-level, integrates UART + 7-seg logic.
* `uart_tx` / `uart_rx` → handles UART comm.
* `rxlogic_handle` → digit shifting of received chars.
* `send_message` → sends predefined char(s) when triggered.
* `ssdDisplay` → ASCII to 7-segment decoder.

---

## FPGA Constraints (Nexys 4 DDR, XDC)

* **Clock:** 100 MHz (pin `E3`).
* **7-Segment Display:** segments and anodes mapped.
* **Reset Button:** `N17` (center pushbutton).
* **UART RX/TX:** `C4 (rx)` and `D4 (tx)`.
* **Send Switch:** `SW[0]` (`J15`) → triggers `send_message` to transmit predefined data via TX.

---

##  Get Started

### Requirements

* **Board:** Nexys 4 DDR FPGA.
* **Clock:** 100 MHz onboard oscillator.
* **Tools:**

  * [Xilinx Vivado](https://www.xilinx.com/products/design-tools/vivado.html) (synthesis & programming).
  * [Verilator](https://www.veripool.org/verilator/) (simulation).
* **Serial terminal** (PuTTY, TeraTerm, minicom, etc.) configured at **57600 baud, 8N1**.

---

## Simulation with Verilator
**NOTE:** Verilator works in linux only
Overall compile
```sh
verilator --binary 8digitSSD.sv ssdFunctions.sv UART_message.sv UART_rx.sv UART_rxLogicHandle.sv UART_tx.sv -top NDigitDisplay 
./obj_dir/VNDigitDisplay
```
For nice looking warning add ```-Wall``` in the end.

## Running on FPGA (Vivado + Nexys 4 DDR)

1. Clone the repo

2. Open **Vivado** → create a new project → add all `.sv` source files + `nexys4ddr.xdc` constraints.

3. Set **NDigitDisplay** as the top module.

4. Run **Synthesis → Implementation → Generate Bitstream**.

5. Connect the **Nexys 4 DDR** board via USB and program it with the generated bitstream.

6. Open a **serial terminal** on your PC(for example PuTTY or arduino IDE serial monitor):

   * Port: COMx (USB-UART port of Nexys 4 DDR)
   * Baud: `57600`
   * Data bits: `8`
   * Parity: `None`
   * Stop bits: `1`

7. Usage:

   * **Typing characters in the terminal** → Characters appear on the **7-segment display** (shifted across digits).
   * **Flip switch `SW[0]` → Sends predefined message** via UART TX. You will see it on the PC serial terminal.

---

## Future Work

* Extend character mapping (lowercase, punctuation).
* Implement **scrolling text** for messages longer than 8 digits.
* Add **custom message input** from UART instead of fixed send.

---


