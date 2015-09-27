/*
** Convert an IEEE double-precision floating point 64-bit number
** into a 64-bit signed integer, using round-to-zero.
** long long __float64_to_int64_round_to_zero(long double);
**
** Copyright (C) 2003 Analog Devices, Inc.
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
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusABIMandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___fixdfdi;
.file_attr FuncName      = ___fixdfdi;

#endif

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRY AC
#else
#define CARRY AC0
#endif

.text;
.align 2;
___fixdfdi:
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
	// large or too small to represent in an integer.

	R2 >>= 21;		// This is the biased exponent
	R3 = 1023 (Z);
	R2 = R2 - R3;		// Unbiased

	// If the exponent is negative, then there's no integer
	// portion of the number. If the value is 0.5x, then we'd
	// round to zero, giving us zero anyway.

	CC = R2 < 0;
	IF CC JUMP .too_small;

	// If the exponent is larger than 62, then we're shifting
	// the significant bit into the sign bit, so they don't
	// work either.

	R3 = 62 (Z);
	CC = R3 < R2;
	IF CC JUMP .too_big;

	P0 = R1;		// Save the sign, for later.

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

	R3 += -10;		// Now 52
	CC = R2 < R3;
	IF CC JUMP .right_shift;

	// If we're supposed to left-shift 52 spaces, then we're already
	// at the place we need to be, and can skip ahead to the sign
	// correction.

	CC = R2 == R3;
	IF CC JUMP .sign_correction;

	// Otherwise, we need to left-shift more than 52 spaces, which
	// means we still need to shift a few spaces.

	R2 = R2 - R3;		// how many spaces we actually need
				// to shift
	R3 += -20;		// Now 32;
	R3 = R2 - R3;		// saving bits
	R3 = LSHIFT R0 BY R3.L;	// the bits that move across
	R1 <<= R2;
	R0 <<= R2;
	R1 = R1 | R3;
.sign_correction:
	P1 = R7;		// save for workspace
	R2 = -R0;		// Compute a negative
	CC = CARRY;		// version of the result
	CC = !CC;
	R7 = CC;
	R3 = -R1;
	R3 = R3 - R7;
	R7 = P1;		// (restore value)
	CC = P0 < 0;		// and use negative version
	IF CC R0 = R2;		// if input was negative
	IF CC R1 = R3;
	RTS;

.right_shift:
	// We're supposed to shift left by less than 52 spaces,
	// which translates to a right-shift of 52-N spaces.
	// This means we'll move bits from R1 to R0, and off the
	// end of R0. Because we are rounding to zero, this means
	// we just discard the bits that fall off the end of R0.

	R2 = R3 - R2;		// Amount we want to right-shift
	R3 += -20;		// Now 32
	CC = R3 <= R2;		// If we're shifting 32..51 spaces,
	IF CC JUMP .right_lots;	// then all high bits move to the low half.
	// here 0 <= R2 <= 31
	R3 = R3 - R2;		// for getting the transferred bits
	// here 1 <= R3 <= 32
	// The below shift is ok on non-535 cos a shift by 32 is 'read'
	// as a shift by -32 which gives the same result
	R3 = LSHIFT R1 BY R3.L;	// the bits we'll move
	R1 >>= R2;		// Shift bits
	R0 >>= R2;
	R0 = R3 | R0;		// And combine with moved bits
	JUMP .sign_correction;

.right_lots:
	// We're shifting right by 32..51 spaces, which means we'll
	// lose all of the bits in the bottom half, and all of the
	// top half's bits will move into the bottom half, and then
	// perhaps shift some more.

	R3 = R2 - R3;		// The amount to shift, once in low half.
	R0 = R1;		// Move bits from high to low
	R0 >>= R3;		// and shift
	R1 = 0;			// leaving nothing in high half.
	JUMP .sign_correction;

.inf_or_nan:
	// It's an Inf or a NaN. If it's an Inf, then R0 will be 0,
	// as will the rest of the mantissa in R1. R2 contains the
	// high-half, left-shifted to remove the sign. R3 contains
	// a similarly-shifted exponent for Inf.

	R2 = R2 | R0;
	CC = R3 < R2;
	IF CC JUMP .is_nan;

	// It's an Inf, either +Inf or -Inf. For +Inf, we
	// return 0x7fffffff. For -Inf, we return 0x80000000.
	// and we already know that R0==0, from the input.

.ret_inf:
	CC = R1 < 0;
	R1 = R0;
	BITSET(R1,31);		// Now 0x8000 0000 0000 0000
	R2 = ~R0;
	R3 = ~R1;
	IF !CC R0 = R2;
	IF !CC R1 = R3;
	RTS;

.too_small:
.is_nan:
	// We just return zero. Not a lot we can do.
	R0 = 0;
.ret_zero:
	R1 = R0;
	RTS;

.too_big:
	// Can't fit a number this large into an int, so return
	// maximum positive or negative, depending on sign.
	R0 = 0;
	JUMP .ret_inf;

.size ___fixdfdi, .-___fixdfdi

.global ___fixdfdi;
.type ___fixdfdi, STT_FUNC;
