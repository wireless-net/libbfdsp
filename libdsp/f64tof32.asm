/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU General
** Public License. See the file COPYING for more details.
**
** In addition to the permissions in the GNU General Public License,
** Analog Devices gives you unlimited permission to link the
** compiled version of this file into combinations with other programs,
** and to distribute those combinations without any restriction coming
** from the use of this file.  (The General Public License restrictions
** do apply in other respects; for example, they cover modification of
** the file, and distribution when not linked into a combine
** executable.)
**
** Non-GPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** Convert an IEEE double-precision floating point number into
** an IEEE single-precision floating point number.
**
** float __float64_to_float32(long double);
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___truncdfsf2;
.file_attr FuncName      = ___truncdfsf2;

#endif

.text;
.align 2;
___truncdfsf2:
	// Check for exceptional values first.

	R2 = R1 << 1;	// Remove sign bit.
	R2 = R2 | R0;
	CC = R2 == 0;
	IF CC JUMP .ret_zero;

	R2 = R1 << 1;	// Remove sign bit again
	R2 >>= 21;
	R3 = 0x7FF (Z);
	CC = R2 == R3;
	IF CC JUMP .inf_or_nan;

	// All other numbers are "sensible", but might be
	// out of the range of the sp version, so let's
	// have a look at the exponent.
	// dp's exponent is 0..2047, bias of 1023,
	// sp's exponent is 0..255, bias of 127, so
	// if we subtract (1023-127)=896, we get the
	// sp-biased value. If that's outside of 0..254,
	// then the exponent is beyond the sp range.

	R3 = 896 (Z);
	R2 = R2 - R3;
	CC = R2 < 0;
	IF CC JUMP .too_small;
	R3 = 255 (Z);
	CC = R2 < R3;
	IF !CC JUMP .too_big;

	// The number will fit (not counting the lost
	// precision of the mantissa), so we want the
	// low 20 bits from the high half, and the top
	// 3 bits from the low half, all shoved into the
	// bottom 23 bits of the sp number.

	// The remaining bits determine whether we round,
	// so compute that first. The bits in the low half
	// are bbGRSSSS.... where rounding is R&(S|G).

	P1 = R2;		// Save some workspace.
	R3 = R0 << 2;		// Ignore the bb bits
	CC = BITTST(R3,30);	// Is R set in GRSSSS..S00?
	R2 = CC;
	BITCLR(R3,30);		// Make sure it's not...
	CC = R3;		// So CC is set from G0SSS..S00, i.e. (G|S)
	R3 = CC;
	R2 = R2 & R3;		// R & (S|G)


	R3 = R1 << 12;		// chop off sign and exponent
	R3 >>= 9;		// position to right of sp sign+exp
	R0 >>= 29;		// keep just top three bits.
	R0 = R0 | R3;		// and combine with the rest of mantissa.
	R0 = R0 + R2;		// add in round bit
	R2 = P1;		// Restore exponent from saved area

	R2 <<= 23;		// Move exp into place
	R0 = R0 + R2;		// and add to result; if rounding caused mantissa
				// to overflow, this will affect the exponent, by
				// incrementing it.
	R1 >>= 31;		// Isolate the sign bit
	R1 <<= 31;
	R0 = R1 | R0;		// and include in result.
	RTS;

.inf_or_nan:
	// If all of the mantissa in R0 and R1 is zero, it's
	// Infinity. Otherwise, it's NaN.

	CC = R0 == 0;		// If R0 !=0, it's NaN, and R1
	IF !CC R0 = R1;		// holds a suitable NaN pattern
	IF !CC JUMP .ret_nan;	// already (extra exp bits make it sp Nan)

	// Still need to check the remaining mantissa bits in R1.

	R2 = R1 << 12;		// Mask off sign and exp
	CC = R2 == 0;
	IF !CC R0 = R1;
	IF !CC JUMP .ret_nan;

	// It's an Inf, so we need to return a corresponding sp Inf.
	// We do this by clearing the bottom low exponent bits, giving
	// us an eight-bit all-ones exponent and zero mantissa;

	R0 = R1 >> 23;
	R0 <<= 23;
.ret_nan:
.ret_zero:
	RTS;

.too_big:
	// The exponent was too large to fit into the sp, so
	// return +Inf.

	R0 = 0xff (Z);
	R0 <<= 23;
	RTS;

.too_small:
	// The exponent was too small to fit into the sp, so
	// return -Inf;

	R0 = 0x1ff (Z);
	R0 <<= 23;
	RTS;
.size ___truncdfsf2, .-___truncdfsf2

.global ___truncdfsf2;
.type ___truncdfsf2, STT_FUNC;
