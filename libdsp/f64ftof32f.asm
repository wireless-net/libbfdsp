/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert non-IEEE 64-bit floating point to non-IEEE 32-bit
** floating point.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName       = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc       = ___truncdfsf2;
.file_attr FuncName      = ___truncdfsf2;

#endif

.text;
.align 2;

___truncdfsf2:
	/* If the exponent is outside the range of the
	   16-bit space in the result, then we have an
	   infinity. In that case, the sign-extended form
	   of the exponent is sufficient, and we zero the
	   mantissa. Otherwise, we just truncate the mantissa. */

	R2 = R1.L (X);
	R3 = 0;
	CC = R2 == R1;
	IF !CC R0 = R3;		// Clear mantissa if out of range
	R0.L = R2.L << 0;
	RTS;
.size ___truncdfsf2, .-___truncdfsf2
.global ___truncdfsf2;
.type ___truncdfsf2, STT_FUNC;
