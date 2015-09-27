/*
** Copyright (C) 2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert non-IEEE 32-bit floating-point to non-IEEE 64-bit
** floating-point.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___extendsfdf2;
.file_attr FuncName      = ___extendsfdf2;

#endif

.text;
.align 2;

___extendsfdf2:
	/* Exponent is a signed integer, so extend it to the high half. */
	R1 = R0.L (X);
	/* Mantissa is a signed fraction, so extend it to the low half. */
	R0.L = 0;
	RTS;
.size ___extendsfdf2, .-___extendsfdf2
.global ___extendsfdf2;
.type ___extendsfdf2, STT_FUNC;

