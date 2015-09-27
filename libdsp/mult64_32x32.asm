/*
** Copyright (C) 2002-2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
** signed long long multiplication:
** long long mult64_32x32(int, int)
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___mult64_32x32;
.file_attr FuncName      = ___mult64_32x32;

#endif

.text;
.align 2;
___mult64_32x32:

	/* multiply 32 bit signed integers R0 (h0,l0) and R1 (h1,l1)
	** to give 64 bit signed integer result by shift and add.
	*/

	R2 = (A0 = R0.L * R1.L) (FU);	// l0	* l1
	A1 = R1.H * R0.L (M,IS);		// (h0 * l1)
	A1 += R0.H * R1.L (M,IS);		// +(h1*l0)
	A0 = A0 >> 16;	
	A0 += A1;							// y = (h0*l1 + h1*l0) + (l0*l1>>16)
	R3 = A0.W;
	A0 = A0 >>> 16;
	A0 += R0.H * R1.H (IS);			// high word = h0*h1 + y>>16
	R1 = A0.W;
	R0 = PACK(R3.L,R2.L);			// low word = (y<<16) | l0*l1
	RTS;

.size ___mult64_32x32, .-___mult64_32x32
.global ___mult64_32x32;
.type ___mult64_32x32,STT_FUNC;

