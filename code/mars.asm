; ====================================================================		
; ----------------------------------------------------------------
; MARS SH2 CPU(s)
; 
; DO NOT REMOVE THE FREE RUN TIMER ADJUSTMENTS
; ----------------------------------------------------------------

		phase CS3
		cpu SH7600

; ====================================================================
; ----------------------------------------------------------------
; MARS SH2 constants
; ----------------------------------------------------------------

; ====================================================================		
; ----------------------------------------------------------------
; MASTER SH2 CPU
; ----------------------------------------------------------------

		align 4
SH2_Master:
		dc.l SH2_M_Entry,CS3|$40000	; Cold PC,SP
		dc.l SH2_M_Entry,CS3|$40000	; Manual PC,SP

		dc.l SH2_Error			; Illegal instruction
		dc.l 0				; reserved
		dc.l SH2_Error			; Invalid slot instruction
		dc.l $20100400			; reserved
		dc.l $20100420			; reserved
		dc.l SH2_Error			; CPU address error
		dc.l SH2_Error			; DMA address error
		dc.l SH2_Error			; NMI vector
		dc.l SH2_Error			; User break vector

		dc.l 0,0,0,0,0,0,0,0,0,0	; reserved
		dc.l 0,0,0,0,0,0,0,0,0

		dc.l SH2_Error,SH2_Error	; Trap vectors
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error		
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error		
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error		
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error

 		dc.l master_irq			; Level 1 IRQ
		dc.l master_irq			; Level 2 & 3 IRQ's
		dc.l master_irq			; Level 4 & 5 IRQ's
		dc.l master_irq			; PWM interupt
		dc.l master_irq			; Command interupt
		dc.l master_irq			; H Blank interupt
		dc.l master_irq			; V Blank interupt
		dc.l master_irq			; Reset Button

; ====================================================================
; ----------------------------------------------------------------
; SLAVE SH2 CPU
; ----------------------------------------------------------------

		align 4
SH2_Slave:
		dc.l SH2_S_Entry,CS3|$3F000	; Cold PC,SP
		dc.l SH2_S_Entry,CS3|$3F000	; Manual PC,SP

		dc.l SH2_Error			; Illegal instruction
		dc.l 0				; reserved
		dc.l SH2_Error			; Invalid slot instruction
		dc.l $20100400			; reserved
		dc.l $20100420			; reserved
		dc.l SH2_Error			; CPU address error
		dc.l SH2_Error			; DMA address error
		dc.l SH2_Error			; NMI vector
		dc.l SH2_Error			; User break vector

		dc.l 0,0,0,0,0,0,0,0,0,0	; reserved
		dc.l 0,0,0,0,0,0,0,0,0

		dc.l SH2_Error,SH2_Error	; Trap vectors
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error		
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error		
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error		
		dc.l SH2_Error,SH2_Error
		dc.l SH2_Error,SH2_Error

 		dc.l slave_irq			; Level 1 IRQ
		dc.l slave_irq			; Level 2 & 3 IRQ's
		dc.l slave_irq			; Level 4 & 5 IRQ's
		dc.l slave_irq			; PWM interupt
		dc.l slave_irq			; Command interupt
		dc.l slave_irq			; H Blank interupt
		dc.l slave_irq			; V Blank interupt
		dc.l slave_irq			; Reset Button

; ====================================================================
; ----------------------------------------------------------------
; irq
; 
; r0-r1 are safe
; ----------------------------------------------------------------

		align 4
master_irq:
		mov.l	r0,@-r15
		mov.l	r1,@-r15
		sts.l	pr,@-r15
	
		stc	sr,r0
		shlr2	r0
		and	#$3C,r0
		mov	#int_m_list,r1
		add	r1,r0
		mov	@r0,r1
		jsr	@r1
		nop
		
		lds.l	@r15+,pr
		mov.l	@r15+,r1
		mov.l	@r15+,r0
		rte
		nop
		align 4
		ltorg

; ------------------------------------------------
; irq list
; ------------------------------------------------

		align 4
int_m_list:
		dc.l m_irq_bad,m_irq_bad
		dc.l m_irq_bad,m_irq_bad
		dc.l m_irq_bad,m_irq_bad
		dc.l m_irq_pwm,m_irq_pwm
		dc.l m_irq_cmd,m_irq_cmd
		dc.l m_irq_h,m_irq_h
		dc.l m_irq_v,m_irq_v
		dc.l m_irq_vres,m_irq_vres

; =================================================================
; ------------------------------------------------
; Unused
; ------------------------------------------------

m_irq_bad:
		rts
		nop
		align 4
		ltorg
		
; =================================================================
; ------------------------------------------------
; Master | PWM Interrupt
; ------------------------------------------------

m_irq_pwm:
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(pwmintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(pwmintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required
	
; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(pwmintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop
		
; ----------------------------------

  		mov.w	@(monowidth,gbr),r0
  		shlr8	r0
 		tst	#$80,r0
 		bf	.exit
		mov	r2,@-r15
		mov	r3,@-r15
		mov	r4,@-r15
		mov	r5,@-r15
		mov	r6,@-r15
		mov	r7,@-r15
		sts	pr,@-r15
		bsr	MarsSound_PWM
		nop
		lds	@r15+,pr
		mov	@r15+,r7
		mov	@r15+,r6
		mov	@r15+,r5
		mov	@r15+,r4
		mov	@r15+,r3
		mov	@r15+,r2
.exit:
		nop

; ----------------------------------

		rts
		nop
		align 4
		ltorg

; =================================================================
; ------------------------------------------------
; Master | CMD Interrupt
; ------------------------------------------------

m_irq_cmd:
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(cmdintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(cmdintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required
		
; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(cmdintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop
		
; ----------------------------------

; 		mov	r2,@-r15
; 		mov	r3,@-r15
; 
; 		mov	#_DMASOURCE0,r1
; 		stc	gbr,r0
; 		add	#dreqfifo,r0
; 		mov	r0,@r1			; Source
; 		add 	#4,r1
; 
; 		mov 	#$FFFF,r3
; 		mov.w	@(dreqdest,gbr),r0
; 		and	r3,r0
; 		shll16	r0
; 		mov	r0,r2
; 		mov.w	@(dreqdest+2,gbr),r0
; 		and 	r3,r0
; 		or	r2,r0
; 		mov 	#CS3,r2
; 		or	r2,r0
; 		mov	r0,r3
; 
; 		mov	r0,@r1			; Destination
; 		add	#4,r1
; 		mov.w	@(dreqlen,gbr),r0
; 		extu.w	r0,r0
; 		mov	r0,@r1			; Length
; 		add	#4,r1
; 		mov	#%0100010011100001,r0
; 		mov	r0,@r1			; Control register
; 		mov	#_DMAOPERATION,r1
; 		mov	#%0001,r0
; 		mov	r0,@r1			; DMA Start
; 		mov	#_DMACHANNEL0,r1
; cpuw_01:
; 		mov	@r1,r0
; 		tst	#%10,r0
; 		bt	cpuw_01
; 		mov	#_DMAOPERATION,r1
; 		mov	#0,r0
; 		mov	r0,@r1			; DMA off
; 
; 		mov	@r15+,r3
; 		mov	@r15+,r2
		rts
		nop
		align 4
		ltorg
		
; =================================================================
; ------------------------------------------------
; Master | HBlank
; ------------------------------------------------

m_irq_h:
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(hintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(hintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required
		
; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(hintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop
		
; ----------------------------------

		rts
		nop
		align 4
		ltorg
		
; =================================================================
; ------------------------------------------------
; Master | VBlank
; ------------------------------------------------

m_irq_v:
		mov	#$F0,r0
		ldc	r0,sr
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(vintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(vintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required

; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(vintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop
		
; ----------------------------------

		mov 	#_vdpreg,r1
.min_r		mov.w	@(10,r1),r0		; Wait for FEN to clear
		and	#%10,r0
		cmp/eq	#2,r0
		bt	.min_r
		mov	r2,@-r15		; Send palette from ROM to Super VDP
		mov	r3,@-r15
		mov	r4,@-r15
		mov	r5,@-r15
		mov	r6,@-r15
		mov.l	#_vdpreg,r1		; Wait for palette access ok
.wait		mov.b	@(vdpsts,r1),r0
		tst	#$20,r0
		bt	.wait
		mov	#MARSVid_Palette,r1	; Send palette from cache
		mov	#_palette,r2
 		mov	#256,r3
		mov	#%0101011011110001,r4	; transfer size 2 / burst
		mov	#_DMASOURCE0,r5 	; _DMASOURCE = $ffffff80
		mov	#_DMAOPERATION,r6 	; _DMAOPERATION = $ffffffb0
		mov	r1,@r5			; set source address
		mov	r2,@(4,r5)		; set destination address
		mov	r3,@(8,r5)		; set length
		xor	r0,r0
		mov	r0,@r6			; Stop OPERATION
		xor	r0,r0
		mov	r0,@($C,r5)		; clear TE bit
		mov	r4,@($C,r5)		; load mode
		add	#1,r0
		mov	r0,@r6			; Start OPERATION
; 
; 	; Grab inputs from MD (using COMM12 and COMM14)
; 	; using MD's VBlank
; 		mov	#$FFFF,r2
; 		mov	#MarsSys_Input,r3
; 		mov.w 	@(comm14,gbr),r0
; 		and	r2,r0
; 		mov 	r0,r4
; 		mov.w 	@(comm12,gbr),r0
; 		and	r2,r0
; 		mov	@r3,r1
; 		xor	r0,r1
; 		mov	r0,@r3
; 		and	r0,r1
; 		mov	r1,@(4,r3)
; 		add 	#8,r3
; 		mov 	r4,r0
; 		mov	@r3,r1
; 		xor	r0,r1
; 		mov	r0,@r3
; 		and	r0,r1
; 		mov	r1,@(4,r3)
; 
		mov	@r15+,r6
		mov	@r15+,r5
		mov	@r15+,r4
		mov	@r15+,r3
		mov	@r15+,r2
		mov 	#0,r0
		mov	#MarsVid_VIntBit,r1
		mov 	r0,@r1
		mov.w	@(comm8,gbr),r0
		add 	#1,r0
		mov.w	r0,@(comm8,gbr)
		rts
		nop
		align 4
		ltorg
		
; =================================================================
; ------------------------------------------------
; Master | VRES Interrupt
; ------------------------------------------------

m_irq_vres:
		mov.l	#_sysreg,r0
		ldc	r0,gbr
		mov.w	r0,@(vresintclr,gbr)	; V interrupt clear
		mov.b	@(dreqctl,gbr),r0
		tst	#1,r0
		bf	.mars_reset
.md_reset:
		mov.l	#"68UP",r1		; wait for the 68k to show up
		mov.l	@(comm12,gbr),r0
		cmp/eq	r0,r1
		bf	.md_reset
.sh_wait:
		mov.l	#"S_OK",r1		; wait for the slave to show up
		mov.l	@(comm4,gbr),r0
		cmp/eq	r0,r1
		bf	.sh_wait

; 		mov	#$220003D4,r1		; TODO: creo que ya no necesito esto
; 		mov	@r1,r2
; 		mov	@(4,r1),r3
; 		mov	@(8,r1),r4
; 		mov	#$22000000,r1
; 		add	r1,r2
; 		mov	#$26000000,r1
; 		add	r1,r3
; 		shlr2	r4
; 		add	#-1,r4
; .recopy_rom:
; 		mov.l	@r2+,r0
; 		mov.l	r0,@r3
; 		add	#4,r3
; 		dt	r4
; 		bf	.recopy_rom

		mov	#"M_OK",r0		; let the others know master ready
		mov	r0,@(comm0,gbr)
		mov	#CS3|$40000-8,r15
		mov	#SH2_M_HotStart,r0
		mov	r0,@r15
		mov.w	#$F0,r0
		mov	r0,@(4,r15)
		mov	#_DMAOPERATION,r1
		mov	#0,r0
		mov	r0,@r1			; DMA off
		mov	#_DMACHANNEL0,r1
		mov	#0,r0
		mov	r0,@r1
		mov	#%0100010011100000,r1
		mov	r0,@r1			; Channel control
		rte
		nop
.mars_reset:
		mov.l	#_FRT,r1
		mov.b	@(_TOCR,r1),r0
		or	#$01,r0
		mov.b	r0,@(_TOCR,r1)
.vresloop:
		bra	.vresloop
		nop
		align 4
		ltorg

; ====================================================================
; ----------------------------------------------------------------
; irq
; 
; r0-r1 are safe
; ----------------------------------------------------------------

		align 4
slave_irq:
		mov.l	r0,@-r15
		mov.l	r1,@-r15
		sts.l	pr,@-r15
	
		stc	sr,r0
		shlr2	r0
		and	#$3C,r0
		mov	#int_s_list,r1
		add	r1,r0
		mov	@r0,r1
		jsr	@r1
		nop
		
		lds.l	@r15+,pr
		mov.l	@r15+,r1
		mov.l	@r15+,r0
		rte
		nop
		
; ------------------------------------------------
; irq list
; ------------------------------------------------

		align 4
int_s_list:
		dc.l s_irq_bad,s_irq_bad
		dc.l s_irq_bad,s_irq_bad
		dc.l s_irq_bad,s_irq_bad
		dc.l s_irq_pwm,s_irq_pwm
		dc.l s_irq_cmd,s_irq_cmd
		dc.l s_irq_h,s_irq_h
		dc.l s_irq_v,s_irq_v
		dc.l s_irq_vres,s_irq_vres

; =================================================================
; ------------------------------------------------
; Unused
; ------------------------------------------------

s_irq_bad:
		rts
		nop
		align 4
		ltorg
		
; =================================================================
; ------------------------------------------------
; Slave | PWM Interrupt
; ------------------------------------------------

s_irq_pwm:
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(pwmintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(pwmintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required
		
; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(pwmintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop
		
; ----------------------------------

		rts
		nop
		align 4
		ltorg

; =================================================================
; ------------------------------------------------
; Slave | CMD Interrupt
; ------------------------------------------------

s_irq_cmd:
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(cmdintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(cmdintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required
		
; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(cmdintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop
		
; ----------------------------------

		nop
		rts
		nop
		align 4
		ltorg

; =================================================================
; ------------------------------------------------
; Slave | HBlank
; ------------------------------------------------

s_irq_h:
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(hintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(hintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required
		
; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(hintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop
		
; ----------------------------------

		rts
		nop
		align 4
		ltorg

; =================================================================
; ------------------------------------------------
; Slave | VBlank
; ------------------------------------------------

s_irq_v:
		mov	#$02,r0			; toggle FRT bit for future IRQs
		mov.w	r0,@(vintclr,gbr)	; interrupt clear
		mov	#_FRT,r1
		mov.b	r0,@(_TOCR,r1)		; as required
		mov.w	@(vintclr,gbr),r0	; interrupt clear
		mov.b	@(_TOCR,r1),r0		; as required
		
; 		mov	#$F0,r0
; 		ldc	r0,sr
; 		mov.l	#_FRT,r1
; 		mov.b	@(_TOCR,r1),r0
; 		xor	#$02,r0
; 		mov.b	r0,@(_TOCR,r1)
; 		mov.w	r0,@(vintclr,gbr)
; 		nop
; 		nop
; 		nop
; 		nop

; ----------------------------------
		
		rts
		nop
		align 4
		ltorg

; =================================================================
; ------------------------------------------------
; Slave | VRES Interrupt
; ------------------------------------------------

s_irq_vres:
		mov.l	#_sysreg,r0
		ldc	r0,gbr
		mov.w	r0,@(vresintclr,gbr)	; V interrupt clear
		mov.b	@(dreqctl,gbr),r0
		tst	#1,r0
		bf	.mars_reset
.md_reset:
		mov.l	#"68UP",r1		; wait for the 68k to show up
		mov.l	@(comm12,gbr),r0
		cmp/eq	r0,r1
		bf	.md_reset
		mov	#"S_OK",r0		; tell the others slave is ready
		mov	r0,@(comm4,gbr)
.sh_wait:
		mov.l	#"M_OK",r1		; wait for the slave to show up
		mov.l	@(comm0,gbr),r0
		cmp/eq	r0,r1
		bf	.sh_wait

		mov	#CS3|$3F000-8,r15
		mov	#SH2_S_HotStart,r0
		mov	r0,@r15
		mov.w	#$F0,r0
		mov	r0,@(4,r15)
		mov	#_DMAOPERATION,r1
		mov	#0,r0
		mov	r0,@r1			; DMA off
		mov	#_DMACHANNEL0,r1
		mov	#0,r0
		mov	r0,@r1
		mov	#%0100010011100000,r1
		mov	r0,@r1			; Channel control
		rte
		nop
.mars_reset:
		mov.l	#_FRT,r1
		mov.b	@(_TOCR,r1),r0
		or	#$01,r0
		mov.b	r0,@(_TOCR,r1)
.vresloop:
		bra	.vresloop
		nop
		align 4
		ltorg

; ====================================================================
; ----------------------------------------------------------------
; Error trap
; ----------------------------------------------------------------

SH2_Error:
		nop
		bra	SH2_Error
		nop
		align 4
		ltorg

; ====================================================================
; ----------------------------------------------------------------
; MARS System features
; ----------------------------------------------------------------

		include "system/mars/video.asm"
		include "system/mars/sound.asm"
		align 4

; ====================================================================
; ----------------------------------------------------------------
; Master entry
; ----------------------------------------------------------------

SH2_M_Entry:
		mov	#CS3|$40000,r15
		mov	#_sysreg,r14
		ldc	r14,gbr
		mov.w	r0,@(vintclr,gbr)
		mov.w	r0,@(vintclr,gbr)
		mov.w	r0,@(hintclr,gbr)	;clear IRQ ACK regs
		mov.w	r0,@(hintclr,gbr)
		mov.w	r0,@(cmdintclr,gbr)
		mov.w	r0,@(cmdintclr,gbr)
		mov.w	r0,@(pwmintclr,gbr)
		mov.w	r0,@(pwmintclr,gbr)
		mov.l	#_FRT,r1		; Set Free Run Timer
		mov	#$00,r0
		mov.b	r0,@(_TIER,r1)		;
		mov	#$E2,r0
		mov.b	r0,@(_TOCR,r1)		;
		mov	#$00,r0
		mov.b	r0,@(_OCR_H,r1)		;
		mov	#$01,r0
		mov.b	r0,@(_OCR_L,r1)		;
		mov	#0,r0
		mov.b	r0,@(_TCR,r1)		;
		mov	#1,r0
		mov.b	r0,@(_TCSR,r1)		;
		mov	#$00,r0
		mov.b	r0,@(_FRC_L,r1)		;
		mov.b	r0,@(_FRC_H,r1)		;
		mov	#$F2,r0			; reset setup
		mov.b	r0,@(_TOCR,r1)		;
		mov	#$00,r0
		mov.b	r0,@(_OCR_H,r1)		;
		mov	#$01,r0
		mov.b	r0,@(_OCR_L,r1)		;
		mov	#$e2,r0
		mov.b	r0,@(_TOCR,r1)		;
		
; ---------------------------------------------
; Wait for MD and Slave SH2
; ---------------------------------------------

.wait_md:
		mov.l	@(comm0,gbr),r0
		cmp/eq	#0,r0
		bf	.wait_md
		mov.l	#"SLAV",r1
.wait_slave:
		mov.l	@(comm8,gbr),r0			; wait for the slave to finish booting
		cmp/eq	r1,r0
		bf	.wait_slave
		mov	#0,r0				; clear SLAV
		mov.l	r0,@(comm8,gbr)

; ********************************************************
; Your MASTER code starts here
; ********************************************************

SH2_M_HotStart:
		mov	#CS3|$40000,r15
		mov	#_sysreg,r14
		ldc	r14,gbr
	
		mov	#$F0,r0				; Interrupts OFF
		ldc	r0,sr
		mov	#_CCR,r1			; Set this cache mode
		mov	#$19,r0
		mov.w	r0,@r1
		mov	#PWMIRQ_ON|VIRQ_ON|CMDIRQ_ON,r0	; IRQ enable bits
    		mov.b	r0,@(intmask,gbr)

; ------------------------------------------------

		bsr	MarsVideo_Init			; Init video
		nop
		bsr	MarsSound_Init			; Init sound
		nop
; 		mov 	#CACHE_DATA,r1		
; 		mov 	#$C0000000,r2
; 		mov 	#(CACHE_END-CACHE_START)/4,r3
; .copy:
; 		mov 	@r1+,r0
; 		mov 	r0,@r2
; 		add 	#4,r2
; 		dt	r3
; 		bf	.copy

		mov	#0,r0
		mov.w	r0,@(comm8,gbr)
		
; ------------------------------------------------

		mov	#$20,r0			; Interrupts ON
		ldc	r0,sr
		
; --------------------------------------------------------
; Loop
; --------------------------------------------------------

master_loop:
		mov.w	@(comm0,gbr),r0
		add 	#1,r0
		mov.w	r0,@(comm0,gbr)
		bra	master_loop
		nop
		align 4
		ltorg

; ====================================================================
; ----------------------------------------------------------------
; Slave entry
; ----------------------------------------------------------------

SH2_S_Entry:
		mov	#_sysreg,r14
		ldc	r14,gbr
		mov.l	#_FRT,r1		; Set Free Run Timer
		mov	#$00,r0
		mov.b	r0,@(_TIER,r1)		;
		mov	#$E2,r0
		mov.b	r0,@(_TOCR,r1)		;
		mov	#$00,r0
		mov.b	r0,@(_OCR_H,r1)	;
		mov	#$01,r0
		mov.b	r0,@(_OCR_L,r1)		;
		mov	#0,r0
		mov.b	r0,@(_TCR,r1)		;
		mov	#1,r0
		mov.b	r0,@(_TCSR,r1)		;
		mov	#$00,r0
		mov.b	r0,@(_FRC_L,r1)		;
		mov.b	r0,@(_FRC_H,r1)		;
    		
; --------------------------------------------------------
; Wait for MD, report to Master SH2
; --------------------------------------------------------

.wait_md:
		mov.l	@(comm0,gbr),r0
		cmp/eq	#0,r0
		bf	.wait_md
		mov.l	#"SLAV",r0
		mov.l	r0,@(comm8,gbr)

; ********************************************************
; Your SLAVE code starts here
; ********************************************************

SH2_S_HotStart:
		mov.l	#CS3|$3F000,r15
		mov.l	#_sysreg,r14
		ldc	r14,gbr			; GBR = addr of sys regs
		mov	#$F0,r0			; Interrupts OFF
		ldc	r0,sr
		mov	#_CCR,r1		; Set this cache mode
		mov	#$19,r0
		mov.w	r0,@r1
		mov	#CMDIRQ_ON,r0		; IRQ enable bits
    		mov.b	r0,@(intmask,gbr)	; clear IRQ ACK regs
		mov.w	r0,@(pwmintclr,gbr)
		mov.w	r0,@(pwmintclr,gbr)
		mov.w	r0,@(vintclr,gbr)
		mov.w	r0,@(vintclr,gbr)
		mov.w	r0,@(hintclr,gbr)
		mov.w	r0,@(hintclr,gbr)
		mov.w	r0,@(cmdintclr,gbr)
		mov.w	r0,@(cmdintclr,gbr)

; ------------------------------------------------

		mov	#$20,r0			; Interrupts ON
		ldc	r0,sr

; --------------------------------------------------------
; Loop
; --------------------------------------------------------

slave_loop:
		mov.w	@(comm2,gbr),r0
		add 	#1,r0
		mov.w	r0,@(comm2,gbr)
		
		bra	slave_loop
		nop
		align 4
		ltorg

; ====================================================================
; ----------------------------------------------------------------
; MARS DATA
; ----------------------------------------------------------------

sin_table	binclude "system/mars/data/sinedata.bin"	; sinetable for 3D stuff
		align 4

		include "data/mars_sdram.asm"

; ====================================================================
; ----------------------------------------------------------------
; MARS SH2 RAM
; ----------------------------------------------------------------

SH2_RAM:
		struct SH2_RAM|TH
	if MOMPASS=1
MARSRAM_System	ds.l 0
MARSRAM_Video	ds.l 0
MARSRAM_Sound	ds.l 0
sizeof_marsram	ds.l 0
	else
MARSRAM_System	ds.b (sizeof_marssys-MARSRAM_System)
MARSRAM_Video	ds.b (sizeof_marsvid-MARSRAM_Video)
MARSRAM_Sound	ds.b (sizeof_marssnd-MARSRAM_Sound)
sizeof_marsram	ds.l 0
	endif

.here:
	if MOMPASS=7
		message "MARS RAM from \{((SH2_RAM)&$FFFFFF)} to \{((.here)&$FFFFFF)}"
	endif
		finish
		
; ====================================================================
; ----------------------------------------------------------------
; MARS System RAM
; ----------------------------------------------------------------

		struct MARSRAM_System
MarsSys_Input	ds.l 4
MARSSys_MdReq	ds.l 1
sizeof_marssys	ds.l 0
		finish
		
; ====================================================================
; ----------------------------------------------------------------
; MARS Sound RAM
; ----------------------------------------------------------------

		struct MARSRAM_Sound
MARSSnd_Pwm	ds.b sizeof_sndchn*8
sizeof_marssnd	ds.l 0
		finish

; ====================================================================
; ----------------------------------------------------------------
; MARS Video RAM
; ----------------------------------------------------------------

		struct MARSRAM_Video
MARSVid_LastFb	ds.l 1
MarsVid_VIntBit	ds.l 1
MARSMdl_FaceCnt	ds.l 1
MarsMdl_CurrPly	ds.l 2
MarsMdl_CurrZtp	ds.l 1
MarsMdl_CurrZds	ds.l 1
; MARSMdl_OutPnts ds.l 3*MAX_VERTICES			; Output vertices for reading
MarsPly_ZList	ds.l 2*MAX_POLYGONS			; Polygon address | Polygon Z pos
MARSVid_Palette	ds.w 256
MARSMdl_Playfld	ds.b sizeof_plyfld			; Playfield buffer (or camera)
MARSVid_Polygns	ds.b sizeof_polygn*MAX_POLYGONS		; Polygon data
MARSMdl_Objects	ds.b sizeof_mdl*MAX_MODELS
sizeof_marsvid	ds.l 0
		finish
