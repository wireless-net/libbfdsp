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
** Convert an IEEE double-precision floating point 64-bit number
** into a 64-bit unsigned integer, using round-to-zero.
** unsigned long long __float64_to_unsigned_int64_round_to_zero(long double);
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName       = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc       = ___fixunsdfdi;
.file_attr FuncName      = ___fixunsdfdi;

#endif


.text;
.align 2;
___fixunsdfdi:
	// Check for zero.

	R2 = R1 << 1;
	R3 = R2 | R0;
	CC = R3 == 0;
	IF CC JUMP .ret_zero;

	// Check for other exceptional values.

	R3 = 0x7ff (Z);
	R3 <<= 21;
	CC = R3 <= R2 (IU);
	IF CC JUMP .inf_or_nan;

	// Remaining numbers are sensible, but might be too
	// large or too small to represent in an unsigned long long.

	R2 >>= 21;		// This is the biased exponent
	R3 = 1023(Z);
	R2 = R2 - R3;		// Unbiased

	// If the exponent is negative, then there's no integer
	// portion of the number. If the value is 0.5x, then we'd
	// round to zero, giving us zero anyway.

	CC = R2 < 0;
	IF CC JUMP .too_small;

	// If the exponent is larger than 62, then we're shifting
	// the significant bit into the sign bit, so they don't
	// work either.

	R3 = 63 (Z);
	CC = R3 < R2;
	IF CC JUMP .too_big;

	R1 <<= 12;		// Clear the sign and exponent.
	R1 >>= 12;

	BITSET(R1,20);		// Restore the hidden bit.

	// The exponent considers the Hidden bit to be at position
	// zero, in that shifting left from position zero by the exponent
	// will give the value desired. But the hidden bit is at
	// position 52 in the whole dp value, so we want to shift
	// right to get the Hidden bit into the right place.

	// If we're supposed to left-shift less than 52 spaces, then
	// we actually need to right-shift, which will involve
	// rounding.

	R3 += -11;		// Now 52
	CC = R2 < R3;
	IF CC JUMP .right_shift;

	// If we're supposed to left-shift 52 spaces, then we're already
	// at the place we need to be, and can skip ahead to the sign
	// correction.

	CC = R2 == R3;
	IF CC JUMP .return_val;

	// Otherwise, we need to left-shift more than 52 spaces, which
	// means we still need to shift a few spaces.

	// 52 < R2 <= 63
	R2 = R2 - R3;		// how many spaces we actually need
				// to shift
	// 0 < R2 <= 31
	R3 += -20;		// Now 32;
	R3 = R2 - R3;		// saving bits
	R3 = LSHIFT R0 BY R3.L;	// the bits that move across
	R1 <<= R2;
	R0 <<= R2;
	R1 = R1 | R3;
	RTS;

.right_shift:
	// We're supposed to shift left by less than 52 spaces,
	// which translates to a right-shift of 52-N spaces.
	// This means we'll move bits from R1 to R0, and off the
	// end of R0. Because we are rounding to zero, this means
	// we just discard the bits that fall off the end of R0.
	// 0 <= R2 < 52
	R2 = R3 - R2;		// Amount we want to right-shift
	// 0 < R2 <= 52
	R3 += -20;		// Now 32
	// -20 < R2 <= 31
	R3 = R3 - R2;		// for getting the transferred bits
	R3 = LSHIFT R1 BY R3.L;	// the bits we'll move

#if defined(__WORKAROUND_SHIFT) & defined(__ADSPLPBLACKFIN__)
#error Not expecting __WORKAROUND_SHIFT to be defined for non 535 cores
#endif
#if defined(__WORKAROUND_SHIFT) & !defined(__ADSPLPBLACKFIN__)
	// LSHIFT uses 7 bits of the operand on BF535 cores so 52 is in range
	R2 = -R2;
	R1 = LSHIFT R1 BY R2.L;
	R0 = LSHIFT R0 BY R2.L;
#else
	R1 >>= R2;		// Shift bits
	R0 >>= R2;
#endif
	R0 = R3 | R0;		// And combine with moved bits
	RTS;

.inf_or_nan:
	// It's an Inf or a NaN. If it's an Inf, then R0 will be 0,
	// as will the rest of the mantissa in R1. R2 contains the
	// high-half, left-shifted to remove the sign. R3 contains
	// a similarly-shifted exponent for Inf.

	R2 = R2 | R0;
	CC = R3 < R2;
	IF CC JUMP .is_nan;

	// It's an Inf, either +Inf or -Inf. For +Inf, we
	// return 0xffffffff. For -Inf, we return 0x0.
	// and we already know that R0==0, from the input.

.ret_inf:
	CC = R1 < 0;
	R2 = ~R0;
	R1 = R0;
	IF !CC R0 = R2;
	IF !CC R1 = R2;
	RTS;

.too_small:
.is_nan:
	// We just return zero. Not a lot we can do.
	R0 = 0;
.ret_zero:	// if we jump here r0==0
	R1 = R0;
.return_val: // return value in r0 and r1
	RTS;

.too_big:
	// Can't fit a number this large into an int, so return
	// maximum positive or negative, depending on sign.
	R0 = 0;
	JUMP .ret_inf;

.size ___fixunsdfdi, .-___fixunsdfdi

.global ___fixunsdfdi;
.type ___fixunsdfdi, STT_FUNC;
