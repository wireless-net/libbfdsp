/*
** Copyright (C) Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert float to unsigned long long (R4 to U8).
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = __float32_to_unsigned_longlong64;
.file_attr FuncName      = __float32_to_unsigned_longlong64;

#endif


.text;
.align 2;

__float32_to_unsigned_longlong64:
	CC = R0 < 0;		// Negative values return zero.
	IF CC JUMP ret_zero;
	R1 = R0 << 1;		// Extract mantissa
	R1 >>= 24;
	R2 = 150 (X);		// 127 for unbiasing, 23 for adjusting
	R1 = R1 - R2;		// exponent value, since the 1.xxx is
				// actually shifted 23 bits into low half.
				// R1 now e'.

	// cases 0 and 6 both will mean we shift everything off one
	// end or the other, so we return the same value in both cases.

	R3 = -24 (X);		// case 0: e' < -24
	CC = R1 < R3;
	IF CC JUMP ret_zero;
	R3 = 64;		// case 6: 64 <= e'
	CC = R3 <= R1;
	IF CC JUMP ret_zero;

	// Other cases will leave at least some of the bits within
	// high or low halves (or both), so need to extract the
	// mantissa.

	R0 <<= 8;		// extract mantissa bits
	R0 >>= 8;
	BITSET(R0, 23);		// and restore hidden bit.

	CC = R1 < 0;		// case 1: -24 <= e' < 0
	IF CC JUMP case_1;
	R3 = 8;
	CC = R1 < R3;		// case 2: 0 <= e' < 8
	IF CC JUMP case_2;
	R3 <<= 2;
	CC = R1 < R3;		// case 3: 8 <= e' < 32;
	IF CC JUMP case_3;

	// The two remaining cases are:
	// case 4: 32 <= e' < 40	mantissa entirely in high half
	// case 5: 40 <= e' < 64	mantissa partially off the top
	// of high half. Both treated the same.

case_4:
case_5:
	// we've shifted the value off the top of the high half.
	// set high = mantisa << (e'-32), low = 0
	R3 = 32;
	R3 = R1 - R3;
	R1 = ASHIFT R0 BY R3.L;
	R0 = 0;
	RTS;

case_1:
case_2:
	// We have either:
	// case 1: -24 <= e' < 0	mantissa partially off bottom of low
	// case 2:   0 <= e' < 8	mantissa entirely in low half
	// both are treated the same
	R0 = ASHIFT R0 BY R1.L;
	R1 = 0;
	RTS;

case_3:
	// case 3: 8 <= e' < 32		mantissa split between high and low
	R2 = R0;			// Save L, for computing H
	R0 = ASHIFT R0 BY R1.L;		// L=L>>e'
	R3 = 32;			// Want H=L>>(32-e'), which is
	R3 = R1 - R3;			// H=L<<(e'-32)
	R1 = ASHIFT R2 BY R3.L;
	RTS;

ret_zero:
	R0 = 0;
	R1 = R0;
	RTS;

.size __float32_to_unsigned_longlong64, .-__float32_to_unsigned_longlong64
.global __float32_to_unsigned_longlong64;
.type __float32_to_unsigned_longlong64, STT_FUNC;
