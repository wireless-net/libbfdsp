/* Copyright (C) 2002 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 */
/*
** Check whether the supplied value is Infinity.
** Returns non-zero if so, zero if not.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = math.h;
.file_attr libGroup      = math_bf.h;
.file_attr libFunc       = isinff;
.file_attr libFunc       = _isinf;
.file_attr libFunc       = isinf;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = _isinf;

#endif

.text;
.align 2;
_isinf:
	BITCLR(R0, 31);		// Remove sign bit
	R1 = 0xFF;
	R1 <<= 23;		// R1 now +Inf.
	CC = R0 == R1;
	R0 = CC;
	RTS;
.size _isinf, .-_isinf
.global _isinf;
.type _isinf, STT_FUNC;

