\ ==============================================================================
\ W65C265 Device Definitions
\ ------------------------------------------------------------------------------

HEX

DF00 CONSTANT PD0       \ Port 0 Data Register
DF01 CONSTANT PD1       \ Port 1 Data Register
DF02 CONSTANT PD2       \ Port 2 Data Register
DF03 CONSTANT PD3       \ Port 3 Data Register
DF04 CONSTANT PDD0      \ Port 0 Data Direction Register
DF05 CONSTANT PDD1      \ Port 1 Data Direction Register
DF06 CONSTANT PDD2      \ Port 2 Data Direction Register
DF07 CONSTANT PDD3      \ Port 3 Data Direction Register

DF20 CONSTANT PD4       \ Port 4 Data Register
DF21 CONSTANT PD5       \ Port 5 Data Register
DF22 CONSTANT PD6       \ Port 6 Data Register
DF23 CONSTANT PD7       \ Port 7 Data Register
DF24 CONSTANT PDD4      \ Port 4 Data Direction Register
DF25 CONSTANT PDD5      \ Port 5 Data Direction Register
DF26 CONSTANT PDD6      \ Port 6 Data Direction Register
DF27 CONSTANT PCS7      \ Port 7 Chip Select

\ 00DF28-3F --- Reserved uninitialized

DF40 CONSTANT BCR       \ Bus Control Register
DF41 CONSTANT SSCR      \ System Speed Control Register
DF42 CONSTANT TCR       \ Timer Control Register
DF43 CONSTANT TER       \ Timer Enable Register
DF44 CONSTANT TIFR      \ Timer Interrupt Flag Register
DF45 CONSTANT EIFR      \ Edge Interrupt Flag Register
DF46 CONSTANT TIER      \ Timer Interrupt Enable Register
DF47 CONSTANT EIER      \ Edge Interrupt Enable Register
DF48 CONSTANT UIFR      \ UART Interrupt Flag Register
DF49 CONSTANT UIER      \ UART Interrupt Enable Register

DF50 CONSTANT T0LL      \ Timer 0 Latch Low
DF51 CONSTANT T0LH      \ Timer 0 Latch High
DF52 CONSTANT T1LL      \ Timer 1 Latch Low
DF53 CONSTANT T1LH      \ Timer 1 Latch High
DF54 CONSTANT T2LL      \ Timer 2 Latch Low
DF55 CONSTANT T2LH      \ Timer 2 Latch High
DF56 CONSTANT T3LL      \ Timer 3 Latch Low
DF57 CONSTANT T3LH      \ Timer 3 Latch High
DF58 CONSTANT T4LL      \ Timer 4 Latch Low
DF59 CONSTANT T4LH      \ Timer 4 Latch High
DF5A CONSTANT T5LL      \ Timer 5 Latch Low
DF5B CONSTANT T5LH      \ Timer 5 Latch High
DF5C CONSTANT T6LL      \ Timer 6 Latch Low
DF5D CONSTANT T6LH      \ Timer 6 Latch High
DF5E CONSTANT T7LL      \ Timer 7 Latch Low
DF5F CONSTANT T7LH      \ Timer 7 Latch High
DF60 CONSTANT T0CL      \ Timer 0 Counter Low
DF61 CONSTANT T0CH      \ Timer 0 Counter High
DF62 CONSTANT T1CL      \ Timer 1 Counter Low
DF63 CONSTANT T1CH      \ Timer 1 Counter High
DF64 CONSTANT T2CL      \ Timer 2 Counter Low
DF65 CONSTANT T2CH      \ Timer 2 Counter High
DF66 CONSTANT T3CL      \ Timer 3 Counter Low
DF67 CONSTANT T3CH      \ Timer 3 Counter High
DF68 CONSTANT T4CL      \ Timer 4 Counter Low
DF69 CONSTANT T4CH      \ Timer 4 Counter High
DF6A CONSTANT T5CL      \ Timer 5 Counter Low
DF6B CONSTANT T5CH      \ Timer 5 Counter High
DF6C CONSTANT T6CL      \ Timer 6 Counter Low
DF6D CONSTANT T6CH      \ Timer 6 Counter High
DF6E CONSTANT T7CL      \ Timer 7 Counter Low
DF6F CONSTANT T7CH      \ Timer 7 Counter High

\ 00DFC0-FF CS1 COProcessor Expansion uninitialized

DF70 CONSTANT ACSR0     \ UART 0 Control/Status Register
DF71 CONSTANT ARTD0     \ UART 0 Data Register
DF72 CONSTANT ACSR1     \ UART 1 Control/Status Register
DF73 CONSTANT ARTD1     \ UART 1 Data Register
DF74 CONSTANT ACSR2     \ UART 2 Control/Status Register
DF75 CONSTANT ARTD2     \ UART 2 Data Register
DF76 CONSTANT ACSR3     \ UART 3 Control/Status Register
DF77 CONSTANT ARTD3     \ UART 3 Data Register
DF78 CONSTANT PIBFR     \ Parallel Interface Flag Register
DF79 CONSTANT PIBER     \ Parallel Interface Enable Register
DF7A CONSTANT PIR2      \ Parallel Interface Register 2
DF7B CONSTANT PIR3      \ Parallel Interface Register 3
DF7C CONSTANT PIR4      \ Parallel Interface Register 4
DF7D CONSTANT PIR5      \ Parallel Interface Register 5
DF7E CONSTANT PIR6      \ Parallel Interface Register 6
DF7F CONSTANT PIR7      \ Parallel Interface Register 7
