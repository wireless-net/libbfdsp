/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert an IEEE double-precision floating point 64-bit number
** into a 32-bit signed integer, using round-to-nearest.
** int __float64_to_int32(long double);
**
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___float64_to_int32;
.file_attr FuncName      = ___float64_to_int32;

#endif

.text;
.align 2;
___float64_to_int32:
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

	// If the exponent is larger than 30, then we're shifting
	// the significant bit into the sign bit, so they don't
	// work either.

	R3 = 30 (Z);
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
	// However, since we've already done a boundary check, and we
	// know that we'll be moving the hidden bit into R0 somewhere,
	// it's actually easier to consider that we're building the
	// result into R1, where the hidden bit already is.
	// So let's pretend that we've already got the hidden bit to
	// position 0 of R1 (32 bits of those 52 taken care of), and
	// in reality, it's at position 20. So R2 is only out by 20:

	R3 = 20 (Z);
	R2 = R2 - R3;		// Amount to shift, within R1. Call it N.

	// If N > 1, then we're left-shifting within R1, getting some bits
	// from R0. If N < 1, then we're right-shifting within R1, pushing
	// some bits back to R0. If it's 0, we're already done with the
	// shifting.

	CC = R2 < 0;
	IF CC JUMP .right_shift;
	CC = R2 == 0;
	IF CC JUMP .rounding;

	// We're left-shifting, so want some bits from R0;
	R3 += 12;		// Now 32;
	R3 = R2 - R3;		// M = N - 32, gives -(bits to save)
	R3 = LSHIFT R0 BY R3.L;
	R1 <<= R2;
	R0 <<= R2;
	R1 = R1 | R3;

.rounding:
	// Our result is in R1, and our remainder is in R0.
	// The LSB of R1 is the guard bit G. The MSB of R0 is
	// the rounding bit R. The rest of R0 ORed together make
	// up the S bit. We round if R & (S | G).

	R0 = ROT R0 BY 1;
	R2 = CC;		// R bit
	CC = R0;
	R0 = CC;		// S bit
	CC = BITTST(R1,0);
	R3 = CC;		// G bit
	R0 = R0 | R3;		// S | G
	R2 = R2 & R0;		// R & (S | G)
	R0 = R1 + R2;

	// We saved the sign earlier, and now we have to check
	// whether this is really a negative number.

	CC = P0 < 0;		// Check sign
	R1 = -R0;
	IF CC R0 = R1;

.ret_zero:
	RTS;

.right_shift:
	// N < 1, so we're shifting right by -N spaces,
	// pushing bits from R1 back into R0. We're also
	// pushing bits off the end of R0, and we need to
	// note these, as they're part of the S bit for
	// rounding.

	R3 += 12;		// Now 32
	R3 = R2 + R3;		// M = N + 32 (for saving bits)
	P1 = R0;		// Save for a moment
	R3 = LSHIFT R1 BY R3.L;	// Get the bits that move from R1
	R1 = LSHIFT R1 BY R2.L;	// Shift R1 and R0 right
	R0 = LSHIFT R0 BY R2.L;	// and combine the bits that
	R0 = R0 | R3;		// moved across.
	R2 = P1;		// recover old R0, and set S bit
	CC = R2;		// if any of those bits were 1.
	R2 = CC;		// Then incorporate into new R0, to
	R0 = R0 | R2;		// ensure S will still be set.
	JUMP .rounding;

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
	BITSET(R0,31);		// Now 0x80000000
	R2 = ~R0;
	CC = R1 < 0;
	IF !CC R0 = R2;
	RTS;

.too_small:
.is_nan:
	// We just return zero. Not a lot we can do.
	R0 = 0;
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

	// But don't forget the sign.

	CC = R1 < 0;
	R0 = -R0;
	IF CC R0 = R1;
	RTS;

.size ___float64_to_int32, .-___float64_to_int32

.global ___float64_to_int32;
.type ___float64_to_int32, STT_FUNC;
