/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert a 64-bit signed integer to a non-IEEE 32-bit floating point.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libGroup      = integer_support;
.file_attr libName = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___int64_to_float32;
.file_attr FuncName      = ___int64_to_float32;

#endif

.text;
.align 2;

___int64_to_float32:

	// Check for zero
	R2 = R0 | R1;
	CC = R2 == 0;
	IF CC JUMP .ret_zero;

	// If the high half is just sign bits extended from
	// the MSB of the low half, then we can treat this as
	// a 32-bit int-to-float.

	R2 = R0 >>> 31;		// Make R2 all sign bits
	CC = R2 == R1;
	IF !CC JUMP .full_64;

	// It's just a 32-bit signed value.

	R1 = 31 (Z);

	// and normalise.

	R2.L = SIGNBITS R0;
	R2 = R2.L (X);
	R0 <<= R2;
	R0.L = R1.L - R2.L (S);
.ret_zero:
	RTS;

.full_64:

	// There is some data in the high half. Is there any in
	// the low half? If not, we won't lose precision.

	CC = R0 == 0;
	IF CC JUMP .high_only;
	CC = R0 == R2;		// all sign-bits
	IF CC JUMP .minus_one;

	// There is data in both halves. Shift left as much
	// as possible to remove the sign-bits, so that we
	// don't chop too much off.

	R2.L = SIGNBITS R1;
	R2 = R2.L (X);
	R3 = 32;
#ifdef __WORKAROUND_SHIFT
	R3 = R2 - R3;
	R0 = LSHIFT R0 BY R3.L;
#else
	R3 = R3 - R2;
	R0 >>= R3;		// the bits we move from R0 to R1
#endif
	R1 <<= R2;
	R1 = R1 | R0;
	R0 = -R2;		// exponent is 63 - amount we shift
	R0 += 63;
	R0.H = R1.H << 0;
	RTS;
.high_only:
	// There is only data in the high half of the int.
	// That means it's already positioned appropriately.
	// Just set the exponent.

	R0 = R1;
	R1 = 63 (Z);

	// and normalise.

	R2.L = SIGNBITS R0;
	R2 = R2.L (X);
	R0 <<= R2;
	R0.L = R1.L - R2.L (S);
	RTS;

.minus_one:
	// The int is all-ones, so set the exponent to 31,
	// rather than 63, because 63 would imply another
	// 32 bits of zeros.
	R0.L = 31;
	RTS;
.size ___int64_to_float32, .-___int64_to_float32
.global ___int64_to_float32;
.type ___int64_to_float32, STT_FUNC;
