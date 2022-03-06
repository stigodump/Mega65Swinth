;******************************************************************
;
; Generates 256 lines of point data then wraps around
;
;	Auther: R Welbourn
;	File Name:MovePoint.asm
;	Discord: Stigodump
;	Date: 22/01/2022
;	Assembler: 64TAS Must be at least build 2625
;
;******************************************************************
;Constants
CIAA_TBLO	= $dc06

X_MAX	= 127
Y_MAX	= 99
X_MIN	= 129
Y_MIN	= 157

X1 		= 0
Y1 		= 1
X2 		= 2
Y2 		= 3
X1n		= 4
Y1n		= 5
X2n 	= 6
Y2n 	= 7

;Zero Page variables
	.section zero_page
head_pntr	.word ?
last_pntr	.word ?
tail_pntr	.word ?
head_pos	.byte ?
tail_len	.byte ?
step_size	.byte ?
	.send

Initialize		lda #7
				sta step_size
				lda #0
				sta head_pos
				sta tail_len
				
set_pntrs		lda head_pos
				sta head_pntr
				lda #0
				asl head_pntr
				rol a
				asl head_pntr
				rol a
				asl head_pntr
				rol a
				adc #>point_table
				sta head_pntr+1

				lda head_pos
				sec 
				sbc tail_len
				sta tail_pntr
				lda #0
				asl tail_pntr
				rol a 
				asl tail_pntr
				rol a 
				asl tail_pntr
				rol a 
				adc #>point_table
				sta tail_pntr+1
				rts

TailPlus1		lda tail_len
				cmp	#255
				beq +
				inc a
				sta tail_len
+				rts

TailMinus1		lda tail_len
				beq +
				dec head_pos
				dec a
				sta tail_len
				bsr set_pntrs
				lda tail_len
+				rts

MovePoints		lda head_pntr
				sta last_pntr
				lda head_pntr+1
				sta last_pntr+1
				inc head_pos
				bsr set_pntrs

				ldy #3
				;***Change Y values
next_point		lda (last_pntr),y
				clc
				adc inc_table,y 
				sta (head_pntr),y
				bvc +
				bpl y_lt
				lda #Y_MAX
				bra y_gt
+				bpl posy_res
				cmp #Y_MIN
				bcs +

				;Y result less than
y_lt			lda #Y_MIN
				sta (head_pntr),y
				jsr get_rnd_step
				sta inc_table,y 
				bra +

posy_res		lda #Y_MAX
				cmp (head_pntr),y
				bcs +

				;Y result greater than
y_gt			sta (head_pntr),y
				jsr get_rnd_step
				neg a
				sta inc_table,y 

+				dey 
				;***Change X values
				lda (last_pntr),y
				clc
				adc inc_table,y 
				sta (head_pntr),y
				bvc +
				bpl x_lt
				lda #X_MAX
				bra x_gt
+				bpl posx_res
				cmp #X_MIN
				bcs +

				;X result less than
x_lt			lda #X_MIN
				sta (head_pntr),y
				jsr get_rnd_step
				sta inc_table,y 
				bra +

posx_res		lda #X_MAX
				cmp (head_pntr),y
				bcs +

				;X result greater than
x_gt			sta (head_pntr),y
				jsr get_rnd_step
				neg a
				sta inc_table,y 

+				dey
				bpl next_point

				;Set complement values
				ldy #3
				ldz #7
next_neg		lda (head_pntr),y
				neg a 
				sta (head_pntr),z 
				dez
				dey 
				bpl next_neg

				rts

GetRND			lda CIAA_TBLO
				sta r_pntr+1
r_pntr			lda point_table
				rts

get_rnd_step	lda CIAA_TBLO
				and #$0f
				tax
				lda step_table,x
				rts

step_table		.byte	4,2,3,4,5,6,4,3,5,7,2,5,4,3,2,1

inc_table		.byte 	254,2,3,253

				.align	$100
point_table		.byte 	10,10,245,245,245,245,10,10
