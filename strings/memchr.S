/* memchr.S
 * Copyright (C) 2003-2008 Analog Devices Inc., All Rights Reserved.
 *
 * Licensed under any of the following (pick one):
 *  - GPL-2
 *  - LGPL-2.1
 *  - Non-GPL license as part of VisualDSP++
 */

/* @WARNING@ */

@HEADERS@

/* void *memchr(const void *s, int c, size_t n);
 * R0 = address (s)
 * R1 = sought byte (c)
 * R2 = count (n)
 *
 * Returns pointer to located character.
 */

.text

.align 2

#ifdef __LIBC__
.weak _memchr
#endif
ENTRY(_memchr)
	P0 = R0;		/* P0 = address */
	P2 = R2;		/* P2 = count */
	R1 = R1.B(Z);
	CC = R2 == 0;
	IF CC JUMP .Lfailed;

.Lbytes:
	LSETUP (.Lbyte_loop_s, .Lbyte_loop_e) LC0=P2;

.Lbyte_loop_s:
	R3 = B[P0++](Z);
	CC = R3 == R1;
	IF CC JUMP .Lfound;
.Lbyte_loop_e:
	NOP;

.Lfailed:
	R0=0;
	RTS;

.Lfound:
	R0 = P0;
	R0 += -1;
	RTS;

ENDPROC(_memchr)

#ifdef __LIBC__
libc_hidden_def (memchr)
#endif
