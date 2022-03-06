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

CIAA_TBLO	= $dc06
CIAA_TBHI	= $dc07
CIAA_ICR	= $dc0d
CIAA_CRB	= $dc0f
TMR_LOAD	= $411a ;60Hz
BPCOMP		= $d03b
KERNAL_GETIN= $f13e

Task			lda #<TMR_LOAD
				sta CIAA_TBLO
				lda #>TMR_LOAD
				sta CIAA_TBHI
				lda #%10010001
				sta CIAA_CRB
				lda #%10000010
				sta CIAA_ICR
				
				lda #<m_finish
				sta $997e
				lda #>m_finish
				sta $997f
				ldx #$0a 
				jsr $9000
				ldx #$00
				stx m_finish
				lda #9
				sta song_num
				cli

task_loop		cpz s_timer
				bne chk_key
				lda s_timer
				adc #10
				taz
				jsr rand_pallet

chk_key			jsr KERNAL_GETIN
				cmp #48		;0
				blt +
				cmp #58		;9
				blt tail_len
				cmp #133	;f1
				beq f1
				cmp #134	;f3
				beq set_rnd_pal
+				cmp #32		;Space
				bne chk_song
				lda #$00
				sta m_finish

chk_song		lda m_finish
				bne task_loop
				sei
				ldx song_num
				cpx #9
				bne +
				ldx #$00
+				inx
				stx song_num
				stx m_finish
				cpx #01
				bne +
				ldx #$91
+				jsr $9000

				cli
				jmp	task_loop

tail_len		sec
				sbc #47
				asl a 
				asl a 
				asl a
				sta tail_length
				jmp chk_song

f1 				lda #$00
				bra +
set_rnd_pal		ldz s_timer
				lda #$10
+				sta BPCOMP
				jmp task_loop

rand_pallet		ldx CIAA_TBLO
				ldy #1
				;Red
-				lda lines.point_table,x
				sta $d110,y
				inx
				;Green
				lda lines.point_table,x
				sta $d210,y
				inx
				;Blue
				lda lines.point_table,x
				sta $d310,y
				inx
				inx
				inx
				inx
				inx
				inx
				iny
				cpy #16
				bne -				
				rts

TimerInt		dec timer
				bne +
				lda #60
				sta timer
				inc s_timer;
+				ldx #$30
				jsr $9000
				jmp $ea7b
				

m_finish	.byte 0
song_num	.byte 91		
timer 	 	.byte 1
s_timer    	.byte 0


