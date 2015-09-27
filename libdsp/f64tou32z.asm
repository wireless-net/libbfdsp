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
** into a 32-bit unsigned integer, using round-to-zero.
** unsigned __float64_to_unsigned_int32_round_to_zero(long double);
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___fixunsdfsi;
.file_attr FuncName      = ___fixunsdfsi;

#endif

.text;
.align 2;
___fixunsdfsi:
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
	// portion of the number. Even 0.5x won't have any effect,
	// since we're rounding to zero.

	CC = R2 < 0;
	IF CC JUMP .too_small;

	// If the exponent is larger than 30, then we're shifting
	// the significant bit into the sign bit, so they don't
	// work either.

	R3 = 31 (Z);
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

	CC = R2 <= 0;
	IF CC JUMP .right_shift;

	// We're left-shifting, so want some bits from R0;
	R3 += 12;		// Now 32;
	R3 = R2 - R3;		// M = N - 32, gives -(bits to save)
	R3 = LSHIFT R0 BY R3.L;
	R1 <<= R2;
	R0 <<= R2;
	R0 = R1 | R3;
	RTS;

.right_shift:
	// N < 1, so we're shifting right by -N spaces,
	// pushing bits from R1 back into R0. We're also
	// pushing bits off the end of R0, and we ignore
	// these, since we're rounding to zero. In fact,
	// since we're building a result in R1 at the moment,
	// we ignore anything that gets pushed into R0 too.

	// if N==0, we are just copting R1 to R0.

	R0 = LSHIFT R1 BY R2.L;	// Shift R1 right
	RTS;

.inf_or_nan:
	// It's an Inf or a NaN. If it's an Inf, then R0 will be 0,
	// as will the rest of the mantissa in R1. R2 contains the
	// high-half, left-shifted to remove the sign. R3 contains
	// a similarly-shifted exponent for Inf.

	R2 = R2 | R0;
	CC = R3 < R2;
	IF CC JUMP .is_nan;

	CC = BITTST(R0, 31);	// Check for sign of input
	IF CC JUMP .neg_inf;	// if negative, return negative inf

	// It's an Inf, so return 0xffffffff. Or it's too big to
	// fit into an Int.

.ret_inf:
.too_big:
	R0 = -1;
	RTS;

.neg_inf:
.ret_zero:
.too_small:
.is_nan:
	// We just return zero. Not a lot we can do.
	R0 = 0;
	RTS;

.size ___fixunsdfsi, .-___fixunsdfsi

.global ___fixunsdfsi;
.type ___fixunsdfsi, STT_FUNC;

