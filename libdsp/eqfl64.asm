/*
** Copyright (C) 2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** This is the internal function implementing IEEE double-precision
** floating-point equality comparison. This functions is for compiler
** internal use only. It does not follow the normal C ABI.
**
** int __float64_adi_eq(long double X, long double Y)
** 
**   X is received in R1:0. 
**   Y is received in R2 and on the stack.
**   CC contains the result and is 1 if neither input is a NaN and X==Y,
**   or 0 otherwise.
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";     
.file_attr libFunc = ___float64_adi_eq;
.file_attr FuncName      = ___float64_adi_eq;

#endif

.text;
.align 2;

___float64_adi_eq:
	P1 = R4;		// Grab some workspace.

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
	IF !CC JUMP .ret;	// with CC=0
	CC = R4 < R3;		// If high-half less than the NaN
	R0 += 0;				// limit, or low-half is zero, it's
	CC |= AZ;			// not a NaN.
	IF !CC JUMP .ret;

	R3 = [SP+12];		// Get other half of Y

	// X is not a NaN. Check equality
	CC = R0 == R2;
	R4 = R1 - R3;
	CC &= AZ;
	IF CC JUMP .ret;  // X==Y so return CC=1

	R4 = R0 | R2;		// Check X==Y==+/-0
	CC = R4 == 0;
	R4 = R1 | R3;
	R4 <<= 1;
	CC &= AZ;
.ret:
	R4 = P1;
	RTS;

.size ___float64_adi_eq, .-___float64_adi_eq
.global ___float64_adi_eq;
.type ___float64_adi_eq, STT_FUNC;
