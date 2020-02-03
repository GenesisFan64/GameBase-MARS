; ====================================================================
; ----------------------------------------------------------------
; SH2 ROM user data
; 
; If your data is too much for SDRAM, place it here.
; Note that this section will be gone if the Genesis side is
; perfoming a DMA ROM-to-VDP Transfer (setting RV=1)
; ----------------------------------------------------------------

Textur_Puyo:	binclude "data/mars/textures/puyo_art.bin"
		align 4
Palette_Puyo:	binclude "data/mars/textures/puyo_pal.bin"
		align 4
Polygn_Puyo:	dc.l 4			; quad (4)
		dc.l Textur_Puyo
		dc.l 600		; texture width
		dc.w 128,  8		; x--1
		dc.w   8,  8		; 2--x
		dc.w   8,128		; 3--x
		dc.w 128,128		; x--4
		dc.w 600,  0
		dc.w   0,  0
		dc.w   0,555
		dc.w 600,555
		align 4
		
Polygn_Solid:	dc.l 4			; quad (4)
		dc.l 36			; Index color
		dc.l 0			; Nothing to add
		dc.w 256,8		; x--1
		dc.w 136,8		; 2--x
		dc.w 136,128		; 3--x
		dc.w 256,128		; x--4
		dc.l 0
		dc.l 0
		dc.l 0
		dc.l 0
		align 4
		
