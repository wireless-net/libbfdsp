/*
** Copyright (C) 2003-2006 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
** Signed long long division.
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusABIMandLoop1Regs
**
** Note that any changes to the clobber set also affects remi64.asm
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = integer_support;
.file_attr libName       = libdsp;
.file_attr libFunc       = ___divdi3;
.file_attr FuncName      = ___divdi3;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define CARRY AC
#else
#define CARRY AC0
#endif

.text;
.global ____divdi3;
.hidden ____divdi3;
.global ___divdi3;
.type   ___divdi3,STT_FUNC;
.extern ____lshftli

.align 2;

___divdi3 :
____divdi3 :
   R3 = [SP+12];
   [--SP] = (R7:4, P5:3);

   /* Attempt to use divide primitives first; these will handle
      most cases, and they're quick - avoids stalls incurred by
      testing for identities. */

   R4 = R2 | R3;
   CC = R4 == 0;
   IF CC JUMP .DIV_BY_ZERO;

   R4.H = 0x8000;
   R4 >>>= 16;          // R4 now 0xFFFF8000
   R5 = R0 | R2;        // If either dividend or divisor have bits in
   R4 = R5 & R4;        // top half or low half's sign bit, skip builtins.
   CC = R4;
   IF CC JUMP .IDENTS;
   R4 = R1 | R3;        // Also check top halves
   CC = R4;
   IF CC JUMP .IDENTS;

   /* We now know that the two 64-bit parameters contain positive
      16-bit values, so we can use the internal primitives */
   DIVS(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   DIVQ(R0, R2);
   R0 = R0.L (X);
   R1 = R0 >>> 31;
   (R7:4, P5:3) = [SP++];
   RTS;

   /* Can't use the primitives. Test common identities. */
   /* If the identity is true, return the value in R6,R7. */

.IDENTS:
   // Check for 0/y, return zero
   R4 = R0 | R1;
   CC = R4 == 0;        // NR==0 => 0
   IF CC JUMP .ZERO_RETURN;

   // Check for x/x, return 1
   R6 = R0 - R2;
   R7 = R1 - R3;
   R4 = R6 | R7;        // if x==y, return 1
   R6 += 1;
   CC = R4 == 0;
   IF CC JUMP .IDENT_RETURN;

                        // Check for x/1, return x
   R6 = R0;
   R7 = R1;
   CC = R3 == 0;

   IF !CC JUMP .nexttest (bp);
   CC = R2 == 1;
   IF CC JUMP .IDENT_RETURN;

.nexttest:

   // Check for x/-1, return -x
   // first, negate R6/R7
   R6 = -R6;
   CC = CARRY;
   CC = !CC;
   R7 = -R7;
   R4 = CC;
   R7 = R7 - R4;
   // then check whether y is -1
   R4 = R2 & R3;
   CC = R4 == -1;
   IF CC JUMP .IDENT_RETURN;

   // check for divide by 0x8000000000000000. If found, return 0. The case of
   // Y also being same value which should result in 1 should already have
   // been handled.
   R6 = R2;
   R7 = R3;
   BITCLR(R7,31);
   R4 = R6 | R7;
   CC = R4 == 0;
   IF CC JUMP .IDENT_RETURN;

   /* Identities haven't helped either. Perform the full
      division process. */

   R4 = R1 ^ R3;        // Note the sign of the result
   [--SP] = R4;         // and store for later.

   CC = R1 < 0;
   IF !CC JUMP .xispos;
   // negate x to get positive value X'=ABS(X)
   R0 = -R0;
   CC = CARRY;
   CC = !CC;
   R1 = -R1;
   R4 = CC;
   R1 = R1 - R4;
.xispos:
   // We also want to get Y'=ABS(Y), but the inner loop involves us
   // either adding or subtracting Y'. I.e. Adding Y' or -Y', i.e.
   // Adding Y' or Y. So we want to negate regardless.

   R4.L = ONES R2;      // check for div by power of two which
   R5.L = ONES R3;      // can be done using a shift

   P0 = R2;             // First save Y in P0,P1.
   P1 = R3;
   R2 = -R2;            // Then negate Y.
   CC = CARRY;
   CC = !CC;
   R7 = -R3;
   R6 = CC;
   R7 = R7 - R6;
   P2 = R2;             // And store into P2,P3.
   P3 = R7;

   R6 = PACK (R5.L, R4.L);  // continue check of div by power of two
   CC = R6 == 1;
   IF CC JUMP .power_of_two_upper_zero;
   R6 = PACK (R4.L, R5.L);
   CC = R6 == 1;
   IF CC JUMP .power_of_two_lower_zero;

   // Assume Y positive, and P0,P1=Y, and P2,P3=-Y.
   // But if Y is negative, need to swap them over.
   CC = R7 < 0;
   IF !CC P2 = P0;
   IF !CC P3 = P1;
   IF !CC P0 = R2;
   IF !CC P1 = R7;

   R6 = 0;              // remainder = 0
   R7 = R6;
   [--SP] = R6; P5 = SP;
   [--SP] = P3; P3 = SP;
   [--SP] = P2; P2 = SP;
   [--SP] = P1;

   // At this point, P0:P1 == Y', and P2:P3 == -Y'

   /* We now need to start computing a quotient and remainder.
      We use the following register assignments:
      R0-R1	x, workspace
      R2-R3	y, workspace
      R4-R5	partial division
      R6-R7	partial remainder
      P5		AQ;
      The division and remainder form a 128-bit value, with
      the Remainder in the higher bits.
   */

   // Set the quotient to X' << 1. So we want to shift in 0:

   CC = R6;             // i.e. zero
   R4 = ROT R0 BY 1;
   R5 = ROT R1 BY 1;    // Now X'<<1.

   R1 = 0;
   P4 = 63;             // Set loop counter 

   LSETUP(.LST,.LEND)  LC0 = P4;   /* Setup loop */
.LST:  /* Shift quotient and remainder up by one; the bit shifted out
          of quotient is shifted into the bottom of the remainder. */

       CC = R1;
       R4 = ROT R4 BY 1;      // bit from low q to high q
       R5 = ROT R5 BY 1 ||    // bit from high q to low r
            R0 = [P5];        // restore saved AQ
       R6 = ROT R6 BY 1 ||    // bit from low r to high r
            R3 = [P3];        // Recover -Y'
       R7 = ROT R7 BY 1 ||    // bit discarded
            R2 = [P2];        // Recover -Y'
       CC = R0 < 0;           // Check AQ
       IF CC R2 = P0;         // If set, then use Y' instead of -Y'
       IF CC R3 = P1;
       R6 = R6 + R2;          // remainder += Y' (or -= Y')
       CC = CARRY;
       R0 = CC;
       R7 = R7 + R3;
       R7 = R7 + R0 (NS) ||
            R0 = [SP];        // Get high half of Y'.
    
       R0 = R7 ^ R0;          // Next AQ comes from remainder^Y'
       R0 = R0 >> 31 ||       // Position for "shifting" into quotient
            [P5] = R0;        // Save next AQ
       BITCLR(R4,0);          // Assume AQ==1, shift in zero
       BITTGL(R0,0);          // tweak AQ to be what we want to shift in
.LEND: R4 = R4 + R0;          // then set shifted-in value to tweaked AQ.

   R0 = -R4;            // Set result to -quotient
   CC = CARRY;
   CC = !CC;
   R1 = -R5;
   R6 = CC;
   R1 = R1 - R6;

   R6 = [SP + 16];      // Get sign of result from X^Y
   CC = R6 < 0;
   IF !CC R0 = R4;      // and if not negative, then set
   IF !CC R1 = R5;      // result to quotient after all.

   SP += 20;
   (R7:4, P5:3)= [SP++];
   RTS;


   /* Y has a single bit set, which means it's a power of two.
   ** That means we can perform the division just by shifting
   ** X to the right the appropriate number of bits
   */

   /* signbits returns the number of sign bits, minus one.
   ** 1=>30, 2=>29, ..., 0x40000000=>0. Which means we need
   ** to shift right n-signbits spaces. It also means 0x80000000
   ** is a special case, because that *also* gives a signbits of 0
   **
   ** also, the code that jumps to this label has preserved the top
   ** half of Y in R3 - this avoids an instance of Anomalies 05-00-0127
   ** and 05-00-0209 which would have occurred if the operand of the
   ** SIGNBITS instruction below had been created by its preceding
   ** instruction (as in R3=P1).
   */

.power_of_two_lower_zero:
   // case of division by 0x8000000000000000 already handled
   R2.L = SIGNBITS R3;
   R2 = R2.L (Z);
   R2 += -62;
   

.power_of_two_rtn:
   [--SP] = RETS;       // save RETS
   CALL.X ____lshftli;
   R4 = -R0;            // calculate -quotient
   CC = CARRY;
   CC = !CC;
   R5 = -R1;
   R6 = CC;
   R5 = R5 - R6;

   RETS = [SP++];       // pop RETS
   R6 = [SP++];         // Get sign of result from X^Y
   CC = R6 < 0;
   IF CC R0 = R4;       // and if not negative, then set
   IF CC R1 = R5;       // result to quotient after all.

   (R7:4, P5:3)= [SP++];
   RTS;

.power_of_two_upper_zero:
   R4 = P0;             // copy lower half of Y (upper half is zero)

   // to avoid Anomalies 05-00-0127 and 05-00-0209, the instruction that
   // precedes SIGNBITS must not create its operand - hence the following
   // useful instruction has been used to separate the initialization of
   // R4 from its use in the SIGNBITS instruction.
   CC = R4 < 0;

   R2.L = SIGNBITS R4;
   IF CC JUMP .maxint_shift;

   R2.L = SIGNBITS R4;
   R2 = R2.L (Z);
   R2 += -30;
   JUMP .power_of_two_rtn;

.maxint_shift:
   R2 = -31;
   JUMP .power_of_two_rtn;

.IDENT_RETURN:
   R0 = R6;             // Return an identity value
   R1 = R7;
.ZERO_RETURN:
   (R7:4, P5:3) = [SP++];
   RTS;                 // ...including zero

.DIV_BY_ZERO:
   R1 = ROT R1 BY 1;    // save sign bit in CC 
   R0 = ~R2;            // R2==0, so R0 = all-ones 
   R1 = ROT R0 BY -1;   // and copy to R1, but restore sign to give 
                        // us 7fff.... or ffff....
   (R7:4, P5:3) = [SP++];
   RTS;

.size ___divdi3, .-___divdi3
