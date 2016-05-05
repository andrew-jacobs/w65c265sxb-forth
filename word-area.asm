;===============================================================================
;     _    _   _ ____    _____          _   _       _  ___  _  __
;    / \  | \ | / ___|  |  ___|__  _ __| |_| |__   ( )( _ )/ |/ /_
;   / _ \ |  \| \___ \  | |_ / _ \| '__| __| '_ \  |/ / _ \| | '_ \
;  / ___ \| |\  |___) | |  _| (_) | |  | |_| | | |   | (_) | | (_) |
; /_/   \_\_| \_|____/  |_|  \___/|_|   \__|_| |_|    \___/|_|\___/
;
; A Direct Threaded ANS Forth for the WDC 65C816
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
; This implementation is designed to run in the 65C816's native mode with both
; the accumulator and index registers in 16-bit mode except when the word needs
; 8-bit memory access.
;
; The DP register is used for the Forth data stack is values can be accessed
; using the direct-page addressing modes. The code uses the same offsets as
; would be used with the stack relative instructions (i.e <1, <3, etc.).
;
; The Y register holds the forth instruction pointer leaving X free for general
; use in words. Some words push Y if they need an extra register.
;
; Some of the high-level definitions are based on Bradford J. Rodriguez's
; CamelForth implementations.
;
;-------------------------------------------------------------------------------

                pw      132
                inclist on
                maclist off

                chip    65816
                longi   off
                longa   off

                include "w65c816.inc"

;===============================================================================
;-------------------------------------------------------------------------------
		
 		udata
		
		public NEXT_WORD

NEXT_WORD:	ds	4096;

                end