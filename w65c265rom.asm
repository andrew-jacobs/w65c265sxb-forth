;===============================================================================
; __        ____  ____   ____ ____   __  ____ ______  ______
; \ \      / / /_| ___| / ___|___ \ / /_| ___/ ___\ \/ / __ )
;  \ \ /\ / / '_ \___ \| |     __) | '_ \___ \___ \\  /|  _ \
;   \ V  V /| (_) |__) | |___ / __/| (_) |__) |__) /  \| |_) |
;    \_/\_/  \___/____/ \____|_____|\___/____/____/_/\_\____/
;
; Basic Vector Handling for the W65C265SXB Development Board
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
;-------------------------------------------------------------------------------

                pw      132
                inclist on

                chip    65816

                include "w65c265.inc"
                include "w65c265sxb.inc"

;===============================================================================
; Configuration
;-------------------------------------------------------------------------------

BAUD_RATE       equ     19200                   ; ACIA baud rate

BRG_VALUE       equ     OSC_FREQ/(16*BAUD_RATE)-1

                if      BRG_VALUE&$ffff0000
                messg   "BRG_VALUE does not fit in 16-bits"
                endif
		
;===============================================================================
; ROM Header
;-------------------------------------------------------------------------------

rom_header	section offset $8000
		
		db	'AJJ',0
		jmp	RESET

;===============================================================================
; Power On Reset
;-------------------------------------------------------------------------------

		code
	public RESET
                extern  Start
                longi   off
                longa   off
RESET:
                sei                             ; Disable interrupts
                native                          ; Switch to native mode
                long_i
                ldx     #$01ff                  ; Reset the stack
                txs

                ; Ensure no serial interrupts
                stz     UIER

                lda     #$c0                    ; Ensure A15/AMS are output
                sta     PDD4
                stz     PD4                     ; And select bank 0

                lda     #%00010000              ; Set UART0 to use timer 3
                trb     TCR
                lda     #<BRG_VALUE             ; And set baud rate
                sta     T3CL
                lda     #>BRG_VALUE
                sta     T3CH

                lda     #1<<3                   ; Enable timer 3
                tsb     TER

                lda     #%00100101              ; Set UART0 for 8-N-1
                sta     ACSR0

                jmp     Start                   ; Jump to the application start

;===============================================================================
; ACIA Interface
;-------------------------------------------------------------------------------

; Wait until the last transmission has been completed then send the character
; in A.

                public  UartTx
UartTx:
                pha                             ; Save the character
                php                             ; Save register sizes
                short_a                         ; Make A 8-bits
                pha
                lda     #1<<1
TxWait:         bit     UIFR                    ; Has the timer finished?
                beq     TxWait
                pla
                sta     ARTD0                   ; Transmit the character
                plp                             ; Restore register sizes
                pla                             ; And callers A
                rts                             ; Done

; Fetch the next character from the receive buffer waiting for some to arrive
; if the buffer is empty.

                public  UartRx
UartRx:
                php                             ; Save register sizes
                short_a                         ; Make A 8-bits
                lda     #1<<0
RxWait:         bit     UIFR                    ; Any data in RX buffer?
                beq     RxWait                  ; No
                lda     ARTD0                   ; Yes, read it
                plp                             ; Restore register sizes
                rts                             ; Done

; Check if the receive buffer contains any data and return C=1 if there is
; some.

                public  UartRxTest
UartRxTest:
                pha                             ; Save callers A
                php
                short_a
                lda     UIFR                    ; Read the status register
                plp
                ror     a                       ; Shift UART0R bit into carry
                pla                             ; Restore A
                rts                             ; Done

;===============================================================================
;-------------------------------------------------------------------------------

IRQT0:		bra	$

BadVector:	bra	$

;===============================================================================
; Vectors
;-------------------------------------------------------------------------------

native_vector	section	 offset $ff80
	
		dw	IRQT0			; Timer 0 Interrupt
		dw	IRQT0			; Timer 1 Interrupt
		dw	IRQT0			; Timer 2 Interrupt
		dw	IRQT0			; Timer 3 Interrupt
		dw	IRQT0			; Timer 4 Interrupt
		dw	IRQT0			; Timer 5 Interrupt
		dw	IRQT0			; Timer 6 Interrupt
		dw	IRQT0			; Timer 7 Interrupt
		dw	BadVector		; Positive Edge Interrupt on P56
		dw	BadVector		; Negative Edge Interrupt on P57
		dw	BadVector		; Positive Edge Interrupt on P60
		dw	BadVector		; Positive Edge Interrupt on P62
		dw	BadVector		; Negative Edge Interrupt on P64
		dw	BadVector		; Negative Edge Interrupt on P66
		dw	BadVector		; Parallel Interface Bus (PIB) Interrupt
		dw	BadVector		; IRQ Level Interrupt
		dw	BadVector		; UART0 Receiver Interrupt
		dw	BadVector		; UART0 Transmitter Interrupt
		dw	BadVector		; UART1 Receiver Interrupt
		dw	BadVector		; UART1 Transmitter Interrupt
		dw	BadVector		; UART2 Receiver Interrupt
		dw	BadVector		; UART2 Transmitter Interrupt
		dw	BadVector		; UART3 Receiver Interrupt
		dw	BadVector		; UART3 Transmitter Interrupt
		dw	BadVector		; Reserved
		dw	BadVector		; Reserved
		dw	BadVector		; COP Software Interrupt
		dw	BadVector		; BRK Software Interrupt
		dw	BadVector		; ABORT Interrupt
		dw	BadVector		; Non-Maskable Interrupt
		dw	BadVector		; Reserved
		dw	BadVector		; Reserved

emulate_vectors	section	offset $ffc0

		dw	IRQT0			; Timer 0 Interrupt
		dw	IRQT0			; Timer 1 Interrupt
		dw	IRQT0			; Timer 2 Interrupt
		dw	IRQT0			; Timer 3 Interrupt
		dw	IRQT0			; Timer 4 Interrupt
		dw	IRQT0			; Timer 5 Interrupt
		dw	IRQT0			; Timer 6 Interrupt
		dw	IRQT0			; Timer 7 Interrupt
		dw	BadVector		; Positive Edge Interrupt on P56
		dw	BadVector		; Negative Edge Interrupt on P57
		dw	BadVector		; Positive Edge Interrupt on P60
		dw	BadVector		; Positive Edge Interrupt on P62
		dw	BadVector		; Negative Edge Interrupt on P64
		dw	BadVector		; Negative Edge Interrupt on P66
		dw	BadVector		; Parallel Interface Bus (PIB) Interrupt
		dw	BadVector		; IRQ Level Interrupt
		dw	BadVector		; UART0 Receiver Interrupt
		dw	BadVector		; UART0 Transmitter Interrupt
		dw	BadVector		; UART1 Receiver Interrupt
		dw	BadVector		; UART1 Transmitter Interrupt
		dw	BadVector		; UART2 Receiver Interrupt
		dw	BadVector		; UART2 Transmitter Interrupt
		dw	BadVector		; UART3 Receiver Interrupt
		dw	BadVector		; UART3 Transmitter Interrupt
		dw	BadVector		; Reserved
		dw	BadVector		; Reserved
		dw	BadVector		; COP Software Interrupt
		dw	BadVector		; Reserved
		dw	BadVector		; ABORT Interrupt
		dw	BadVector		; Non-Maskable Interrupt
		dw	RESET    		; Reset
		dw	BadVector		; IRQ/BRK

                end