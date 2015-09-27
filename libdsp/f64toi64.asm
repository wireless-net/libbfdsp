/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert an IEEE double-precision floating point 64-bit number
** into a 64-bit signed integer, using round-to-nearest.
** long long __float64_to_int64(long double);
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
.file_attr libFunc = ___float64_to_int64;
.file_attr FuncName      = ___float64_to_int64;

#endif

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRY AC
#else
#define CARRY AC0
#endif

.text;
.align 2;
___float64_to_int64:
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
	// portion of the number, but 0.5x might still show up,
	// so we can only ignore exponents of -2 or less.

	CC = R2 < -1;
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

	// We'll treat the case of an exponent of -1 as a special
	// case, so that all exponents are positive.

	CC = R2 == -1;
	IF CC JUMP .round_half;

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
	// end of R0. It also means we need to round the result.


	R2 = R3 - R2;		// Amount we want to right-shift

	R3 += -20;		// Now 32
	P1 = R7;		// make workspace

	R3 = R3 - R2;		// for getting the transferred bits

	// HERE -20 < R3 <= 32.  The below shifts are ok cos on non-535
	// a shift by 32 is seen as a shift by -32 (sign bit set)
	// and therefore we get the corrert result.
	R7 = LSHIFT R0 BY R3.L;	// The bits we'll lose
	R3 = LSHIFT R1 BY R3.L;	// and the bits we'll move

#if defined(__WORKAROUND_SHIFT) & defined(__ADSPLPBLACKFIN__)
#error Not expecting __WORKAROUND_SHIFT to be defined for non 535 cores
#endif
#if defined(__WORKAROUND_SHIFT) & !defined(__ADSPLPBLACKFIN__)
	// LSHIFT uses 7 bits of the operand on BF535 cores
	R2 = -R2;
	R1 = LSHIFT R1 BY R2.L;
	R0 = LSHIFT R0 BY R2.L;
#else
	R1 >>= R2;		// Shift bits
	R0 >>= R2;
#endif
	R0 = R3 | R0;		// And combine with moved bits

	// Our result is in R1:0, and our remainder is in R7.
	// The LSB of R0 is the guard bit G. The MSB of R7 is
	// the rounding bit R. The rest of R7 ORed together make
	// up the S bit. We round if R & (S | G).

	R7 = ROT R7 BY 1;
	R2 = CC;		// R bit
	CC = R7;
	R7 = CC;		// S bit
	CC = BITTST(R0,0);
	R3 = CC;		// G bit
	R7 = R7 | R3;		// S | G
	R2 = R2 & R7;		// R & (S | G)
	R7 = P1;		// restore R7

	// Now add the round bit to the result
	R0 = R0 + R2;
	CC = CARRY;
	R2 = CC;
	R1 = R1 + R2;
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

.round_half:
	// The input is 0.5x, and if x is 0, then we return 0,
	// otherwise we round up to 1. At this point, we've
	// masked off the exponent/sign bits, but haven't restored
	// the hidden bit, so the only bits set are those of
	// the mantissa. If any are set, then we round up.

	R0 = R0 | R1;
	CC = R0;
	R0 = CC;
	R1 = 0;

	// But don't forget the sign.

	P1 = R7;
	R2 = -R0;
	CC = CARRY;
	CC = !CC;
	R7 = CC;
	R3 = -R1;
	R3 = R3 + R7;
	R7 = P1;
	CC = P0 < 0;
	IF CC R0 = R2;
	IF CC R1 = R3;
	RTS;

.size ___float64_to_int64, .-___float64_to_int64

.global ___float64_to_int64;
.type ___float64_to_int64, STT_FUNC;
