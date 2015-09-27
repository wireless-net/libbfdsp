/*
** Normalise a float16.
** Copyright (C) 2003 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = _norm_fl16;
.file_attr FuncName      = _norm_fl16;

#endif

.text;
.align 2;

_norm_fl16:
	R1 = R0;
	R1 >>>= 16;
	R3.L = SIGNBITS R0.H;
	R0.H = ASHIFT R0.H BY R3.L;
	R0.L = R0.L - R3.L (NS);
	CC = R1 == 0;
	IF CC R0 = R1;
	RTS;
.size _norm_fl16, .-_norm_fl16
.global _norm_fl16;
.type _norm_fl16, STT_FUNC;

