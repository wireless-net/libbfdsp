/*
** Convert fract 16 to float16
** Copyright (C) 2003 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = float16.h;
.file_attr libFunc       = fr16_to_fl16;
.file_attr libFunc       = _fr16_to_fl16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = _fr16_to_fl16;

#endif

.text;
.align 2;

_fr16_to_fl16:
	CC = R0 == 0;
	IF CC JUMP finished;
	R1.L = SIGNBITS R0.L;
	R0.H = ASHIFT R0.L BY R1.L;
	R1 = -R1 (V);
	R0.L = R1.L >> 0;
finished:
	RTS;
.size _fr16_to_fl16, .-_fr16_to_fl16
.global _fr16_to_fl16;
.type _fr16_to_fl16, STT_FUNC;
