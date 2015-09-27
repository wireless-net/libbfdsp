/*
** Copyright (C) 2003-2004 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** 64-bit floating point division of non-IEEE numbers.
**
** This function implements floating point division for
** non-IEEE format 64-bit numbers. X is received in R1:0.
** Y is received in R2 and on the stack. The result is
** returned in R1:0.
**
** long double __float64_div(long double, long double);
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64fast;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___divdf3;
.file_attr FuncName      = ___divdf3;

#endif

.text;
.align 2;

___divdf3:
	R3 = [SP+12];		// recover high half of Y
	R0 = R0 - R2 (S);	// subtract exponents.
	I0 = R0;		// save for later
	R2 = R1 ^ R3;		// are signs different?
	P0 = R2;
	CC = R3 == 0;		// Check for X/0
	IF CC JUMP .ret_inf;
	CC = R1 == 0;		// Check whether we're dividing 0 by Y
	IF CC JUMP .ret_zero;
	P1 = R7;		// Save for workspace
	P2 = 32;		// iterations
	R1 = ABS R1;
	R3 = ABS R3;		// Must be done using positive numbers
	R7 = 0;			// R
	LSETUP(.ls, .le) LC0 = P2;
.ls:	CC = R1 == 0;
	IF CC JUMP .skip;
	CC = R3 <= R1 (IU);
	R7 = R1 - R3;
	IF CC R1 = R7;
	R2 = ROT R2 BY 1;
.le:	R1 <<= 1;

.skip:	R0 = LC0;
	R2 <<= R0;
	R0 = 0;
	LC0 = R0;

	R0 = I0;		// Restore exponent

	// If we set the sign bit, back off one space.
	CC = R2 < 0;
	R7 = CC;
	R2 >>= R7;

	// Are the signs different? If so, negate the result.
#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
	R1 = 0;
	R1 = R1 - R2 (S);
#else
	R1 = -R2 (S);
#endif
	CC = P0 < 0;
	IF !CC R1 = R2;

	// Normalise.
	R0 = R0 + R7;		// moved from earlier to avoid signbits speedpath
	R2.L = SIGNBITS R1;
	R2 = R2.L (X);
	R1 <<= R2;
	R0 = R0 - R2 (S);

	R7 = P1;		// Restore
	CC = R1 == 0;		// check for zero
.ret_zero:
	IF CC R0 = R1;
	RTS;

.ret_inf:
	R0.L = 0xFFFF;
	R0.H = 0x7FFF;
	R1 = 0;
	CC = P0 < 0;
	R2 = CC;
	R0 = R0 + R2;		// If negative, R0 => 0x80000000
	RTS;

.size ___divdf3, .-___divdf3

.global ___divdf3;
.type ___divdf3, STT_FUNC;
