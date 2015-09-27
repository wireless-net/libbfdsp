/*
** Copyright (C) 2002-2003 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
** Logical shift, on signed long long.
** inline long long __lshftli (long long  ll1, int i1);
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___lshftli;
.file_attr FuncName      = ___lshftli;

#endif

.text;

.align 2;
___lshftli:
____lshftli:
	CC = R2 == 0;
	IF CC JUMP finished;	// nothing to do
	CC = R2 < 0;
	IF CC JUMP rshift;
	R3 = 64;
	CC = R2 < R3;
	IF !CC JUMP retzero;

	// We're shifting left, and it's less than 64 bits, so
	// a valid result will be returned.

	R3 >>= 1;	// R3 now 32
	CC = R2 < R3;

	IF !CC JUMP zerohalf;

	// We're shifting left, between 1 and 31 bits, which means
	// some of the low half will be shifted into the high half.
	// Work out how much.

	R3 = R3 - R2;

	// Save that much data from the bottom half.

	P1 = R7;
	R7 = R0;
	R7 >>= R3;

	// Adjust both parts of the parameter.

	R0 <<= R2;
	R1 <<= R2;

	// And include the bits moved across.

	R1 = R1 | R7;
	R7 = P1;
	RTS;

zerohalf:
	// We're shifting left, between 32 and 63 bits, so the
	// bottom half will become zero, and the top half will
	// lose some bits. How many?

	R2 = R2 - R3;	// N - 32
	R1 = LSHIFT R0 BY R2.L;
	R0 = R0 - R0;
	RTS;

retzero:
	R0 = R0 - R0;
	R1 = R0;
finished:
	RTS;

rshift:
	// We're shifting right, but by how much?
	R2 = -R2;
	R3 = 64;
	CC = R2 < R3;
	IF !CC JUMP retzero;

	// Shifting right less than 64 bits, so some result bits will
	// be retained.

	R3 >>= 1;	// R3 now 32
	CC = R2 < R3;
	IF !CC JUMP signhalf;

	// Shifting right between 1 and 31 bits, so need to copy
	// data across words.

	P1 = R7;
	R3 = R3 - R2;
	R7 = R1;
	R7 <<= R3;
	R1 >>= R2;
	R0 >>= R2;
	R0 = R7 | R0;
	R7 = P1;
	RTS;

signhalf:
	// Shifting right between 32 and 63 bits, so the top half
	// will become all zero-bits, and the bottom half is some
	// of the top half. But how much?

	R2 = R2 - R3;
	R0 = R1;
	R0 >>= R2;
	R1 = 0;
	RTS;

.size ___lshftli, .-___lshftli
.global ___lshftli;
.type ___lshftli, STT_FUNC;
.global ____lshftli;
.hidden ____lshftli;
