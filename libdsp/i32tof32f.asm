/*
** Convert a 32-bit signed integer into a non-IEEE 32-bit floating point.
** Copyright (C) 2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libGroup      = integer_support;
.file_attr libName = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___floatsisf;
.file_attr FuncName      = ___floatsisf;

#endif

.text;
.align 2;

___floatsisf:
	R2 = 31;
	R1.L = SIGNBITS R0;
	R1 = R1.L (X);
	R0 <<= R1;
	R0.L = R2.L - R1.L (S);
	RTS;
.size ___floatsisf, .-___floatsisf
.global ___floatsisf;
.type ___floatsisf, STT_FUNC;
