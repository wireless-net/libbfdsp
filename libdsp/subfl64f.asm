/* 
** Copyright (C) 2003-2005 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** 64-bit non-IEEE floating point subtraction (and addition).
**
** This routine does 64-bit floating point subtraction, of two
** numbers in non-IEEE format. X is passed in R1:0. Y is
** passed in R2 and on the stack. The result is returned
** in R1:0.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName       = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc       = ___subdf3;
.file_attr FuncName      = ___subdf3;
.file_attr libFunc       = ___adddf3;
.file_attr FuncName      = ___adddf3;

#endif


.text;
.align 2;

___subdf3:
	R3 = [SP+12];		// Get high half of Y
	P0 = R7;		// Workspace
	// Arrange for R = X - Y to be done as R = X + -Y
#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
	R7 = 0;
	R3 = R7 - R3 (S);
#else
	R3 = -R3 (S);
#endif
	JUMP .common;

___adddf3:
	R3 = [SP+12];		// Get high half of Y
	P0 = R7;		// Workspace

.common:
	// If X or Y is zero, return the other.
	CC = R3 == 0;
	IF CC JUMP .ret_x;
	CC = R1 == 0;
	IF CC JUMP .ret_y;

	// Need to align mantissas, so arrange for Y to
	// be the less significant of the two.

	CC = R0 < R2;		// is X less significant?
	IF CC R7 = R0;		// if so, swap X and Y
	IF CC R0 = R2;
	IF CC R2 = R7;
	IF CC R7 = R1;
	IF CC R1 = R3;
	IF CC R3 = R7;


	// Y is now less significant, so shift Y's mantissa
	// right until it's aligned with X.

	R2 = R0 - R2;
#ifdef __WORKAROUND_SHIFT
	R7 = 31;
	R2 = MIN(R7,R2);
#endif
	R3 >>>= R2;
	R7 = R1 ^ R3;		// Note whether the signs are
	CC = R7 < 0;		// different
	CC = !CC;
	R1 = R1 + R3;

	// If the signs of X and Y are the same, and the sign
	// of the result is different from X/Y, then we've had
	// overflow. I.e. (X^Y==0 && Y^R==1) => overflow

	R3 = R3 ^ R1;
	CC &= AN;

	// If there was an overflow, then shift the mantissa
	// right one space, and increment the exponent.

	R2 = CC;
	R7 = ROT R7 BY 1;	// Get expected sign
	R3 = ROT R1 BY -1;	// Move into result
	R0 = R0 + R2;
	CC = R2;
	IF CC R1 = R3;

	// Normalise.
#if defined(__WORKAROUND_SIGNBITS) || defined(__WORKAROUND_DREG_COMP_LATENCY)
	NOP;
#endif
	R2.L = SIGNBITS R1;	// Get number of sign bits, less one.
	R2 = R2.L (X);
	R1 <<= R2;		// shift and adjust exponent to account
	R0 = R0 - R2 (S);	// for it.
	
	// Check for a zero mantissa. Set exponent to zero
	// too, if so.

	CC = R1 == 0;
	IF CC R0 = R1;

.ret_x:
	R7 = P0;		// Restore
	RTS;
.ret_y:
	R1 = R3;
	R0 = R2;
	R7 = P0;		// Restore
	RTS;
.size ___subdf3, .-___subdf3

.global ___subdf3;
.global ___adddf3;
.type ___subdf3, STT_FUNC;
.type ___adddf3, STT_FUNC;
