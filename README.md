# Async RISCV
Verilog model of an asynchronous RISCV CPU

## Points to note
 - All the time circuitry is confined within `control.v`. The backup trigger is also placed in `control.v`.

## To do
 - Use branches for developments
 - [x] Testbench
 	- [ ] Add reset signal
 - [ ] Delay modelling
 - [ ] Control signals
 	- [ ] Control.v + cpu in-outs
 	- [ ] Backup delay-circuit
 	- [ ] Type specific signals
 - [ ] Synthesis

## Contributors
 - [Mukhesh Pugalendhi](https://github.com/mukheshpugal)
