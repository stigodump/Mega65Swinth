;******************************************************************
;
; Draw lines one on each of the four bitplanes
;
;	Auther: R Welbourn
;	Discord: Stigodump
;	Date: 05/03/2022
;	Assembler: 64TAS Must be at least build 2625
;	64tass-1.56.2625\64tass.exe -a Build.asm -o Build.prg --tab-size=4
;	Xemu: Tested using Xemu and Nexys4 with ROM 920300
;
;******************************************************************

;Target CPU
	.cpu "4510"

X1 		= Lines.X1
Y1 		= Lines.Y1
X2 		= Lines.X2
Y2 		= Lines.Y2
X1n		= Lines.X1n
Y1n		= Lines.Y1n
X2n 	= Lines.X2n
Y2n 	= Lines.Y2n

ZERO_PAGE			= $61
BASIC_CODE			= $2001
MAIN_CODE 			= $2200

* = ZERO_PAGE
	.dsection zero_page
	.cerror * > $8f, "Too many ZP variables"

* = BASIC_CODE
	.dsection basic_code
	.cerror * > BASIC_CODE + MAIN_CODE - BASIC_CODE, "Not enough space"

* = MAIN_CODE
	.dsection main_code
	.cerror * > $7fff, "Not enough space"

	.section zero_page
temp_pal 	.byte ?
tmr     	.byte ?
tail_length	.byte ?
	.send

	.section basic_code
	.byte $09,$20,$0a,$00,$fe,$02,$30,$00,$13,$20,$14,$00,$9e,$38,$37
	.byte $30,$34,$00,$1e,$20,$19,$00,$22,$0d,$93,$0e,$22,$14,$00,$30,$20
	.byte $1b,$00,$02,$22,$14,$14,$14,$14,$d3,$d7,$c9,$d3,$c8,$22,$14,$00
	.byte $7c,$20,$1e,$00,$05,$22,$14,$14,$14,$14,$20,$d7,$52,$49,$54,$54
	.byte $45,$4e,$20,$42,$59,$3a,$20,$c7,$4c,$45,$4e,$20,$c5,$2e,$20,$c2
	.byte $52,$45,$44,$4f,$4e,$20,$c3,$4f,$4d,$50,$55,$2d,$d3,$45,$52,$56
	.byte $45,$20,$c3,$c2,$cd,$2d,$33,$31,$30,$2d,$c4,$cc,$36,$20,$32,$2d
	.byte $cd,$41,$59,$2d,$31,$39,$38,$35,$22,$14,$11,$00,$95,$20,$1f,$00
	.byte $02,$22,$14,$14,$14,$14,$d3,$d9,$ce,$d4,$c8,$20,$d3,$c1,$cd,$d0
	.byte $cc,$c5,$22,$14,$00,$e2,$20,$28,$00,$05,$22,$14,$14,$14,$14,$20
	.byte $d5,$50,$2d,$4c,$4f,$41,$44,$45,$44,$20,$42,$59,$3a,$20,$ca,$49
	.byte $4d,$20,$d7,$49,$4e,$49,$4e,$47,$53,$20,$c3,$4f,$4d,$50,$55,$2d
	.byte $d3,$45,$52,$56,$45,$20,$c3,$c2,$cd,$2d,$39,$36,$32,$2d,$c4,$cc
	.byte $32,$20,$32,$34,$2d,$ca,$55,$4c,$59,$2d,$31,$39,$38,$34,$22,$14
	.byte $11,$00,$f5,$20,$29,$00,$02,$22,$14,$14,$14,$14,$d3,$d7,$c9,$ce
	.byte $d4,$c8,$22,$14,$00,$22,$21,$32,$00,$05,$22,$14,$14,$14,$14,$20
	.byte $c3,$4f,$4d,$42,$49,$4e,$45,$44,$20,$42,$59,$3a,$20,$c3,$41,$52
	.byte $4c,$20,$c1,$2e,$20,$cd,$45,$41,$48,$4c,$20,$ca,$52,$2e,$22,$14
	.byte $11,$00,$42,$21,$33,$00,$02,$22,$14,$14,$14,$14,$cd,$20,$c5,$20
	.byte $c7,$20,$c1,$20,$36,$20,$35,$20,$20,$d3,$d7,$c9,$ce,$d4,$c8,$22
	.byte $14,$00,$93,$21,$3c,$00,$05,$22,$14,$14,$14,$14,$20,$d7,$52,$49
	.byte $54,$54,$45,$4e,$20,$41,$4e,$44,$20,$43,$4f,$4d,$42,$49,$4e,$45
	.byte $44,$20,$42,$59,$3a,$20,$d2,$20,$d7,$45,$4c,$42,$4f,$55,$52,$4e
	.byte $20,$c4,$49,$53,$43,$4f,$52,$44,$20,$53,$54,$49,$47,$4f,$44,$55
	.byte $4d,$50,$20,$35,$2d,$cd,$41,$52,$43,$48,$2d,$32,$30,$32,$32,$22
	.byte $14,$11,$00,$a8,$21,$3d,$00,$02,$22,$14,$14,$14,$14,$c3,$cf,$ce
	.byte $d4,$d2,$cf,$cc,$d3,$22,$14,$00,$c5,$21,$46,$00,$05,$22,$14,$14
	.byte $14,$14,$20,$30,$2d,$39,$20,$54,$41,$49,$4c,$20,$4c,$45,$4e,$47
	.byte $54,$48,$22,$14,$00,$df,$21,$47,$00,$22,$14,$14,$14,$14,$20,$c6
	.byte $31,$2d,$c6,$33,$20,$43,$4f,$4c,$4f,$55,$52,$53,$22,$14,$00,$fe
	.byte $21,$48,$00,$22,$14,$14,$14,$14,$20,$d3,$50,$41,$43,$45,$20,$43
	.byte $48,$41,$4e,$47,$45,$20,$54,$55,$4e,$45,$22,$14,$11,$00,$00,$00
	.send

	.section main_code
				;Clear MAP and Stack
				cld
				ldy #$01
				tys
				ldx #$ff
				txs
				see
				lda #0
				tab
				ldx #0
				ldy #0
				ldz #0
				map
				eom

				;Map in the C64 Kernal ROM and RESTORE
				sei 	
				lda #%00000000
				sta $d030
				lda #%11111110
				sta $01
				jsr $fd15

				;Update IRQ interrupt vector
				lda #<Int
				sta $0314
				lda #>Int
				sta $0315

				;Set DMAgic to F018B
				lda #%00000001
				tsb $d703

				;Set 3.5Mhz
				lda #%01000000
				trb $d054

				;Set Bitplanes to bank 4 & 5
				lda $d07c
				and #%11111000
				ora #%00000010
				sta $d07c

				;Set raster compare to 251
				lda #%10000000
				trb $d011
				lda #<251
				sta $d012
				
				;Set first thiry two colours in colour pallet
				ldx #0
				ldy #0
				;Red
-				lda colour_table,x
				sta $d100,y
				inx
				;Green
				lda colour_table,x
				sta $d200,y
				inx
				;Blue
				lda colour_table,x
				sta $d300,y
				inx
				iny
				cpy #colour_end-colour_table
				bne -

				;Set two bitplanes to $8000 Bank0 & Bank1
				;Set two bitplanes to $c000 Bank0 & Bank1
				lda #%10001000
				sta $d033
				sta $d034
				lda #%10101010
				sta $d035
				sta $d036
				lda #%00001111
				sta $d032
				lda #%01010000
				sta $d031

				;Clear whole BP1 & BP2 & BP3 & BP4
				;and copy music program to $9000
				lda #0
				sta $d702
				lda #>dma_clrscrn
				sta $d701
				lda #<dma_clrscrn
				sta $d700
				
				;Setup Lines demo test routine
				jsr lines.Initialize
				lda #0
				sta $d020
				sta $d021
				sta $d03b
				lda #2
				sta tmr
				lda #35
				sta tail_length
				
				jmp	music.Task

				;Interrupt entry point
Int				lda $d019
				bmi RasterInt
				jmp music.TimerInt

RasterInt		phz
				dec tmr
				beq +
				lda #2
				cmp tmr
				beq do_line
				bra r_int_exit
+				lda #6
				sta tmr
				jsr set_tail

				;Set linedraw to draw line
do_line			lda #1
				sta lineBpln.SC
				;**************************************
				;draw line 1 to 4
				ldx #0
-				ldy pattern_table,x
				lda (lines.head_pntr),y
				clc 
				adc #lines.X_MAX
				sta lineBpln.X1
				inx
				ldy pattern_table,x
				lda (lines.head_pntr),y
				clc 
				adc #lines.Y_MAX
				sta lineBpln.Y1
				inx
				ldy pattern_table,x
				lda (lines.head_pntr),y
				clc 
				adc #lines.X_MAX
				sta lineBpln.X2
				inx
				ldy pattern_table,x
				lda (lines.head_pntr),y
				clc 
				adc #lines.Y_MAX
				sta lineBpln.Y2
				inx
				lda pattern_table,x
				sta lineBpln.BP
				phx
				jsr lineBpln.Line
				plx 
				inx 
				cpx #20
				bne -

				;Set linedraw to remove line
				lda #0
				sta lineBpln.SC
				;**************************************
				;remove line 1 to 4
				ldx #0
-				ldy pattern_table,x
				lda (lines.tail_pntr),y
				clc 
				adc #lines.X_MAX
				sta lineBpln.X1
				inx
				ldy pattern_table,x
				lda (Lines.tail_pntr),y
				clc 
				adc #lines.Y_MAX
				sta lineBpln.Y1
				inx
				ldy pattern_table,x
				lda (lines.tail_pntr),y
				clc 
				adc #Lines.X_MAX
				sta lineBpln.X2
				inx
				ldy pattern_table,x
				lda (lines.tail_pntr),y
				clc 
				adc #lines.Y_MAX
				sta lineBpln.Y2
				inx
				lda pattern_table,x
				sta lineBpln.BP
				phx
				jsr lineBpln.Line
				plx 
				inx 
				cpx #20
				bne -

				;Calculate next line
				jsr lines.MovePoints

r_int_exit		lda #1
				sta $d019
				plz
				jmp $ea81

				;Set tail length
set_tail		lda Lines.tail_len
				cmp tail_length
				bge +
				jsr lines.TailPlus1
				rts
+				bne +
				rts
+				jsr lines.TailMinus1				
				rts

			;DMA job to clear whole of four bitplanes
dma_clrscrn	.byte %00000111 ;command low byte: FILL+CHAIN
			.word 16383		;2 x 8192 screens
			.word 0000		;source address/fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 4			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

			.byte %00000111	;command low byte: FILL+CHAIN
			.word 16383		;2 x 8192 screens
			.word 0000		;source address/fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 5 		;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo
			;DMA job to copy music program to $9000
			.byte %00000000	;command low byte: COPY
			.word m_end-m_start	;2 x 8192 screens
			.word m_start  		;source address/fill value
			.byte 0			;source Bank
			.word $9000		;destination address
			.byte 0 		;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

colour_table
			.byte $0,$0,$0 ;0	0000 Black
			.byte $f,$0,$0 ;1 	0001 Red
			.byte $0,$c,$0 ;2 	0010 Green
			.byte $1,$5,$a ;3 	0011 Teal
			.byte $0,$0,$f ;4 	0100 Blue
			.byte $0,$c,$f ;5 	0101 Cyan
			.byte $f,$0,$f ;6 	0110 Magenta
			.byte $0,$0,$0 ;7	0111 Black
			.byte $c,$c,$0 ;8 	1000 Yellow
			.byte $8,$8,$8 ;9 	1001 Grey
			.byte $8,$2,$f ;a 	1010 Purple
			.byte $0,$0,$0 ;b	1011 Black
			.byte $d,$7,$0 ;c 	1100 Orange
			.byte $0,$0,$0 ;d	1101 Black
			.byte $0,$0,$0 ;e	1110 Black
			.byte $f,$f,$f ;f	1111 White

			.byte $0,$0,$0 ;0 	0000 Black
colour_end

pattern_table
			.byte X1,Y1,X2,Y2,0
			.byte X1n,Y1,X2n,Y2,1
			.byte X1,Y1n,X2,Y2n,2
			.byte X1n,Y1n,X2n,Y2n,3
pattern_end

music 		.binclude "Music.asm"
lineBpln	.binclude "Line4Bitplane.asm"
lines		.binclude "Lines.asm"
m_start		.binary "music9000.bin"
m_end
			.send