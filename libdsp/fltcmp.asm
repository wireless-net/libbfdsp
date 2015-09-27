/*
** Floating point comparison.
** Copyright (C) Analog Devices, Inc. 2002.
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
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___cmpsf2;
.file_attr FuncName      = ___cmpsf2;

#endif

.text;
.align 2;
___cmpsf2:
___eqsf2:
___gesf2:
___gtsf2:
___lesf2:
___ltsf2:
___nesf2:
	// Test for NaNs, which must compare as not-equal,
	// no matter to what they are compared.
	// A NaN has an exponent of 255, and a non-zero
	// mantissa. Sign is irrelevant. We check whether
	// either input is a NaN by getting rid of the
	// sign bit, and then comparing against 0x7F80000;
	// if the operand is larger, it's got a 255 exponent
	// and non-zero mantissa, hence it's a NaN.
	// If R0 is a NaN, it's a suitable return value, since
	// it's non-zero.

	R2 = R0 << 1;
	R2 >>= 1;
	R3 = 0XFF;
	R3 <<= 23;
	CC = R3 < R2;
	IF CC JUMP nan;

	// If R1 is a NaN, then it's also a suitable return
	// value, so move it into R0 before jumping to the return.

	R2 = R1 << 1;
	R2 >>= 1;
	CC = R3 < R2;
	IF CC R0 = R1;
	IF CC JUMP nan;

	// Neither operand is a NaN. If they're both zero,
	// then they must compare equal, regardless of their
	// sign bits. Otherwise, we can treat the floats as
	// signed integers, since the remaining values are
	// properly ordered (sign bit is the same, tiny
	// exponents are smaller than huge exponents).

	R2 = R0 - R1;		// check whether the two
	CC = R2 == 0;		// are equal, and return zero
	IF CC JUMP res;		// if so.

	R2 = R0 | R1;		// check whether both are
	R2 <<= 1;		// zero, ignoring sign bits.
	CC = R2 == 0;
	IF CC JUMP res;

	R2 = 1;
	R3 = -R2;
	CC = R0 < R1;		// if R0 < R1, then
	IF CC R2 = R3;		// R2 == -1, else R2 == 1
	R3 = R0 & R1;		// If both R0 and R1 are negative
	CC = BITTST(R3,31);	// then toggle the sign bit on
	R3 = -R2;		// R2 before returning.
	IF CC R2 = R3;
res:
	R0 = R2;
nan:
	RTS;
.size ___cmpsf2, .-___cmpsf2
.size ___eqsf2, .-___eqsf2
.size ___gesf2, .-___gesf2
.size ___gtsf2, .-___gtsf2
.size ___lesf2, .-___lesf2
.size ___ltsf2, .-___ltsf2
.size ___nesf2, .-___nesf2
.type ___cmpsf2, STT_FUNC;
.type ___eqsf2, STT_FUNC;
.type ___gesf2, STT_FUNC;
.type ___gtsf2, STT_FUNC;
.type ___lesf2, STT_FUNC;
.type ___ltsf2, STT_FUNC;
.type ___nesf2, STT_FUNC;
.global ___cmpsf2;
.global ___eqsf2;
.global ___gesf2;
.global ___gtsf2;
.global ___lesf2;
.global ___ltsf2;
.global ___nesf2;

