# 0x01 8-bit Counter

This is another simple app for ATtiny85/ATtiny45 microcontroller using AVR assembly, so I can learn it by doing simple projects.
It's a refecence to build upon for future projects. 

It uses the same features as [0x00 LED Blink](https://github.com/adamszymanowski/MakerProjects/blob/main/ATtiny/0x00-LED-Blink/in-MicrochipStudio-for-ATtiny45/0x00-for-ATtiny45/Documentation.md)
but it builds upon that and uses a bit more complex code.

What it does: counts from 0 to 255, but the output is represented in binary format using 8 LEDS,
that representation is handled by 74HC595 Shift Register.

## App Overview
In order to make 74HC595 Shift Register work you need to send it data in serial form (using 3 pins),
and it will output it on 8 pins. I'm using technique called **bit banging** to achieve this.
### Bit banging
Bit bang timing diagram
```
bit        0       1     2      3      4      5      6      7
Clock :____/--\_  /- \_  /- \_  /- \_  /- \_  /- \_  /- \_  /- \_
Data  :___/----\_/    \_/    \_/    \_/    \_/    \_/    \_/    \_       
Latch :___________________________________________________________/- \_                                  
```

- `Data` goes **high** before `clock` and goes **low** after
- `Clock` goes **high** then **low** (pulses in data)
- `Latch` goes **high** then **low** at the end (the sent serial data now outputs in parallel in shift register)
 

 ## Electronic parts
- 1 x ATtiny85-20PU
- 1 x 74HC595 Shift Register
- 8 x LED, yellow (Vf = 1.84 V)
- 8 x 330 Ohm resistor

## Hardware
PIC kit 4 programmer/debugger, 
5V power supply

also breadboard and cables

# Documentation
[ATtiny25/V / ATtiny45/V / ATtiny85/V](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-2586-AVR-8-bit-Microcontroller-ATtiny25-ATtiny45-ATtiny85_Datasheet.pdf#G1.1182750)

[AVR Instruction Set Manual](http://ww1.microchip.com/downloads/en/devicedoc/atmel-0856-avr-instruction-set-manual.pdf)

[PICkit4](https://ww1.microchip.com/downloads/en/DeviceDoc/50002751F.pdf)
look for 11.3.2 Pinouts for Interfaces

- [How to use 74hc595](https://lastminuteengineers.com/74hc595-shift-register-arduino-tutorial/)