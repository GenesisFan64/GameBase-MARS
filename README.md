# GameBase-MARS
A Starter code base for making 32X software (games, demos...)
this base is currently for NTSC systems

Please note that current 32X emulators ignore critical parts of the system, these include:

- Free Run Timers: I don't have clue what are these for but if you don't put their respective places, the interrupts will act weird (bad timings)
- FM bit: this bit tells which system can read/write the Super VDP (The framebuffer and 256-color palette)
- RV bit: this flag reverts the ROM map to the original state (from $880000 to $000000), required for doing ROM-to-VDP transfers on the Genesis side
(and more stuff forgot to mention)

Also other things:
- PWM interrupt: If you set a high Hz value (ex. 320000) and do heavy tasks (like rendering a 3D model) it will cause serious slowdown, Emulators ignore the slow timings

So for testing please check on real hardware.

CURRENT ISSUES:
- Reset crashes (Real hardware only)
