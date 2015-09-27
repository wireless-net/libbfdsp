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
** Convert a signed integer 32-bit value into an IEEE
** double-precision floating point value.
** long double __int32_to_float64(int)
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusPABIMandLoopRegs
**
** Note you'll need to change SOFTFLOAT source if you change this regset
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libGroup      = integer_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___floatsidf;
.file_attr FuncName      = ___floatsidf;

#endif

.text;
.align 2;

___floatsidf:

	// Check for inputs of 0x0 or 0x80000000 
	R1 = R0 << 1;
	CC = AZ;
	IF CC JUMP .ret_min_or_zero;

	// The mantissa will be unsigned, so if the input
	// value is negative, negate it, and remember this
	// fact.

	CC = R0 < 0;
	R1 = -R0;
	IF CC R0 = R1;

	// Determine the exponent.

	R3 = 1053;			// Load exponent bias in advance here to prevent
							// signbits operand having been loaded in previous
							// instruction (anomaly 05-00-0209 and 05-00-0127)
	R2.L = SIGNBITS R0;
	R2 = R2.L (X);
	R0 <<= R2;			// Adjust for normalisation
	R1 = R0;				// Put normalized bits into high half.
	R0 <<= 22;			// Adjust for the bits that are
							// in high half (including hidden)
	R1 >>= 10;			// and then back for exponent space
	BITCLR(R1,20);		// Remove the hidden bit.
							// Exponent is biased by 1023, and it also
	R2 = R3 - R2;		// includes the number of bits we'd shift
							// *right*, to make the most significant bit
							// into 1 (because we're 1.x raised to a
							// power). So that's 1023+(30-signbits).

	R2 <<= 21;			// Position at MSB
	R2 = ROT R2 BY -1;// and insert sign bit (in CC), realigning exponent
	R1 = R1 | R2;		// Combine with mantissa.
	RTS;

.ret_min_or_zero:
	CC = BITTST(R0,31);
	R0 = 0;
	R1.H = 0xC1E0;		// Exponent and sign for int min
	IF !CC R1 = R0;	// Return representation of int min
	RTS;	

.size ___floatsidf, .-___floatsidf

.global ___floatsidf;
.type ___floatsidf,STT_FUNC;
