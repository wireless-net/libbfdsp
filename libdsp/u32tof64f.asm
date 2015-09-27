/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert 32-bit unsigned integer to 64-bit non-IEEE floating point.
**
** This function implements conversions from 32-bit unsigned
** integers, into the special non-IEEE 64-bit floating point
** format. It receives its input in R0, and returns its
** result in R1:0.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___floatunsidf;
.file_attr FuncName      = ___floatunsidf;

#endif

.text;
.align 2;

___floatunsidf:

	// An unsigned 32-bit int has 32 bits of significand.
	// Whereas the high-half of our
	// non-IEEE format has 31 bits of fractional
	// significand, and a sign bit. So we're just moving
	// the decimal point 32 spaces to the left, and thus
	// setting the exponent to be 32. Zero is the exception.

	R1 = R0;
	R0 = 31 (Z);

	// We lose a bit of precision, since we've got only 31
	// bits to contain a 32-bit number. If the high bit's
	// in use, we have to shift right one more space (to
	// ensure a zero sign bit), which can cause us to lose
	// what's in the low bit.

	CC = R1 < 0;
	R2 = CC;
	R1 >>= R2;
	R0 = R0 + R2;

	// Normalise.
	R2.L = SIGNBITS R1;
	R2 = R2.L (X);
	R1 <<= R2;
	R0 = R0 - R2 (S);

	// Check for zero
	CC = R1 == 0;
	IF CC R0 = R1;
	RTS;
.size ___floatunsidf, .-___floatunsidf
.global ___floatunsidf;
.type ___floatunsidf, STT_FUNC;

