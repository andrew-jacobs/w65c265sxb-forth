# W65C265SXB ANS Forth

This project builds a Forth environment for a WDC W65C265SXB which can be
accessed via a USB serial connection to the ACIA port. (I use a cheap PL2303
module with jumper wires acquired from ebay).

The code is split into two modules namely:

- The w65c265sxb.asm file is a general purpose system reset and UART
  handler.

- The ans-forth.asm file is implements the forth environment. This file includes
  device.asm to implement hardware specific words.

A number of include files are used to support the code, namely:

- The w65c816.inc file contains useful definitions and macros for the W65C816
  processor.
  
- The w65c265.inc file contains definitions for the hardware built into the
  W65C265 processor.
  
- The w65c265sxb.inc file contains hardware definitions for the WDC W65C265SXB
  development board.

## Current Status

The code in this repository builds a functional Forth environment that can
execute standard commands and compile new words.

```

W65C265SXB ANS-Forth [16.04]

: STAR ( -- ) 42 EMIT ; Ok
: STARS ( n -- ) 0 DO STAR LOOP ; Ok
CR 7 STARS
*******Ok
: SQUARE ( n -- )  DUP 0 DO DUP STARS CR LOOP DROP ; Ok
CR 6 SQUARE CR
******
******
******
******
******
******

Ok
```

I will continue to add documentation, more words and debug.

## Bugs

- The generation of new lines during command entry needs to be improved.

## Forth in ROM

The latest version of the code builds an S28 version that runs from RAM and a S19 version that
is converted into a 32K ROM image that can be loaded into the SXB's flash ROM chip (if installed).

To load the image use the W65C265SXB-Hacker program to disable the WDC ROM, erase the default
flash bank and the XMODEM download the image. The commands are:
```
F 0
E
X 8000
```
The current image still expects a USB serial adapter on UART0. The ROM does not start with the
'WDC' character sequence that would cause it to auto execute so you need to start it with a 'G 00:8004'
command in the Mensch monitor.
