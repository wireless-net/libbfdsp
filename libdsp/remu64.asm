/*
** Copyright (C) Analog Devices, Inc,
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Unsigned long long remainder.
**
** unsigned long long __umoddi3(unsigned long long, unsigned long long);
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusA0BIMandLoop1Regs
**
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___umoddi3;
.file_attr FuncName      = ___umoddi3;

#endif

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRY AC
#else
#define CARRY AC0
#endif

.text;

.align 2;

___umoddi3:
	[SP +0] = R0;
	[SP +4] = R1;
	[SP +8] = R2;
	R3 = [SP +12];

	P0 = R4;		// Working space

	// If  x < y, then return x.
	CC = R1 < R3 (IU);
	R4 = CC;
	CC = R1 == R3;
	R4 = ROT R4 BY 1;
	CC = R0 < R2 (IU);
	R4 = ROT R4 BY 1;
	CC = R4 < 3;
	R4 = P0;
	IF !CC JUMP RET_X;
	
	LINK 16;

	// Compute d = x / y
	[SP +12] = R3;
	CALL.X ____udivdi3;

	// then compute z = d * y
	R2 = [FP +16];
	R3 = [FP +20];
	[SP +12] = R3;
	CALL.X ____mullu3;

	UNLINK;

	// r = x - z, so r = -z + x

	R0 = -R0;
	CC = CARRY;
	CC = !CC;
	R3 = CC;
	R1 = -R1;
	R1 = R1 - R3;	// z now negated

	R2 = [SP +0];
	R3 = [SP +4];

	R0 = R0 + R2;
	CC = CARRY;
	R2 = CC;
	R1 = R1 + R3;
	R1 = R1 + R2;

RET_X:
	RTS;

.size ___umoddi3, .-___umoddi3
.global ___umoddi3;
.type ___umoddi3, STT_FUNC;
.extern ____udivdi3;
.extern ____mullu3;
