/* Copyright (C) 2007 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 */
/*
** Convert a float to Float32.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = _fl_to_fl32;
.file_attr FuncName      = _fl_to_fl32;

#endif

.text;
.align 2;
_fl_to_fl32:
	R1 = R0 << 1;
	CC = R1 == 0;			// if +0.0 or -0.0
	IF CC R0 = R1;			// then set both to
	IF CC JUMP finished;		// zero and return.

	// Extract sign
	R3 = R0 >> 31;
	R3 <<= 31;
	P0 = R3;

	R1 = R0;
	BITSET(R1, 23);
	R1 <<= 8;
	R1 >>= 1;
	
	// Extract exponent
	R2 = R0 << 1;
	R2 >>= 24;
	R3 = 126;
	R0 = R2 - R3;

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
	R2 = 0;
	R2 = R2 - R1 (S);
#else
	R2 = - R1 (S);
#endif
	CC = P0 < 0;
	IF CC R1 = R2;
finished:
	RTS;
.size _fl_to_fl32, .-_fl_to_fl32
.global _fl_to_fl32;
.type _fl_to_fl32, STT_FUNC;
