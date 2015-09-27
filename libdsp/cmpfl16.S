/*
** Float16 compare.  Compares 2 non-IEEE-754 floating point numbers (16.16)
**
** Copyright (C) 2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName       = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc       = ___cmpsf2;
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
	CC = R0 < 0;
	R2 = CC;
	CC = R1 < 0;
	R3 = CC;
	CC = R2 == R3;
	IF !CC JUMP diff_signs;

	// signs are the same. Examine exponents.
	R0 = R0 -|- R1;
	R1 = R0.L (X);	// difference between exponents
	R0 >>>= 16;	// difference between mantissas
	CC = R1 == 0;	// If exponents are the different, they decide.
	IF !CC R0 = R1;	// Otherwise, mantissas decide.
	R1 = -R0;	// If x was negative (and therefore y also negative)
	CC = R2 == 0;	// then we have to negate our result
	IF !CC R0 = R1;	//
	RTS;

diff_signs:
	// Signs are different, so we return a number that
	// derives its sign from whether X was negative.
	R0 = R2 << 31;
	R0 += 1;
	RTS;
.size ___cmpsf2, .-___cmpsf2
.size ___eqsf2, .-___eqsf2
.size ___gesf2, .-___gesf2
.size ___gtsf2, .-___gtsf2
.size ___lesf2, .-___lesf2
.size ___ltsf2, .-___ltsf2
.size ___nesf2, .-___nesf2
.global ___cmpsf2;
.global ___eqsf2;
.global ___gesf2;
.global ___gtsf2;
.global ___lesf2;
.global ___ltsf2;
.global ___nesf2;
.type ___cmpsf2, STT_FUNC;
.type ___eqsf2, STT_FUNC;
.type ___gesf2, STT_FUNC;
.type ___gtsf2, STT_FUNC;
.type ___lesf2, STT_FUNC;
.type ___ltsf2, STT_FUNC;
.type ___nesf2, STT_FUNC;
