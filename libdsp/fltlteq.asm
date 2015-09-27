/*
** Copyright (C) 2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** This is the internal function implementing IEEE single-precision
** floating-point less than or equal comparison. This functions is
** for compiler internal use only. It does not follow the normal C ABI.
**
** int __float32_adi_lteq(float X, float Y)
**
**   X is received in R0.
**   Y is received in R1.
**   CC contains the result and is 1 if neither input is a NaN and X<=Y,
**   or 0 otherwise.
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___float32_adi_lteq;
.file_attr FuncName      = ___float32_adi_lteq;

#endif

.text;
.align 2;

___float32_adi_lteq:

	// A NaN has an exponent of 255, and a non-zero
	// mantissa. Sign is irrelevant. We check whether
	// either input is a NaN by getting rid of the
	// sign bit, and then comparing against 0xFF000000
	// if the operand is larger, it's got a 255 exponent
	// and non-zero mantissa, hence it's a NaN.

	R2 = R0 << 1;
	R3 = 0xFF;
	R3 <<= 24;
	CC = R2 <= R3 (IU);
	IF !CC JUMP .ret;
	
	R2 = R1 << 1;
	CC = R2 <= R3 (IU);
	IF !CC JUMP .ret;
	
	R2 = R0 | R1;		// check for equality +0==-0 
	R2 <<= 1;
	CC = AZ;				// No bits other than sign set
	IF CC JUMP .ret;

	// Neither operand is a NaN or 0. Can treat the floats
	// as signed integers (they have a sign bit, tiny
	// exponents are smaller than huge exponents).

	CC = R0 == R1;			// Check equality and save
	AV1 = CC;				// the result for later

	CC = R0 < R1;			// Check X<Y
	R2 = R0 & R1;
	CC ^= AN;				// but if both operands negative
	CC |= AV1;				// result must be toggled
.ret:
	RTS;

.size ___float32_adi_lteq, .-___float32_adi_lteq
.type ___float32_adi_lteq, STT_FUNC;
.global ___float32_adi_lteq;
