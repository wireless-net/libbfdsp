/***************************************************************************
Copyright (C) 2000-2006 Analog Devices, Inc.
This file is subject to the terms and conditions of the GNU General
Public License. See the file COPYING for more details.

In addition to the permissions in the GNU General Public License,
Analog Devices gives you unlimited permission to link the
compiled version of this file into combinations with other programs,
and to distribute those combinations without any restriction coming
from the use of this file.  (The General Public License restrictions
do apply in other respects; for example, they cover modification of
the file, and distribution when not linked into a combine
executable.)

Non-GPL License is also available as part of VisualDSP++
from Analog Devices, Inc.

****************************************************************************
  File name :  fpmult.asm 
 
  This function performs 32 bit floating point multiplication. Implemention
  is based on the algorithm mentioned in the reference. Some more conditionS
  are added in the present algorithm to take care of various testcases.
     
  Registers used:
    Operands in  R0 & R1 
                 R0 - X operand, 
                 R1 - Y operand
                 R2 - R7
        
				  
  Special case: 
    1) If (x AND y) == 0, Return 0, 
    2) Overflow  :  If(Exp(x) + Exp(y) > 254,
                           Return 0X7F80000 or 0xFF80000
                           depending upon sign of X and y. 
							  
    3) Underflow :  If(Exp(x) + Exp(y) <= -149, RETURN 0.
  
  Reference  : Computer Architecture a Quantitative Approach 2nd Ed.
               by Jhon L Hennessy and David Patterson 
				
  !!NOTE- Uses non-standard clobber set in compiler:
          DefaultClobMinusBIMandLoopRegs

  Remember to change the #pragma regs_clobbered in fpmult.c in softfloat if you
  change this clobber set

**************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___mulsf3;
.file_attr FuncName      = ___mulsf3;

#endif

#define  BIASEXP    127
#define  MAXBIASEXP 254
#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRYFLAG	AC
#else
#define CARRYFLAG	AC0
#endif

.text;
.align 2;

.global ___mulsf3;
.type ___mulsf3, STT_FUNC;
___mulsf3:
	R2 = R0^R1;				/* sign of the result of X * Y */   
	P0 = R2;					/* Store sign  */
	R2 = R0 << 1;			/* Remove the sign bit of X */
	CC = R2 == 0;
	R3 = R1 << 1;			/* Remove the sign bit of Y */
	CC |= AZ;
	IF CC JUMP .HANDLE_ZERO_OP;

	[--SP] = (R7:4);/* Push registers R4-R7 */
	R4 = MAXBIASEXP+1;	/* Max biased exponent */
	
	/* Get exponents. */
	R2 = R2 >> 24;			/* Exponent of X operand */
	R3 = R3 >> 24;			/* Exponent of Y operand */
	CC = R2 == R4;
	IF CC JUMP .HANDLE_NAN_INF_X;
	CC = R3 == R4;
	IF CC JUMP .HANDLE_NAN_INF_Y;

	// Compute result exponent, and check for overflow
	R4 = BIASEXP;
	R5 = R2 + R3;
	R5 = R5 - R4;
	R4 <<= 1;			// R4 now 254, max allowed exponent
	CC = R4 < R5;
	IF CC JUMP .RET_INF;
	P1 = R5;				// store biased result exponent

GET_X_MANTISSA:
	R5 = R0<< 8;			/* Remove sign and exponent bits of */
	BITSET(R5,31);			/* X operand and make hidden bit explicit */
	R0 = R5 >> 8;			/* bring back x_mantissa to position with hidden bit set */ 
GET_Y_MANTISSA:
	R6 = R1 << 8;			/* Remove sign and exponent bits*/
	BITSET(R6,31);			/* Make hidden bit explicit */  
	R1 = R6 >> 8;			/* Bring back y_mantissa to position with hidden bit set */ 
DO_INT32_MULT:
	A1 = A0 = 0;

	R3=(A1=R0.L*R1.L),R2=(A0=R0.H*R1.L)(FU);	/* Multiply R0 by lsb 16 bits of R1 */  
	R5=(A1=R0.H*R1.H),R4=(A0=R0.L*R1.H)(FU);	/* Multiply R0 by msb 16 bits of R1 */

	R4 = R2+R4;			/* Add middle products */
	CC = CARRYFLAG;			/* Check for carry */
	R7 = CC;			/* R7 is 1 if true, 0 if false */
	R7 =  R7 << 16;			/* If true, add one to msb 16 bit */ 
	R5 = R5+R7;			/* of last product (R5)           */  
	R6 =  R4 >> 16;			/* Extract  msb 16 bits from accumlated sum */
	R4 =  R4 << 16;			/* Take only lsb 16 bits */
	R4 = R3+R4;			/* Get least significant 32 bit result */
	CC = CARRYFLAG;			/* Check for carry */
	R7 = R6;
	R7 += 1;			/* If true, add one to  */
  	IF CC R6 = R7;			/* msb 16 bit middle product sum (R6)  */
	R5 = R5+R6;			/* Get most significant 32 bit result */
					/* Multiplication result stored in reg. pair R5:R4 */
	R5 = R5 << 8;			/* Arrange the result in 24 bit format */ 
	R6 = R4 >> 24;			/* Extract only 8 msbits */
	R4 = R4 << 8 ;			/* R4 = A */  
	R5 = R5|R6;			/* R5 = P */                

	// At this point, R5 holds the result, aligned at LSB, and R4 holds
	// the remainder, aligned at MSB. P1 holds the biased exponent (0..255).
	R2 = P1;
	CC = R2 < 1;
	IF CC JUMP denorm;

	CC = BITTST(R5,23);
	R3 = CC;
	R2 = R2 + R3;			// if bit is set, increment exponent
	BITTGL(R3,0);			// if bit, R3==0, else R3==1
	R4 = ROT R4 BY R3.L;		// rotate 0 in, only if bit was clear
	R5 = ROT R5 BY R3.L;		// and propagate from remainder to result.

rounding:
	// R is MSB of remainder, S is rest of remainder, G is LSB of result.
	R3 = R4 >> 31;			// R bit
	R6 = R5 << 31;			// G bit
	R4 = R6 | R4;			// G | S
	CC = R4;
	R4 = CC;
	R3 = R3 & R4;			// R & (S | G)
	R6 = R5 + R3;			// check whether mantissa is zero,
	CC = R6 == 0;			// even with any rounding added in
	IF CC R2 = R6;			// and if so, also make exponent zero.
	BITCLR(R5,23);
	R2 = R2 << 23;
	R0 = R2 | R5;
	R0 = R0 + R3;
	R1 = P0;
	R1 = R1 >> 31;
	R1 = R1 << 31;
	R0 = R0 | R1;
	(R7:4) = [SP++];		/* Pop registers R4-R7 */
	RTS;

denorm:
	// The result is underflowing the exponent, so we need to
	// denormalise until the exponent is within range. This
	// means shifting right N=exp+126 bits, and incrementing
	// the exponent by N; Except that here, the exponent is already
	// biased, so we need to increment it back to 1, not to -126.

	// -130 (approx) < R2 < 0
	R6 = 32;
#ifdef __WORKAROUND_SHIFT
	R6 = R6 + R2;			// may produce a negative number
#else
	R2 = -R2;			// exponent now 0 or positive
	R6 = R6 - R2;			// may produce a negative number
#endif
	R3 = R5;
#ifdef __WORKAROUND_SHIFT
	R0 = -32;
	R2 = MAX(R2,R0);
	R5 = LSHIFT R5 BY R2.L;
	R4 = LSHIFT R4 BY R2.L;
#else
	R5 >>= R2;			// move result and remainder down
	R4 >>= R2;
#endif
	R2 = R2 - R2;			// set exponent to 0.
#ifdef __WORKAROUND_SHIFT
	CC = R6 < 0;
	R3 <<= R6;
	IF CC R3 = R2;
#else
	R3 <<= R6;			// R6 unsigned, so R6<0 => 0
#endif
	R4 = R3 | R4;			// then incorporate saved bits
	JUMP rounding;

.HANDLE_ZERO_OP:
	// One operand is zero. If the other is NaN or inf, return NaN, otherwise
	// zero
	R2 = R2 | R3;
	R2 = R2 >> 24;
	R3 = MAXBIASEXP+1;	/* Max biased exponent */
	CC = R2 == R3;
	R0 = 0;
	IF !CC JUMP .SIGN_RESULT; // Return zero (signed appropriately)
	R0 = -1;					// return default NAN
	RTS; 	// no regs to restore on this path
	
	// Handle certain identities concerning multiplying by NaNs and +/-inf
.HANDLE_NAN_INF_Y:
	// Swap operands and exponents
	R5 = R0;
	R0 = R1;
	R1 = R5;
	R5 = R2;
	R2 = R3;
	R3 = R5;
.HANDLE_NAN_INF_X:
	// Return signed inf if X=inf, and Y is either inf or a non-zero number
	// Otherwise return NaN
	R5 = R1 << 1;	// If Y = 0
	CC = AZ;			// Return NaN
	IF CC JUMP .RET_DEFAULT_NAN;
	CC = R3 < R4;	// if y exp is valid
	R5 = R1 << 9;	// or if Y significand is zero
	CC |= AZ;
	R5 = R0 << 9;	// then Y is either inf or a valid number 
	CC &= AZ;		// And if X is inf, then return inf, otherwise NaN
	IF !CC JUMP .RET_DEFAULT_NAN;
.RET_INF:
	R0 = 0x7F8 (Z);
	R0 <<= 21;
	(R7:4) = [SP++];		/* Pop registers R4-R7 */
.SIGN_RESULT:
	CC = P0 < 0;					/* Extract sign, and set into result */
	R0 = ROT R0 BY -1;			/* by rotating back with CC */
	RTS;
.RET_DEFAULT_NAN:
	R0 = -1;
	(R7:4) = [SP++];		/* Pop registers R4-R7 */
	RTS;

.size ___mulsf3, .-___mulsf3
