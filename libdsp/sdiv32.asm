/******************************************************************************
  Copyright (C) 2000-2007 Analog Devices, Inc. 
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : sdiv32.asm
  Module Name    : Runtime Support
  Label name     : ___div32

  Description    : 16 / 32 bit signed division .

  !!NOTE- Uses non-standard clobber set in compiler:
          DefaultClobMinusPABIMandLoop1Regs

  Note that any changes to the clobber set also affects urem32.asm

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup=integer_support;
.file_attr libName=libdsp;
.file_attr prefersMem=internal;
.file_attr prefersMemNum="30";
.file_attr libFunc=___div32;
.file_attr FuncName=___div32;

#endif

.text;
.global ____div32;
.hidden ____div32;
.global ___div32;
.type   ___div32,STT_FUNC;

.align 2;
___div32:
____div32:
  /* Attempt to use divide primitives first; these will handle
  ** most cases, and they're quick - avoids stalls incurred by
  ** testing for identities. 
  */
  R3 = R0 ^ R1;
  R0 = ABS R0;
#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
  CC = AV0;
#else
  CC = V;
#endif
  r3 = rot r3 by -1;
  r1 = abs r1;      /* now both positive, r3.30 means "negate result", 
                    ** r3.31 means overflow, add one to result 
                    */
  cc = r0 < r1;
  if cc jump .ret_zero;
  r2 = r1 >> 15;
  cc = r2;
  if cc jump .IDENTS;
  r2 = r1 << 16;
  cc = r2 <= r0;
  if cc jump .IDENTS;

  DIVS(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);
  DIVQ(R0, R1);

  R0 = R0.L (Z);
  r1 = r3 >> 31;    /* add overflow issue back in */
  r0 = r0 + r1;
  r1 = -r0;
  cc = bittst(r3, 30);
  if cc r0 = r1;
  RTS;

/* Can't use the primitives. Test common identities. 
** If the identity is true, return the value in R2. 
*/

.IDENTS:
  CC = R1 == 0;                   /* check for divide by zero */
  IF CC JUMP .IDENT_RETURN;

  /* No need to check for division of zero here. If dividing 0 by non-zero,
  ** as we can assert would be the case at this point, we would have 
  ** returned zero already because of the " .ret_zero" jump above as r0 (zero)
  ** would be less than r1.
  */

  CC = R0 == R1;                  /* check for identical operands */
  IF CC JUMP .IDENT_RETURN;

  CC = R1 == 1;                   /* check for divide by 1 */
  IF CC JUMP .IDENT_RETURN;

  R2.L = ONES R1;
  R2 = R2.L (Z);
  CC = R2 == 1;
  IF CC JUMP .power_of_two;

  /* Identities haven't helped either.
  ** Perform the full division process.  
  */

  P1 = 31;                        /* Set loop counter   */

  [--SP] = (R7:5);                /* Push registers R5-R7 */
  R2 = -R1;
  [--SP] = R2;
  R2 = R0 << 1;                   /* R2 lsw of dividend  */ 
  R6 = R0 ^ R1;                   /* Get sign */
  R5 = R6 >> 31;                  /* Shift sign to LSB */

  R0 = 0 ;                        /* Clear msw partial remainder */ 
  R2 = R2 | R5;                   /* Shift quotient bit */ 
  R6 = R0 ^ R1;                   /* Get new quotient bit */  

  LSETUP(.LST,.LEND)  LC0 = P1;   /* Setup loop */
.LST:   R7 = R2 >> 31;            /* record copy of carry from R2 */
        R2 = R2 << 1;             /* Shift 64 bit dividend up by 1 bit */
        R0 = R0 << 1 || R5 = [SP];
        R0 = R0 | R7;             /* and add carry */
        CC = R6 < 0;              /* Check quotient(AQ) */
                                  /* we might be subtracting divisor (AQ==0) */
        IF CC R5 = R1;            /* or we might be adding divisor  (AQ==1)*/
        R0 = R0 + R5;             /* do add or subtract, as indicated by AQ */
        R6 = R0 ^ R1;             /* Generate next quotient bit */
        R5 = R6 >> 31;
                                  /* Assume AQ==1, shift in zero */
        BITTGL(R5,0);             /* tweak AQ to be what we want to shift in */
.LEND:  R2 = R2 + R5;             /* and then set shifted-in value to 
                                  ** tweaked AQ. 
                                  */
  r1 = r3 >> 31;
  r2 = r2 + r1;
  cc = bittst(r3,30);
  r0 = -r2;
  if !cc r0 = r2;
  SP += 4;
  (R7:5)= [SP++];                 /* Pop registers R6-R7 */
  RTS;

.IDENT_RETURN:
  CC = R1 == 0;                   /* check for divide by zero  => 0x7fffffff */
  R2 = -1 (X);
  R2 >>= 1;
  IF CC JUMP .TRUE_IDENT_RETURN;

  CC = R0 == R1;                  /* check for identical operands => 1 */
  R2 = 1 (Z);
  IF CC JUMP .TRUE_IDENT_RETURN;

  R2 = R0;                        /* assume divide by 1 => numerator */
  /*FALLTHRU*/

.TRUE_IDENT_RETURN:
  R0 = R2;                        /* Return an identity value */
  R2 = -R2;
  CC = bittst(R3,30);
  IF CC R0 = R2;
.ZERO_RETURN:
  RTS;                            /* ...including zero */

.power_of_two:
  /* Y has a single bit set, which means it's a power of two.
  ** That means we can perform the division just by shifting
  ** X to the right the appropriate number of bits
  */

  /* signbits returns the number of sign bits, minus one.
  ** 1=>30, 2=>29, ..., 0x40000000=>0. Which means we need
  ** to shift right n-signbits spaces. It also means 0x80000000
  ** is a special case, because that *also* gives a signbits of 0
  */

  R2 = R0 >> 31;
  CC = R1 < 0;
  IF CC JUMP .TRUE_IDENT_RETURN;

  R1.l = SIGNBITS R1;
  R1 = R1.L (Z);
  R1 += -30;
  R0 = LSHIFT R0 by R1.L;
  r1 = r3 >> 31;
  r0 = r0 + r1;
  R2 = -R0;                       // negate result if necessary
  CC = bittst(R3,30);
  IF CC R0 = R2;
  RTS; 

.ret_zero:
  R0 = 0;
  RTS;

.size ___div32, .-___div32
