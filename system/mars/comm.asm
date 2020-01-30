; ====================================================================
; ----------------------------------------------------------------
; MARS ONLY
; ----------------------------------------------------------------
		
; --------------------------------------------------------
; MdMars_SendData
; 
; Transfer data from 68k to SH2 using DREQ
;
; Input:
; a0 - Input data
; d0 | LONG - Output address (SH2 map)
; d1 | WORD - Size
;
; Uses:
; d4-d5,a4-a6
; --------------------------------------------------------

; TODO: broken

MdMars_SendData:
		lea	(sysmars_reg),a6
		move.w	#0,dreqctl(a6)
		move.w	d1,d4
		lsr.w	#1,d4
		move.w	d4,dreqlen(a6)
		move.w	#%100,dreqctl(a6)
		move.l	d0,d4
		move.w	d4,dreqdest+2(a6)
		swap	d4
		move.w	d4,dreqdest(a6)

		move.w	2(a6),d4		; CMD Interrupt
		bset	#0,d4
		move.w	d4,2(a6)
		movea.l	a0,a4
		lea	dreqfifo(a6),a5
		move.w	d1,d5
		lsr.w	#3,d5
		sub.w	#1,d5
.sendfifo:
		move.w	(a4)+,(a5)
		move.w	(a4)+,(a5)
		move.w	(a4)+,(a5)
		move.w	(a4)+,(a5)
.full:
		move.w	dreqctl(a6),d4
		btst	#7,d4
		bne.s	.full
		dbra	d5,.sendfifo
		rts

; --------------------------------------------------------
