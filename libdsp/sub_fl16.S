/*
** Float16 subtract. Subtracts 2 non-IEEE-754 floats (16.16).
**
** Copyright (C) 2003 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = _sub_fl16;
.file_attr FuncName      = _sub_fl16;

#endif

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRY AC
#else
#define CARRY AC0
#endif

.text;
.align 2;

_sub_fl16:
	// Compare exponents
	R2.L = R0.L - R1.L (NS);
	R2 = R2.L (X);
	CC = R2 < 0;
	IF CC JUMP adjust_x;

	// Adjust y
	R3 = R1;
#ifdef __WORKAROUND_SHIFT
	R1 = 31;
	R1 = MIN(R1,R2);
	R3 >>>= R1;
#else
	R3 >>>= R2;
#endif
	R1.H = R3.H >> 0;
	JUMP adjusted;

adjust_x:

#ifdef __WORKAROUND_SHIFT
	R3 = -32;
	R3 = MAX(R2,R3);
	R3 = ASHIFT R0 BY R3.L;
	R0 = R0 - R2;
#else
	R3 = R0;
	R2 = -R2;
	R3 >>>= R2;
	R0 = R0 + R2;		// inc result exponent (mantissa may change)
#endif
	R0.H = R3.H >> 0;	// but now store adjusted mantissa

adjusted:
	// result will be R0. Either R0's or R1's mantissa has been adjusted
	// down to match exponents. R0's exponent is the required final
	// value.

	R0.H = R0.H - R1.H (NS);

	CC = AV0;
	IF CC JUMP overflow;

	// Check if mantissa is non-zero, for normalising.

	R2 = R0;
	R2 >>>= 16;
	CC = R2 == 0;	// if mantissa is zero, then set exponent
	IF CC R0 = R2;	// to zero, too, and finish.
	IF CC JUMP finish;

	// normalise
	R3.L = SIGNBITS R2.L;
	R0.H = ASHIFT R0.H BY R3.L;
	R0.L = R0.L - R3.L (NS);
finish:
	RTS;

overflow:
	CC = CARRY;
	R2 = R0;
	R2 = ROT R2 BY -1;	// and rotate it in
	R0 += 1;		// increment exponent (may change mantissa)
	R0.H = R2.H >> 0;	// but we overwrite with new mantissa anyway.
	RTS;
.size _sub_fl16, .-_sub_fl16
.global _sub_fl16;
.type _sub_fl16, STT_FUNC;
