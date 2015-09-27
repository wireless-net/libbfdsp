/* Copyright (C) 2007 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 */
/*
** Float32 compare.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName       = libdsp;
.file_attr libFunc       = _cmp_fl32;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = _cmp_fl32;

#endif

.text;
.align 2;

_cmp_fl32:
	P0 = R7;
	R3 = [SP+12];
	R7 = R1 | R3;
	CC = R7 < 0;
	IF CC JUMP diff_signs;

	R7 = P0;
	R0 = R0 - R2;	// diff between exponents
	R1 = R1 - R3;	// diff between mantissas
	CC = R0 == 0;	// If exponents are different, they decide
	IF CC R0 = R1;	// otherwise, mantissas decide
	R2 = -R0;
	CC = R3 < 0;	// If Y neg (and hence X neg), neg result
	IF CC R0 = R2;
	RTS;
diff_signs:
	R7 = P0;
	R1 >>>= 31;
	R0 = R1;
	R0 += 1;
	RTS;
.size _cmp_fl32, .-_cmp_fl32
.global _cmp_fl32;
.type _cmp_fl32, STT_FUNC;
