/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU General
** Public License. See the file COPYING for more details.
**
** In addition to the permissions in the GNU General Public License,
** Analog Devices gives you unlimited permission to link the
** compiled version of this file into combinations with other programs,
** and to distribute those combinations without any restriction coming
** from the use of this file.  (The General Public License restrictions
** do apply in other respects; for example, they cover modification of
** the file, and distribution when not linked into a combine
** executable.)
**
** Non-GPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert an IEEE single-precision floating point number
** to an IEEE double-precision floating point number.
**
** long double __float32_to_float64(float)
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
**
** If you change this clobber set rembember to change SOFTFLOAT
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___extendsfdf2;
.file_attr FuncName      = ___extendsfdf2;

#endif

.text;
.align 2;

___extendsfdf2:

	// Check for some unusual numbers first.

	// If all zeroes, apart from sign, then it's a zero value.
	R1 = R0 << 1;
	CC = R1 == 0;
	IF CC JUMP .ret_zero;

	// If exponent is all ones, then either a NaN or +/- Inf.

	R2 = 0xFF (Z);
	R2 <<= 24;
	CC = R2 <= R1 (IU);
	IF CC JUMP .nan_or_inf;

	// Remaining numbers are "ordinary" (although not necessarily
	// "normal")

	// Extract the sign

	R3 = R0 >> 31;
	R3 <<= 31;

	// Extract the exponent

	R2 = R0 << 1;
	R2 >>= 24;

	// The sp exponent is biased, with 127.
	// The dp exponent needs to be biased with 1023,
	// so add another 896.

	R1 = 896 (Z);
	R2 = R2 + R1;
	R2 <<= 20;		// Move into position in high half
	R3 = R3 | R2;		// and combine with sign bit.

	// Of the 23 bits of mantissa, most will be in the high half.
	// The least significant 3 bits will be in the low half.

	R1 = R0 << 9;		// chop off sign and exp
	R1 >>= 12;		// slide back down, taking it 3 spaces more.
	R0 <<= 29;		// and leave those 3 bits at MSB of low half.
	R1 = R1 | R3;		// Combine with exponent and sign.
	RTS;

.ret_zero:
	R1 = R0;		// Put the sign bit at MSB of top half
	R0 <<= 1;		// and make bottom half zero.
	RTS;

.nan_or_inf:
	// Inf is exponent all ones, mantissa all zeros.
	// NaN is exponent all ones, mantissa non-zero.
	// So for both cases, we need to extend the exponent from being
	// 8 1-bits to being 11 1-bits, and we're extending towards the
	// LSB.
	// At this point, R1 contains R0, left-shifted one space to
	// remove the sign.

	R1 >>= 4;	// shift that FF back 1, and then down 3 more
	R1 = R1 | R0;	// which will give us total of 11 exponent bits.

	// We now shift all of the sign and exponent bits out of R0,
	// leaving it with just the mantissa bits. These will be zero
	// for +/- Inf, and non-zero for NaN. We can't rely on R1's
	// part of the mantissa having any non-zero bits, because they
	// might have been overwritten when we extended the exponent.
	// This means we're still returning NaN, but it'll be a different
	// NaN, and not just zero-filled into the lower-precision bits.

	R0 <<= 9;
	RTS;

.size ___extendsfdf2, .-___extendsfdf2

.global ___extendsfdf2;
.type ___extendsfdf2, STT_FUNC;
