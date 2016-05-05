#===============================================================================
# WDC Tools Assembler Definitions
#-------------------------------------------------------------------------------

AS			=	wdc816as

LD			=	wdcln

RM			=	erase

AS_FLAGS	=	-g -l

DEBUG		=	wdcdb.exe

#===============================================================================
# Rules
#-------------------------------------------------------------------------------

.asm.obj:
		$(AS) $(AS_FLAGS) $<

#===============================================================================
# Targets
#-------------------------------------------------------------------------------

OBJS	= \
		w65c265sxb.obj \
		w65c265rom.obj \
		ans-forth.obj \
		word-area.obj

all:	ans-forth.s28 rom-forth.s19 rom-forth.bin

clean:
		$(RM) $(OBJS)
		$(RM) *.bin
		$(RM) *.s19
		$(RM) *.s28
		$(RM) *.lst
		$(RM) *.map
		$(RM) *.sym

debug:
		$(DEBUG)

#===============================================================================
# Dependencies
#-------------------------------------------------------------------------------

ans-forth.s28: 		w65c265sxb.obj ans-forth.obj word-area.obj
		$(LD) -g -hm28 -t -C0300 -Zudata=0200,8000 -O $@ w65c265sxb.obj ans-forth.obj word-area.obj

# w65c265rom.obj ans-forth.obj word-area.obj

rom-forth.bin: 		rom-forth.s19
		srec_cat rom-forth.s19 -offset - 0x8000 -o rom-forth.bin -binary

#		$(LD) -g -hb -t -C8000 -U0200 -Zcode=8000,10000 -O $@ w65c265rom.obj ans-forth.obj word-area.obj

rom-forth.s19: 		w65c265rom.obj ans-forth.obj word-area.obj
		$(LD) -g -hm19 -t -C8000 -U0200 -Zcode=8000,10000 -O $@ w65c265rom.obj ans-forth.obj word-area.obj

w65c265sxb.obj: \
		w65c816.inc \
		w65c265.inc \
		w65c265sxb.inc \
		w65c265sxb.asm

w65c265rom.obj: \
		w65c816.inc \
		w65c265.inc \
		w65c265sxb.inc \
		w65c265rom.asm

ans-forth.obj: \
		w65c816.inc \
		ans-forth.asm \
		device.asm

word-area.obj: \
		w65c816.inc \
		word-area.asm
