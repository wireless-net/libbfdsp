/*
** Copyright (C) 2003-2006 Analog Devices, Inc.
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
** 64-bit IEEE floating point multiplication.
**
** This function implements multiplication for the long double type.
**   long double __float64_mul(long double X, long double Y)
** X is passed in R1:0. Y is passed in R2 and on the stack. The
** result is returned in R1:0.
** long double __float64_mul(long double, long double);
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusLoopRegs
**
** Changing this register set also affects the #pragma regs_clobbered in
** softfloat
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___muldf3;
.file_attr FuncName      = ___muldf3;

#endif

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRY AC
#else
#define CARRY AC0
#endif

#define MAXBIASEXP 0x7FE

.text;
.align 2;

___muldf3:
	R3 = [SP+12];		// Restore other half of Y.
	[--SP] = (R7:4);	// claim some workspace.

	// Compute the sign sR of the result, and save for
	// later.
	R4 = R1 ^ R3;
	P0 = R4;

	// Check identities - mult by zero => zero.
	R4 = R1 << 1;		// Remove sign bits
	R5 = R3 << 1;
	R6 = R4 | R0;
	CC = R6 == 0;
	R6 = R5 | R2;
	CC |= AZ;
	R6 = MAXBIASEXP+1;
	IF CC JUMP .handle_zero_op;	

	// Extract the two exponents eX and eY.
	R4 >>= 21;
	R5 >>= 21;

	CC = R4 == R6;
	IF CC JUMP .handle_nan_inf_X;
	CC = R5 == R6;
	IF CC JUMP .handle_nan_inf_Y;

	// The result exponent eR is eX+eY-1023 (both are biased,
	// so we need to remove one lot of bias to leave the
	// result still biased).

	R4 = R4 + R5;
	R7 = 1023 (Z);
	R4 = R4 - R7;

	// If eR > 2046, then we've overflowed, so return infinity.

	R7 = 2046 (Z);
	CC = R7 < R4;
	IF CC JUMP .ret_inf;

	// Now clear the exponents and signs from X and Y, leaving
	// mX and mY, and make their hidden bits explicit.

	R7.H = 1;		// write a 1
	R7.L = (20<<8) | 12;	// at posn 20, extending for 12 bits
	// Save eR, because we'll need the space.
	P1 = R4;                // here because of anomaly 05000209
	R1 = DEPOSIT(R1, R7);
	R3 = DEPOSIT(R3, R7);

	// Consider mX as (a,b,c,d) and mY as (w,x,y,z),
	// where a and w are at MSB, and d and z are at LSB.
	// Our 128-bit result of mX*mY is computed as follows:
	// A = a*w
	// X = (a*w + w*b) >> 16
	// B = (b*x + a*y + w*c) >> 32
	// Y = (b*y + x*c + a*z + w*d) >> 48
	// C = (c*y + b*z + x*d) >> 64
	// Z = (c*z + y*d) >> 80
	// D = (d*z) >> 96
	//
	// mR = A+B+C+D + X+Y+Z
	// Where A, B, C, D are the partial results that
	// are aligned into 32-bit quarters of a 128-bit
	// register, and X, Y, Z are the 32-bit thirds
	// that fall halfway across the 32-bit quarters
	// of a 128-bit register.
	// This means A, B, C and D can be computed directly
	// into register positions, while X, Y, Z can be
	// computed into register positions, and then shifted
	// across 16 bits.
	// R1:0 and R3:2 are our mX and mY.
	// R4 and R5 are partial results, R7.L is A..D carry,
	// while R7.H is X..Z carry, and R6 is CC space.
	// I3:0 stores A..D and M0..M2 stores X..Z.
	//
	// So  a=R1.H, b=R1.L, c=R0.H, d=R0.L
	// and w=R3.H, x=R3.L, y=R2.H, z=R2.L.

	R6 = 0;
	R7 = 0;

	// D = (d*z) >> 96
	A0 = R0.L * R2.L (FU);
	R4 = A0.w;
	R6.L = A0.x;
	I0 = R4;

	// Z = (c*z + y*d) >> 80
	A0 = R0.H * R2.L (FU);
	A0 += R0.L * R2.H (FU);
	R4 = A0.w;
	R7.L = A0.x;
	M0 = R4;

	// C = (c*y + b*z + x*d) >> 64
	A0 = R6;		// Carry from D;
	A0 += R0.H * R2.H (FU);
	A0 += R1.L * R2.L (FU);
	A0 += R3.L * R0.L (FU);
	R5 = A0.w;
	R6.L = A0.x;
	I1 = R5;

	// Y = (b*y + x*c + a*z + w*d) >> 48
	A0 = R7;
	A0 += R1.L * R2.H (FU);
	A0 += R3.L * R0.H (FU);
	A0 += R1.H * R2.L (FU);
	A0 += R3.H * R0.L (FU);
	R5 = A0.w;
	R7.L = A0.x;
	M1 = R5;

	// B = (b*x + a*y + w*c) >> 32
	A0 = R6;
	A0 += R1.L * R3.L (FU);
	A0 += R1.H * R2.H (FU);
	A0 += R3.H * R0.H (FU);
	R5 = A0.w;
	R6.L = A0.x;
	I2 = R5;

	// X = (a*w + w*b) >> 16
	A0 = R7;
	A0 += R1.H * R3.L (FU);
	A0 += R1.L * R3.H (FU);
	R5 = A0.w;
	M2 = R5;

	// we're doing a 64*64->128 operation, but we know that
	// our input values are unsigned 53-bit numbers, and a
	// 53*53->106 operation means our top 22 bits will all be
	// zero. This means that all of A.H will be zero, so we
	// don't need to worry about carry-out from either X
	// (which would go into A.H) or A itself.

	// A = a*w
	R4 = R1.H * R3.H (FU);
	R4 = R4 + R6;			// Add in B's carry
	I3 = R4;

	// Computed our two partial results.
	// No longer need mX or mY.
	// Move M0, M1, M2 (X, Y, Z) into
	// R7.L...R4.H, via R3:0

	R2 = M2;
	R1 = M1;
	R0 = M0;

	R7.H = 0;
	R7.L = R2.H >> 0;
	R6.H = R2.L >> 0;
	R6.L = R1.H >> 0;
	R5.H = R1.L >> 0;
	R5.L = R0.H >> 0;
	R4.H = R0.L >> 0;
	R4.L = 0;

	// Move I3:0 (A..D) into R3:0 and add to
	// R7:4, rippling the carry upwards.

	R0 = I0;		// restore D
	R1 = I1;		// restore C
	R2 = I2;		// restore B
	R0 = R0 + R4;		// D + Z.L
	CC = CARRY;
	R4 = CC;
	R1 = R1 + R4;		// C + carry
	CC = CARRY;
	R3 = CC;
	R1 = R1 + R5;		// C + Y.H + Z.H
	CC = CARRY;
	R4 = CC;
	R3 = R3 + R4;		// carry out from C stage
	R2 = R2 + R3;		// B + carry
	CC = CARRY;
	R3 = I3;		// Restore A
	R5 = CC;
	R2 = R2 + R6;		// B + X.L + Y.H
	CC = CARRY;
	R4 = CC;
	R4 = R4 + R5;		// carry out from B stage
	R3 = R3 + R4;		// A + carry
	R3 = R3 + R7;		// A + X.H

	// R3:0 is now our 128-bit multiplication result.
	// The bottom 53 bits are our "lost" bits, while
	// the next 53 are our result mR.

	// Bring the exponent back from the wilderness
	R4 = P1;

	// Our exponent eR may be less than one at this
	// point, which would indicate  a denormalised number

	CC = R4 < 1;
	IF CC JUMP .denorm;

	// Is the hidden bit set in mR? If so, increment the
	// exponent eR. Otherwise, shift mR left one place,
	// which will shift in a lost bit, and should place
	// a significant bit into the hidden bit position.
	// The hidden bit is bit 105 of R3:0, which means
	// it's bit 9 of R3.

	CC = BITTST(R3, 9);
	R4 += 1;		// Assume we're incrementing
	IF CC JUMP .hidden_bit_set;
	R4 += -1;		// Nope, we're not.
	R0 = ROT R0 BY 1;	// Shuffle a bit upwards
	R1 = ROT R1 BY 1;
	R2 = ROT R2 BY 1;
	R3 = ROT R3 BY 1;

.hidden_bit_set:

	// Logically, the value is now normalized, and can
	// be rounded. But that's only logically - the
	// boundary between mR and lost bits is still between
	// bits 52 and 53 of R3:0, which is less than
	// convenient. We want it between bits 63 and 64,
	// i.e. on the gap between R2 and R1. Shift everything
	// left 11 bits.

	R7 = R0;
	R7 >>= 21;
	R0 <<= 11;

	R6 = R1;
	R6 >>= 21;
	R1 <<= 11;
	R1 = R1 | R7;

	R7 = R2;
	R7 >>= 21;
	R2 <<= 11;
	R2 = R2 | R6;

	R3 <<= 11;
	R3 = R3 | R7;

.rounding:

	// Round using:
	// - the rounding bit R, which is MSB of lost bits (R1.31)
	// - the guard bit G, which is LSB of mR (R2.0)
	// - the sticky bit S, which is all of lost bits except R,
	//   ORed together.
	// - Round (add one) if R & (S|G).

	R1 = ROT R1 BY 1;		// Move R into CC
	R7 = CC;			// R
	R1 = R1 | R0;			// OR all other lost bits together
	CC = R1;
	R6 = CC;			// to get S
	CC = BITTST(R2, 0);		// then check G
	R5 = CC;
	R6 = R6 | R5;			// S | G
	R7 = R7 & R6;			// R & (S | G)
	CC = R7 == 0;
	IF CC JUMP .no_overflow_into_exponent;
	R2 = R2 + R7;
	CC = CARRY;
	R7 = CC;
	R3 = R3 + R7;
	CC = BITTST(R3, 21);		// overflowed into exponent?
	IF !CC JUMP .no_overflow_into_exponent;
	CC = !CC;			// if this addition caused a carry
	R3 = ROT R3 BY -1;		// into exponent space, move right
	R2 = ROT R2 BY -1;		// one bit (ensuring we shift 0 in
	R4 += 1;			// from CC), and increment exponent.

.no_overflow_into_exponent:


	// Check for a zero result. If the mantissa is still zero,
	// even after rounding, then set the exponent to be zero,
	// too.

	R7 = R3 | R2;
	CC = R7 == 0;
	IF CC R4 = R7;

	// Clear the hidden bit, and recombine our mantissa mR,
	// our exponent eR, and our sign sR.

	BITCLR(R3, 20);
	R4 <<= 21;			// shift into exponent space, and
	CC = P0 < 0;			// one beyond, set sign in CC,
	R4 = ROT R4 BY -1;		// and move exponent back, pulling
	R1 = R4 | R3;			// sign with it. Move R into R1:0.
	R0 = R2;
	(R7:4) = [SP++];
	RTS;

.denorm:
	// Our exponent is less than zero. We need to right-shift
	// the mantissa -eR bits. Since we've got four registers'
	// worth to move, let's do it in 32-bit chunks at first.

	R4 = -R4;			// Make eR positive
	R5 = R4 >> 5;			// Get eR/32
	CC = R5 == 0;
	IF CC JUMP .partial_shift;	// skip whole-reg shifting.
	CC = R5 <= 3;			// Are we shifting everything out?
	IF !CC JUMP .ret_zero;
	P1 = R5;
	R5 <<= 5;			// Determine how many bits have
	R4 = R5 - R4;			// to shift, after whole-reg shifting.
	LSETUP (.lstart, .lend) LC0=P1;
.lstart:	R0 = R1;
	R1 = R2;
	R2 = R3;
.lend:	R3 = 0;

.partial_shift:
	CC = R4 == 0;
	IF CC JUMP .rounding;

	// Still need to shift N=R4 bits down, so each chunk of
	// N bits gets left-shifted M=32-N places, to align them
	// for their position in the next register.

	R5 = 32 (Z);
	R5 = R5 - R4;
	R6 = R1;
	R6 <<= R5;
	R0 >>= R4;
	R0 = R0 | R1;

	R6 = R2;
	R6 <<= R5;
	R1 >>= R4;
	R1 = R1 | R6;

	R6 = R3;
	R6 <<= R5;
	R2 >>= R4;
	R2 = R2 | R6;

	R3 >>= R4;

	// Finally, set eR = 0, which indicates a denormalised number.
	R4 = 0;
	JUMP .rounding;

.handle_zero_op:
	// One operand is zero. If the other is NaN or Inf, return NaN, else zero
	R4 = R4 | R5;
	R4 = R4 >> 21;
	CC = R4 == R6;
	IF !CC JUMP .ret_zero (BP);
.ret_default_nan:
	R0 = -1;
	R1 = R0;
	(R7:4) = [SP++];
	RTS;

	// Handle certain identities concerning multiplying NaNs and +/-inf
.handle_nan_inf_Y:
	// Swap operands and exponents
	R7 = R0;
	R0 = R2;
	R2 = R7;
	R7 = R1;
	R1 = R3;
	R3 = R7;
	R7 = R4;
	R4 = R5;
	R5 = R7;
.handle_nan_inf_X:
	// X (in R0:R1) is NaN or inf, result is inf if Y is Inf or a number,
	// and NaN otherwise.
	R7 = R3 << 1;	// If Y = 0
	CC = AZ;			// Return NaN
	R0 += 0;
	CC &= AZ;
	IF CC JUMP .ret_default_nan;
	R7 = R3 << 12; // If Y significand is zero
	CC = AZ;
	R2 += 0;
	CC &= AZ;
	R7 = R5 - R6;	// or Y exp is valid (AN set if R5 < R6, i.e. valid)
	CC |= AN;
	R7 = R1 << 12;	// and if X is inf, then return inf, otherwise NaN	
	CC &= AZ;
	R0 +=0;
	CC &= AZ;
	IF !CC JUMP .ret_default_nan;
.ret_inf:
	// Infinity is indicated by an exponent of all-ones,
	// and a mantissa of zero. Sign is that of the result.
	R0 = 0;
	R1 = 0x7FF (Z);
	R1 <<= 21;
.sign_result:
	CC = P0 < 0;			// Then move right one, pulling
	R1 = ROT R1 BY -1;	// sign bit in.
	(R7:4) = [SP++];
	RTS;

.ret_zero:
	R0 = 0;
	R1 = R0;
	JUMP .sign_result;

.size ___muldf3, .-___muldf3

.global ___muldf3;
.type ___muldf3, STT_FUNC;
