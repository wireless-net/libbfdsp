/*
** Copyright (C) 2003-2005 Analog Devices, Inc.
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
** Convert an unsigned integer 32-bit value into an IEEE
** double-precision floating point value.
** long double __unsigned_int32_to_float64(unsigned int)
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
**
** If you change the clobber set, remember to change SOFTFLOAT and also
** i64tof64.asm and u64tof64.asm
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___floatunsidf;
.file_attr FuncName      = ___floatunsidf;

#endif

.text;
.align 2;

___floatunsidf:
        // Check for zero first.

        CC = R0 == 0;
        IF CC R1 = R0;
        IF CC JUMP .ret_zero;

        CC = R0 < 0;            // I.e. the MSB (not a sign bit) is set
        IF CC JUMP .big_val;

        // Determine the exponent.

        R2.L = SIGNBITS R0;
        R2 = R2.L (X);

        R0 <<= R2;              // Adjust for normalisation
        R1 = R0;                // Put adjusted bits in high half.
        R0 <<= 22;              // Adjust for the bits that are
                                // in high half (including hidden)
        R1 >>= 10;              // and then back for exponent space

        R3 = (1023+29);         // Bias the exponent (+29 cos we add
                                // in the hidden bit that makes it +30)
        R2 = R3 - R2;

        R2 <<= 20;              // Position at MSB, leaving space for sign.
        R1 = R1 + R2;           // Combine with mantissa.
.ret_zero:
        RTS;

.big_val:
        // The MSB is set, where we'd expect to find the sign bit,
        // so we know what our exponent will be. Set the values
        // directly.

        R1 = R0 >> 11;          // Align MSB with hidden bit
        R0 <<= 21;              // Adjust remaining bits in low half.
        R2 = (1023+30);         // Bias exponent (+30 cos we dont zero the
                                // hidden bit - instead we add it in)
        R2 <<= 20;              // and position for exponent; sign is positive.
        R1 = R1 + R2;           // and include exponent.
        RTS;
.size ___floatunsidf, .-___floatunsidf

.global ___floatunsidf;
.type ___floatunsidf,STT_FUNC;
