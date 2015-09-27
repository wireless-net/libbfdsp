/*
** Float16 add.  Takes two non-IEEE-754 floating point numbers (16.16) and
** adds them.
**
** Copyright (C) 2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName       = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc       = ___addsf3;
.file_attr FuncName      = ___addsf3;

#endif

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRY AC
#else
#define CARRY AC0
#endif

.text;
.align 2;
___addsf3:
	// Compare exponents
	R2.L = R0.L - R1.L (NS);
	R2 = R2.L (X);
	R3 = R0;
	// And if exp X < exp Y, swap args.
	CC = R2 < 0;
	IF CC R0 = R1;
	IF CC R1 = R3;
	R2 = ABS R2;

	// now D >= 0, exp X >= exp Y;
	// Adjust Y's mantissa down, so exponents are equal.
#ifdef __WORKAROUND_SHIFT
	R3 = 0x1f;
	R2 = MIN(R2,R3);
#endif
	R1 >>>= R2;
	R0.H = R0.H + R1.H (NS);
#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
	CC = AV0;
#else
	CC = V;
#endif
	IF CC JUMP overflow;

	// No overflow. Check whether the result needs normalising.
	R2 = R0;
	R2 >>>= 16;
	CC = R2 == 0;
	IF CC R0 = R2;		// If mantissa is zero, make exp zero
	IF CC JUMP finish;	// and skip to end

	// Else normalise
	R1.L = SIGNBITS R2.L;
	R0.L = R0.L - R1.L (NS);
	R0.H = ASHIFT R0.H BY R1.L;

finish:
	RTS;

overflow:
	CC = CARRY;
	R2 = R0.L (X);		// save exp
	R0 = ROT R0 BY -1;	// and rotate bit into mantissa
	R2 += 1;		// increase exponent
	R0.L = R2.L >> 0;	// put changed exponent back
	RTS;
.size ___addsf3, .-___addsf3
.global ___addsf3;
.type ___addsf3, STT_FUNC;
