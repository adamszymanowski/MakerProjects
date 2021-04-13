# LED Blink

This is simple app for ATTIny85/ATtiny45 microcontroller using AVR assembly, so I can learn it by doing simple projects.
It's a refecence to build upon for future projects.

It uses few basic features of this chip: internal timer, timer interrupt handling, IO handling.

What it does: Blinks LED at given cycle (160 ms)

## App Overview
- Blinks LED on Pin B3 (PB3).
- TIMER0 in CTC Mode with clk/8 Prescale (1 timer tick is 8 microseconds [8 us])
- OCR0A is loaded with 250 value  (it takes 250 timer ticks to trigger interrupt each time [250*8 us = 2 ms])
- Timer interrupt 'waits for' timing factor (40), so 40*2 ms = 80 ms, then toggles PB3.
    * on/off cycle is 2*80 ms = 160 ms, debugging in simulator gives slightly off results, but I don't know why

## Electronic parts
- 1 x ATtiny45-20PU
- 1 x LED, blue (Vf = 2.55 V)
- 1 x 330 Ohm resistor

## Hardware
PIC kit 4 programmer/debugger, 
5V power supply

also breadboard and cables

# Documentation
[PICkit4](https://ww1.microchip.com/downloads/en/DeviceDoc/50002751F.pdf)
look for 11.3.2 Pinouts for Interfaces

[ATtiny25/V / ATtiny45/V / ATtiny85/V](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-2586-AVR-8-bit-Microcontroller-ATtiny25-ATtiny45-ATtiny85_Datasheet.pdf#G1.1182750)

[ AVR Instruction Set Manual](http://ww1.microchip.com/downloads/en/devicedoc/atmel-0856-avr-instruction-set-manual.pdf)

## Notes
- before enabling any interrupts stack pointer (SP) must be set
- use pointer to reach lower (32-63) IO registers (sbi,cbi, etc. - can handle only 0-31 ones)
- Writing a logic one to PINxn toggles the value of PORTxn [Toggling the Pin](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-2586-AVR-8-bit-Microcontroller-ATtiny25-ATtiny45-ATtiny85_Datasheet.pdf#G1.1185300)
- use `sleep` next time for interrupt to happen, not just `nop` loop