;===============================================================================
; __        ____  ____   ____ ____   __  ____ ______  ______
; \ \      / / /_| ___| / ___|___ \ / /_| ___/ ___\ \/ / __ )
;  \ \ /\ / / '_ \___ \| |     __) | '_ \___ \___ \\  /|  _ \
;   \ V  V /| (_) |__) | |___ / __/| (_) |__) |__) /  \| |_) |
;    \_/\_/  \___/____/ \____|_____|\___/____/____/_/\_\____/
;
; Power On Reset and Basic Vector Handling for the W65C265SXB Development Board
;-------------------------------------------------------------------------------
; Copyright (C)2015-2016 HandCoded Software Ltd.
; All rights reserved.
;
; This work is made available under the terms of the Creative Commons
; Attribution-NonCommercial-ShareAlike 4.0 International license. Open the
; following URL to see the details.
;
; http://creativecommons.org/licenses/by-nc-sa/4.0/
;
;===============================================================================
; Notes:
;
;
; This ROM takes control of the UART3 serial connection from the Mensch Monitor
; on startup.
;
;-------------------------------------------------------------------------------

                pw      132
                inclist on

                chip    65816

                include "w65c816.inc"
                include "w65c265.inc"
                include "w65c265sxb.inc"

;===============================================================================
; Configuration
;-------------------------------------------------------------------------------

; The BAUD_RATE constant defines the speed that W65C265 will configure UART3 at
; to communicate with the host PC. The Mensch Monitor works works at 9600 baud
; but if the ROM takes over complete control of the board it could be raised to
; a higher speed.

BAUD_RATE       equ     9600                    ; ACIA baud rate

BRG_VALUE       equ     OSC_FREQ/(16*BAUD_RATE)-1

                if      BRG_VALUE&$ffff0000
                messg   "BRG_VALUE does not fit in 16-bits"
                endif

; The size of the UART RX and  TX buffers. Currently a whole page is used for
; these.

BUFF_SIZE       equ     126

;

TIMER0_HZ       equ     1000
TIMER0_PR       equ     OSC_FREQ/TIMER0_HZ-1

                if      TIMER0_PR&$ffff0000
                messg   "TIMER0_PR does not fit in 16-bits"
                endif

;===============================================================================
;-------------------------------------------------------------------------------

                udata

TX_HEAD         ds      1                       ; Offsets to TX data
TX_TAIL         ds      1
RX_HEAD         ds      1                       ; Offsets to RX data
RX_TAIL         ds      1

TX_DATA         ds      BUFF_SIZE
RX_DATA         ds      BUFF_SIZE

;===============================================================================
; ROM Header
;-------------------------------------------------------------------------------

rom_header      section offset $8000

                db      'AJJ',0
                jmp     RESET

;===============================================================================
; Power On Reset
;-------------------------------------------------------------------------------

                code

                extern  Start
                longi   off
                longa   off
RESET:
                sei                             ; Disable interrupts
                native                          ; Switch to native mode
                long_i
                ldx     #$01ff                  ; Reset the stack
                txs

                lda     #$80                    ; Disable the WDC ROM
                tsb     BCR             
                stz     TER                     ; Disable all interrupts
                stz     TIER
                stz     UIER    
                stz     EIER

                lda     #<TIMER0_PR             ; Initialise Timer 0
                sta     T0CL
                lda     #>TIMER0_PR
                sta     T0CH
                lda     #1<<0                   ; Enable the timer
                tsb     TER

                lda     #1<<7                   ; Set UART3 to use timer 3
                trb     TCR
                lda     #<BRG_VALUE             ; And set baud rate
                sta     T3CL
                lda     #>BRG_VALUE
                sta     T3CH
                lda     #1<<3                   ; Enable timer 3
                tsb     TER

                lda     #%00100101              ; Set UART3 for 8-N-1
                sta     ACSR3
                lda     #1<<6                   ; Enable RX interrupt
                tsb     UIER

                stz     TX_HEAD                 ; Clear buffer offsets
                stz     TX_TAIL
                stz     RX_HEAD
                stz     RX_TAIL

        ; CTS/RTS pins

                cli
                jmp     Start                   ; Jump to the application start

;===============================================================================
; UART Interface
;-------------------------------------------------------------------------------

; Appends the character in A to the transmit buffer. If the buffer is completely
; full then wait until a transmit interrupt has occurred before returning.

                public  UartTx
UartTx:
                pha                             ; Save callers registers
                phx
                phy
                php
                short_ai
                ldx     TX_TAIL                 ; Append new data to buffer
                sta     TX_DATA,x
                inx                             ; Bump and wrap the offset
                cpx     #BUFF_SIZE
                bne     $+4
                ldx     #0

TxLoop:         cpx     TX_HEAD                 ; Is the buffer completely full?
                beq     TxWait
                stx     TX_TAIL                 ; No, update the tail

                lda     #1<<7                   ; Ensure TX interrupts enabled
                tsb     UIER
                plp                             ; Restore callers registers
                ply
                plx
                pla
                rts                             ; Done

TxWait:         wai                             ; Wait for an interrupt
                bra     TxLoop                  ; The check again

; Fetch the next character from the receive buffer waiting for some to arrive
; if the buffer is empty.

                public  UartRx
UartRx:
                phx                             ; Save callers registers
                phy
                php
                short_ai
RxLoop:         ldx     RX_HEAD                 ; Any data in the buffer?
                cpx     RX_TAIL
                beq     RxWait                  ; No, wait for some

                lda     RX_DATA,x               ; Extract a byte
                inx                             ; Bump and wrap offset
                cpx     #BUFF_SIZE
                bne     $+4
                ldx     #0
                stx     RX_HEAD                 ; Update the offset
                plp                             ; Restore callers registers
                ply
                plx
                rts                             ; Done

RxWait:         wai                             ; Wait for an interrupt
                bra     RxLoop

; Check if the receive buffer contains any data and return C=1 if there is
; some.

                public  UartRxTest
UartRxTest:
                pha                             ; Save callers registers
                php
                short_a
                clc                             ; Assume buffer empty
                lda     RX_HEAD                 ; Compare offsets
                eor     RX_TAIL
                beq     $+3                     ; Empty?
                sec                             ; No, set C
                rol     a                       ; Save carry
                plp
                ror     a                       ; Restore carry
                pla                             ; Restore callers A
                rts                             ; Done

;===============================================================================
; UART Interrupt Handlers
;-------------------------------------------------------------------------------

; Handle an RX interrupt for UART3. Append the recieved data to the tail of the
; buffer.

IRQAR3:
                long_ai                         ; Save users registers
                pha
                phx
                phy
                
                short_ai
                lda     #1<<6                   ; Clear the RX interrupt flag
                trb     UIFR
                ldx     RX_TAIL
                lda     ARTD3                   ; Copy recieved byte to buffer
                sta     RX_DATA,X
                inx                             ; Bump and wrap
                cpx     #BUFF_SIZE
                bne     $+4
                ldx     #0
                
                cpx     RX_HEAD                 ; Buffer already full?
                beq     $+5                     ; Yes
                stx     RX_TAIL                 ; Update the tail

                ; RTS/CTS processing

                long_ai                         ; Restore users registers
                ply
                plx
                pla
                rti                             ; Continue

; Handle a TX interrupt for UART3. If the buffer is empty then disable the
; interrupt until more data is added to the TX buffer.

IRQAT3:
                long_ai                         ; Save users registers
                pha
                phx
                phy
                
                short_ai
                ldx     TX_HEAD                 ; Any data to transmit?
                cpx     TX_TAIL
                bne     IRQAT3Send              ; Yes
                lda     #1<<7
                trb     UIER                    ; No, disable interrupt
                bra     IRQAT3Done
                
IRQAT3Send:     lda     TX_DATA,x               ; Transmit the nex character
                sta     ARTD3
                inx                             ; Bump and wrap offset
                cpx     #BUFF_SIZE
                bne     $+4
                ldx     #0
                stx     TX_HEAD                 ; Update the offset
                
IRQAT3Done:     long_ai                         ; Restor users registers
                ply
                plx
                pla
                rti

;===============================================================================
; Vectors
;-------------------------------------------------------------------------------

UnusedVector:   bra     $
BadVector:      bra     $

native_vector   section  offset $ff80

                dw      UnusedVector            ; Timer 0 Interrupt
                dw      UnusedVector            ; Timer 1 Interrupt
                dw      UnusedVector            ; Timer 2 Interrupt
                dw      UnusedVector            ; Timer 3 Interrupt
                dw      UnusedVector            ; Timer 4 Interrupt
                dw      UnusedVector            ; Timer 5 Interrupt
                dw      UnusedVector            ; Timer 6 Interrupt
                dw      UnusedVector            ; Timer 7 Interrupt
                dw      UnusedVector            ; Positive Edge Interrupt on P56
                dw      UnusedVector            ; Negative Edge Interrupt on P57
                dw      UnusedVector            ; Positive Edge Interrupt on P60
                dw      UnusedVector            ; Positive Edge Interrupt on P62
                dw      UnusedVector            ; Negative Edge Interrupt on P64
                dw      UnusedVector            ; Negative Edge Interrupt on P66
                dw      UnusedVector            ; Parallel Interface Bus (PIB) Interrupt
                dw      UnusedVector            ; IRQ Level Interrupt
                dw      UnusedVector            ; UART0 Receiver Interrupt
                dw      UnusedVector            ; UART0 Transmitter Interrupt
                dw      UnusedVector            ; UART1 Receiver Interrupt
                dw      UnusedVector            ; UART1 Transmitter Interrupt
                dw      UnusedVector            ; UART2 Receiver Interrupt
                dw      UnusedVector            ; UART2 Transmitter Interrupt
                dw      IRQAR3                  ; UART3 Receiver Interrupt
                dw      IRQAT3                  ; UART3 Transmitter Interrupt
                dw      BadVector               ; Reserved
                dw      BadVector               ; Reserved
                dw      UnusedVector            ; COP Software Interrupt
                dw      UnusedVector            ; BRK Software Interrupt
                dw      UnusedVector            ; ABORT Interrupt
                dw      UnusedVector            ; Non-Maskable Interrupt
                dw      UnusedVector            ; Reserved
                dw      UnusedVector            ; Reserved

emulate_vectors section offset $ffc0

                dw      UnusedVector            ; Timer 0 Interrupt
                dw      UnusedVector            ; Timer 1 Interrupt
                dw      UnusedVector            ; Timer 2 Interrupt
                dw      UnusedVector            ; Timer 3 Interrupt
                dw      UnusedVector            ; Timer 4 Interrupt
                dw      UnusedVector            ; Timer 5 Interrupt
                dw      UnusedVector            ; Timer 6 Interrupt
                dw      UnusedVector            ; Timer 7 Interrupt
                dw      UnusedVector            ; Positive Edge Interrupt on P56
                dw      UnusedVector            ; Negative Edge Interrupt on P57
                dw      UnusedVector            ; Positive Edge Interrupt on P60
                dw      UnusedVector            ; Positive Edge Interrupt on P62
                dw      UnusedVector            ; Negative Edge Interrupt on P64
                dw      UnusedVector            ; Negative Edge Interrupt on P66
                dw      UnusedVector            ; Parallel Interface Bus (PIB) Interrupt
                dw      UnusedVector            ; IRQ Level Interrupt
                dw      UnusedVector            ; UART0 Receiver Interrupt
                dw      UnusedVector            ; UART0 Transmitter Interrupt
                dw      UnusedVector            ; UART1 Receiver Interrupt
                dw      UnusedVector            ; UART1 Transmitter Interrupt
                dw      UnusedVector            ; UART2 Receiver Interrupt
                dw      UnusedVector            ; UART2 Transmitter Interrupt
                dw      UnusedVector            ; UART3 Receiver Interrupt
                dw      UnusedVector            ; UART3 Transmitter Interrupt
                dw      BadVector               ; Reserved
                dw      BadVector               ; Reserved
                dw      UnusedVector            ; COP Software Interrupt
                dw      BadVector               ; Reserved
                dw      UnusedVector            ; ABORT Interrupt
                dw      UnusedVector            ; Non-Maskable Interrupt
                dw      RESET                   ; Reset
                dw      UnusedVector            ; IRQ/BRK

                end