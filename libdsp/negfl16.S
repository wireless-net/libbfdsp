/*
** Float16 negate
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
.file_attr libFunc = _negate_fl16;
.file_attr FuncName      = _negate_fl16;

#endif

.text;
.align 2;
_negate_fl16:
	R1 = 0;
	R0.H = R1.H - R0.H (NS);
	RTS;
.size _negate_fl16, .-_negate_fl16
.global _negate_fl16;
.type _negate_fl16, STT_FUNC;
