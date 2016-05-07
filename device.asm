;==============================================================================
;     _    _   _ ____    _____          _   _       _ ____   __  ____
;    / \  | \ | / ___|  |  ___|__  _ __| |_| |__   ( )___ \ / /_| ___|
;   / _ \ |  \| \___ \  | |_ / _ \| '__| __| '_ \  |/  __) | '_ \___ \
;  / ___ \| |\  |___) | |  _| (_) | |  | |_| | | |    / __/| (_) |__) |
; /_/   \_\_| \_|____/  |_|  \___/|_|   \__|_| |_|   |_____|\___/____/
;
; Device Specific Words for the W65C265SXB
;------------------------------------------------------------------------------
; Copyright (C)2015-2016 HandCoded Software Ltd.
; All rights reserved.
;
; This work is made available under the terms of the Creative Commons
; Attribution-NonCommercial-ShareAlike 4.0 International license. Open the
; following URL to see the details.
;
; http://creativecommons.org/licenses/by-nc-sa/4.0/
;
;==============================================================================
; Notes:
;
;------------------------------------------------------------------------------

		include	"w65c265.inc"

; (TITLE) - ( -- )
;

;               HEADER  7,"(TITLE)",NORMAL
DO_TITLE:       jsr     DO_COLON
                dw      DO_S_QUOTE
                db      28,"W65C265SXB ANS-Forth [16.05]"
                dw      EXIT

; BYE ( -- )
;
; Return control to the host operating system, if any.

                HEADER  3,"BYE",NORMAL
BYE:
                sei			; Restore control to the Mensch Monitor
                cld
                emulate
		lda	#1<<7		; Ename the WDC ROM
		trb	BCR
                jmp     ($fffc)         ; Reset the processor

; UNUSED ( -- u )
;
; u is the amount of space remaining in the region addressed by HERE , in
; address units.

                HEADER  6,"UNUSED",NORMAL
UNUSED:         jsr     DO_COLON
                dw      DO_LITERAL,$8000
                dw      HERE
                dw      MINUS
                dw      EXIT

;-------------------------------------------------------------------------------
