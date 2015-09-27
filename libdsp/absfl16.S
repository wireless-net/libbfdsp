/*
** Float16 abs
** Copyright (C) 2003 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = float16.h;
.file_attr libFunc       = _abs_fl16;
.file_attr libFunc       = abs_fl16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = _abs_fl16;

#endif

.text;
.align 2;
_abs_fl16:
	R1 = ABS R0 (V);
	R0.H = R1.H >> 0;
	RTS;
.size _abs_fl16, .-_abs_fl16
.global _abs_fl16;
.type _abs_fl16, STT_FUNC;
