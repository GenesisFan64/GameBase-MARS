# GameBase-MARS
A Starter code base for making 32X software (games, demos...)
this base is currently for NTSC systems

Please note that current 32X emulators ignore critical parts of the system, these include:

- Free Run Timers: I don't have clue what are these for but if you don't put their respective places, the interrupts will act weird (bad timings)
- FM bit: This bit tells which system side (Genesis or 32X) can read/write to the Super VDP (The framebuffer and 256-color palette), if a CPU with no permission touches the Super VDP, it will freeze the entire system (32X or MD)
- RV bit: this flag reverts the ROM map back to normal temporally, meant as a workaround for the DMA's ROM-to-VDP transfers, if you do any transfer without setting this the DMA will transfer trash data, ALSO: if you store your DMA on ROM, setting this bit will cause the next instruction to be trash since the ROM data moved it's location, all your transfer routines should be stored on RAM instead
(and more stuff forgot to mention)

Also other things:
- PWM interrupt: If you set a high Hz value (ex. 320000) and do heavy tasks (like rendering a 3D model) it will cause serious slowdown, Emulators ignore this

So if possible, please test any changes on hardware.

CURRENT ISSUES:
- Reset crashes (Real hardware only)


For more info check the official hardware manual (32X Hardware Manual.pdf)
