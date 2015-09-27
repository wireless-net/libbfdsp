/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert 64-bit unsigned integer to 64-bit non-IEEE floating point.
**
** This function implements conversions from 64-bit unsigned
** integers, into the special non-IEEE 64-bit floating point
** format. It receives its input in R1:0, and returns its
** result in R1:0.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName       = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc       = ___floatundidf;
.file_attr FuncName      = ___floatundidf;

#endif

.text;
.align 2;

___floatundidf:

	// An unsigned 64-bit int has 64 bits of significand,
	// Whereas the high-half of our
	// non-IEEE format has 31 bits of fractional
	// significand, and a sign bit. This means that
	// we could be losing up to 33 bits of precision
	// from the value. We are moving the decimal point
	// to the left, between 32 and 64 spaces, depending
	// on whether the value occupies all of the 64 bits
	// of integer significand. And zero is a special case.

	// Check for zero
	R2 = R0 | R1;
	CC = R2 == 0;
	IF CC JUMP .ret_zero;

	// If the high half is just zero we can treat this as
	// a 32-bit int-to-float.

	CC = R1 == 0;
	IF !CC JUMP .full_64;

	// It's just a 32-bit value. Move the significand
	// to the high half, set the exponent and return.

	R1 = R0;
	R0 = 31 (Z);

	// We may need to right-shift the significand to ensure
	// a zero sign bit. If this is the case, we might be
	// losing a bit of precision from the LSB.

	CC = R1 < 0;
	R2 = CC;
	R1 >>= R2;
	R0 = R0 + R2;

	// Normalise.

	R2.L = SIGNBITS R1;
	R2 = R2.L (X);
	R1 <<= R2;
	R0 = R0 - R2 (S);

.ret_zero:
	RTS;

.full_64:

	// There's data in the high half. Is there data
	// in the low half?

	CC = R0 == 0;
	IF CC JUMP .high_only;

	// There is data in both halves. Shift left as much
	// as possible to remove the sign-bits, so that we
	// don't chop too much off.

	R2.L = SIGNBITS R1;
	R2 = R2.L (X);
	R3 = 32;
	R3 = R3 - R2;
#ifdef __WORKAROUND_SHIFT
	R0 = LSHIFT R0 BY R3.L;
#else
	R0 >>= R3;		// the bits we move from R0 to R1
#endif
	R1 <<= R2;
	R1 = R1 | R0;
	R0 = 64 (Z);
	R0 = R0 - R2;		// exponent is 64 - amount we shift
	RTS;

.high_only:
	// There is only data in the high half. Set the
	// exponent, clear the sign bit, and return.

	R0 = 63 (Z);

	// Again, need to ensure a zero sign bit, which could
	// lose us some precision.

	CC = R1 < 0;
	R2 = CC;
	R1 >>= R2;
	R0 = R0 + R2;

	// Normalise.

	R2.L = SIGNBITS R1;
	R2 = R2.L (X);
	R1 <<= R2;
	R0 = R0 - R2 (S);

	RTS;
.size ___floatundidf, .-___floatundidf
.global ___floatundidf;
.type ___floatundidf, STT_FUNC;
