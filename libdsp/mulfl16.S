/*
** Float16 multiply.  Takes 2 non-IEEE-754 floats and multiplies them (16.16)
**
** Copyright (C) 2004-2006 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName       = libf64fast;
.file_attr FuncName      = ___mulsf3;
.file_attr libFunc       = ___mulsf3;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif

.text;
.align 2;
___mulsf3:
	R2.L = R0.L + R1.L (NS);
	R0 = R0.H * R1.H;		// Produce 32-bit result first
	R0.L = R0.L - R0.L (NS);	// And lose bottom bits of precision

        /* Work around Anomalies 05-00-0127 and 05-00-0209 which
        ** require that the operand to the SIGNBITS instruction
        ** is not created in the preceding instruction
        */
	CC = R0 == 0;                   // Record if the result is zero

	// Normalise, in case it's needed
	R3.L = SIGNBITS R0.H;
	R1.H = ASHIFT R0.H BY R3.L;
	R1.L = R2.L - R3.L (NS);

	// Which isn't true if the result is zero.
	IF !CC R0 = R1;

	RTS;

.size ___mulsf3, .-___mulsf3
.global ___mulsf3;
.type ___mulsf3, STT_FUNC;
