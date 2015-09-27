/*
** Convert a float to a float16.
** Copyright (C) 2003 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = float16.h;
.file_attr libFunc       = fl_to_fl16;
.file_attr libFunc       = _fl_to_fl16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = _fl_to_fl16;

#endif

.text;
.align 2;
_fl_to_fl16:
	R1 = R0 << 1;
	CC = R1 == 0;
	IF CC R0 = R1;		// +0.0 or -0.0 both come out as 0.0
	IF CC JUMP finished;	// in float16.

	// extract sign
	R1 = R0 >> 31;
	R1 <<= 31;

	// extract exponent
	R2 = R0 << 1;
	R2 >>= 24;
	R3 = 126;		// because float16 includes hidden bit
	R2 = R2 - R3;

	BITSET(R0, 23);		// make hidden bit explicit
	R0 <<= 8;		// move mantissa to top, removing exp and sign
	R0 >>= 1;		// then back to make space for sign

	R3 = - R0 (V);		// negate the mantissa if the sign
	CC = R1;		// bit is set.
	IF CC R0 = R3;

	R0.L = R2.L >> 0;	// move the exponent in.
finished:
	RTS;
.size _fl_to_fl16, .-_fl_to_fl16
.global _fl_to_fl16;
.type _fl_to_fl16, STT_FUNC;

