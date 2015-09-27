/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert a 64-bit unsigned int to a non-IEEE 32-bit floating point.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___unsigned_int64_to_float32;
.file_attr FuncName      = ___unsigned_int64_to_float32;

#endif

.text;
.align 2;

___unsigned_int64_to_float32:

	// Check for zero
	R2 = R0 | R1;
	CC = R2 == 0;
	IF CC JUMP .ret_zero;

	// If the high half is just zero we can treat this as
	// a 32-bit int-to-float.

	CC = R1 == 0;
	IF !CC JUMP .full_64;

	// It's just a 32-bit value.

	R1 = 31 (Z);

	// We may need to right-shift the significand to ensure
	// a zero sign bit. If this is the case, we might be
	// losing a bit of precision from the LSB.

	CC = R0 < 0;
	R2 = CC;
	R0 >>= R2;
	R1 = R1 + R2;

	// Normalise.

	R2.L = SIGNBITS R0;
	R2 = R2.L (X);
	R0 <<= R2;
	R0.L = R1.L - R2.L (S);

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
	R0.H = R1.H << 0;
	RTS;

.high_only:
	// There is only data in the high half.

	R0 = R1;
	R1 = 63 (Z);

	// Again, need to ensure a zero sign bit, which could
	// lose us some precision.

	CC = R0 < 0;
	R2 = CC;
	R0 >>= R2;
	R1 = R1 + R2;

	// Normalise.

	R2.L = SIGNBITS R0;
	R2 = R2.L (X);
	R0 <<= R2;
	R0.L = R1.L - R2.L (S);

	RTS;
.size ___unsigned_int64_to_float32, .-___unsigned_int64_to_float32
.global ___unsigned_int64_to_float32;
.type ___unsigned_int64_to_float32, STT_FUNC;
