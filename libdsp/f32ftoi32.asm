/*
** Convert non-IEEE 32-bit floating point to 32-bit integer.
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
.file_attr libFunc = __float32_to_int32;
.file_attr libFunc = __float32_to_unsigned_int32;
.file_attr libFunc = __float32_to_int32_round_to_zero;
.file_attr libFunc = __float32_to_unsigned_int32_round_to_zero;
.file_attr FuncName      = __float32_to_int32;
.file_attr FuncName      = __float32_to_unsigned_int32;
.file_attr FuncName      = __float32_to_int32_round_to_zero;
.file_attr FuncName      = __float32_to_unsigned_int32_round_to_zero;

#endif

.text;
.align 2;

__float32_to_int32:
__float32_to_unsigned_int32:
__float32_to_int32_round_to_zero:
__float32_to_unsigned_int32_round_to_zero:

	// Quick check for zero

	CC = R0 == 0;
	IF CC JUMP .ret_zero;

	// Unpack into separate mantissa and
	// exponent.

	R1 = R0.L (X);
	R0.L = 0;

	// Check whether the exponent is outside the
	// range of the 32-bit value. If the exponent's
	// negative, then we've just got zero as a
	// result, because we lose all the bits.

	R3 = 32 (Z);
	R2 = 0;
	CC = R1 < 0;
	IF CC R0 = R2;
	IF CC JUMP .ret_zero;

	CC = R3 < R1;		// Too big?
	IF CC R0 = R2;
	IF CC JUMP .ret_zero;

	// Our exponent is now known to be in the
	// range 0..32

	// Our bits are currently 32 bits to the left
	// of where they're supposed to be, logically.
	// So take that off the exponent. That gives
	// us a shift value of -32..0, so negate, and
	// that's how much to shift. Alternatively,
	// it's 32-exponent.

	R1 = R3 - R1;
	R0 >>>= R1;
.ret_zero:
	RTS;
.size __float32_to_int32, .-__float32_to_int32
.size __float32_to_unsigned_int32, .-__float32_to_unsigned_int32
.size __float32_to_int32_round_to_zero, .-__float32_to_int32_round_to_zero
.size __float32_to_unsigned_int32_round_to_zero, .-__float32_to_unsigned_int32_round_to_zero
.global __float32_to_int32;
.global __float32_to_unsigned_int32;
.global __float32_to_int32_round_to_zero;
.global __float32_to_unsigned_int32_round_to_zero;
.type __float32_to_int32, STT_FUNC;
.type __float32_to_unsigned_int32, STT_FUNC;
.type __float32_to_int32_round_to_zero, STT_FUNC;
.type __float32_to_unsigned_int32_round_to_zero, STT_FUNC;
