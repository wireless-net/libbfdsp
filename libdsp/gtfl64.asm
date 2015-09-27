/*
** Copyright (C) 2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** This is the internal function implementing IEEE double-precision
** floating-point greater than comparison. This functions is for compiler
** internal use only. It does not follow the normal C ABI.
**
** int __float64_adi_gt(long double X, long double Y)
**
**   X is received in R1:0.
**   Y is received in R2 and stack.
**   CC contains the result and is 1 if neither input is a NaN and X>Y,
**   or 0 otherwise.
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusABIMandLoopRegs 
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___float64_adi_gt;
.file_attr FuncName      = ___float64_adi_gt;

#endif

.text;
.align 2;

___float64_adi_gt:
	P0 = R4;		// Grab some workspace.

	// NaNs are represented as all-ones exponent, and
	// a non-zero mantissa. If sign is ignored, then
	// an operand is a NaN if its high half is larger
	// than 0x7FF0, or if its high half is equal to
	// 0x7FF0, and its low half is non-zero.

	// Check X first.
	R4 = R1;				// clear the sign
	BITCLR(R4, 31);
	R3 = 0x7FF;
	R3 <<= 20;			// Set up NaN limit.
	CC = R4 <= R3;		// If it's a NaN, return 
	IF !CC JUMP .ret2;	// with CC=0
	CC = R4 < R3;		// If high-half less than the NaN
	R0 += 0;				// limit, or low-half is zero, it's
	CC |= AZ;			// not a NaN.
	IF !CC JUMP .ret2;

	// Check Y next
	P1 = R5;				// Need more space
	R5 = R3;				// NaN limit
	R3 = [SP+12];		// Get other half of Y
	R4 = R3;
	BITCLR(R4,31);		// and clear its sign
	CC = R4 <= R5;		// If it's over the limit
	IF !CC JUMP .ret1;	// it'll do as the return limit
	CC = R4 < R5;		// If its high-half is less than limit
	R2 += 0;				// or low-half is zero, it's not a
	CC |= AZ;			// a NaN.
	IF !CC JUMP .ret1;

	R4 = R1 | R3;		// CC set at this point
	R4 <<= 1;			// Check for -0==+0
	R5 = R0 | R2;
	R4 = R4 | R5;
	CC ^= AZ;			// Return CC=0 if X==Y==+0==-0
	IF !CC JUMP .ret1;	

	// Neither operand is a NaN. Are they both the same?
	CC = R0 == R2;
	R4 = R1 - R3;
	CC &= AZ;
	CC = !CC;
	IF !CC JUMP .ret1;	// X==Y so return CC=0

	// They're both valid numbers, and X != Y, so do
	// a comparison. And we do a signed comparison,
	// because the remaining floating point values
	// are (almost) ordered like a signed integer range.
	CC = R1 < R3;		// Hi X < Hi Y
	R4 = CC;
	CC = R1 == R3;		// Hi X == Hi Y
	R4 = ROT R4 BY 1;
	CC = R0 < R2 (IU);// Lo X < Lo Y
	R4 = ROT R4 BY 1;	// R4 has CC bits in [0..2]
	CC = R4 < 3;		// CC set if 0 or 1 of last two comps true 
	R5 = R1 & R3;		// which means that X>Y
	CC ^= AN;			// but the inverse if both X and Y negative
.ret1:
	R5 = P1;				// Restore preserved regs
.ret2:
	R4 = P0;
	RTS;

.size ___float64_adi_gt, .-___float64_adi_gt
.global ___float64_adi_gt;
.type ___float64_adi_gt, STT_FUNC;
