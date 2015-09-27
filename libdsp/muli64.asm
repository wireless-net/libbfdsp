/*
** Copyright (C) 2002-2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
** signed long long multiplication:
** long long muli64(long long, long long)
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPA0BIMandLoopRegs
**
** Note that any changes to the clobber set also affects remi64.asm
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___mulli3;
.file_attr FuncName      = ___mulli3;

#endif

.text;
.align 2;
___mulli3:
____mulli3:
	// We're using post-modify stores to allow multi-issuing,
	// which means we need to do an initial decrement of the
	// Stack pointer to prevent clobbering half of the second
	// parameter.
        SP += -4;
        R5=(A1 = R0.L*R2.L) (FU) || [SP--] = R5;
        R5 = R5.L (Z);
        A1 = A1 >> 16;
        A1 += R0.H * R2.L (FU) || [SP--] = R6;
        A1 += R0.L * R2.H (FU) || R3 = [SP+24];
        R6 = A1.W;
        R6 = R6 << 16;
        A1 = A1 >> 16;
        R6 = R6 | R5;
        A1 += R3.L * R0.L (FU) || [SP] = R7;
        A1 += R2.L * R1.L (FU);
        A1 += R0.H * R2.H (FU);
        R5 = A1.W;
        R5 = R5.L (Z);
        A1 = A1 >> 16;
        A1 += R1.H * R2.L (M,IS);
        A1 += R3.H * R0.L (M,IS);
        A1 += R1.L * R2.H (IS);
        A1 += R3.L * R0.H (IS) || R7 = [SP++];
        R3 = A1.W;
        R0 = R6;
        R3 = R3 << 16 || R6 = [SP++];
        R1 = R5 | R3;
        R5 = [SP++];
        RTS;
.size ___mulli3, .-___mulli3
.global ___mulli3;
.type ___mulli3, STT_FUNC;
.global ____mulli3;
.hidden ____mulli3;
