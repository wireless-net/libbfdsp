/******************************************************************************
  Copyright (C) 2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : rsqrtf.asm
  Include File   : math_bf.h
  Label name     : __rsqrtf

  Description    : This routine computes a single-precision, floating
                   point reciprocal square root.

                   It returns 0 for denormalized inputs, negative inputs,
                   NaN's, and Inf's.

  Operand        : R0 - Input value, Return value

  Registers Used : R0-3, R6, R7, A0 (A1 for a BF535 only), P0-2

  Cycle count    : 99
                   (BF532, Cycle Accurate Simulator)

  Code size      : 158 Bytes (170 for a BF535)

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = math_bf.h;
.file_attr libGroup = math.h;
.file_attr libName  = libdsp;
.file_attr FuncName = __rsqrtf;

.file_attr libFunc  = __rsqrtf;
.file_attr libFunc  = rsqrtf;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif


.text;
.global  __rsqrtf;

.extern  ___SQRT_Seed_Table;

.align 2;
__rsqrtf:


       //************************** Check Input ******************************

       r2 = r0 >>> 23;            // expose exponent and sign bit
       CC = r2 <= 0;
       if CC jump _ErrRsqrtf;     // if input<=0 or input is a denorm, return 0

          /* Note: we now know that the input value is +ve
          **       and therefore that the sign bit is zero
          **       and therefore R2 contains (just) the exponent
          */

       r3 = 0x00ff;
       CC = r2 == r3;
       if CC jump _ErrRsqrtf;     // if input=Inf or NaN, return 0

       [--SP] = (R7:6);           // Save registers R6,R7


       //******************* Convert from float to 1.31U *********************

       r3.l = 0x7f;               // 0x7f = offset
       r1=r3+|+r2, r2=r3-|-r2 (ASR);
       r3.l = r2.l + r3.l (ns);

       CC = bittst(r0,23);        // exponent odd?
       r1 = CC;
       r3 = r3 - r1;
       r1 += -1;

       r0 <<= 9;                  // clear the exponent
       r0 >>= 2;
       bitset(r0,30);             // set implicit bit
       r7 = lshift r0 by r1.l;    // r7 = y = normalized input


       //***************************** Get seed ******************************

       r0 = r7 >> 24;
       p0 = r0;

       p2.l = ___SQRT_Seed_Table-0x20;
       p2.h = ___SQRT_Seed_Table-0x20;

       r6.h = 0x3000;
       r6.l = 0x0000;             // r6 = 1.5

       p1 = 3;
       p2 = p2 + p0;
       r2 = b[p2] (Z);
       r2 <<= 24;


       //******************* Iterate Newton Approximation ********************

       lsetup(_RsqrtfStart, _RsqrtfEnd) lc0=p1;

_RsqrtfStart:
          // r0 = x0^2
          a0 = r2.h*r2.l (FU);
          a0 = a0>>15;

#if defined(__ADSPLPBLACKFIN__)
          r0 = (a0+=r2.h*r2.h) (IU);
#else
          /* Above instruction is not valid for a BF535 or its derivatives */
          a0+=r2.h*r2.h, r0.h=(a1+=r2.h*r2.h) (IU);
          r0 = a0 (FU);
#endif

          // r0 = y*x0^2/2
          a0 = r0.h*r7.l (FU);
          a0+= r0.l*r7.h (FU);
          a0 = a0>>16;

#if defined(__ADSPLPBLACKFIN__)
          r0 =(a0+=r0.h*r7.h) (IU);
#else
          /* Above instruction is not valid for a BF535 or its derivatives */
          a0+= r0.h*r7.h, r0.h = (a1+=r0.h*r7.h) (IU);
	  r0 = a0 (FU);
#endif

          // r0 = (3.0-y*x(n)^2)/2
          r0 = r6-r0 (ns);

          // r2 = x(n+1) = x(n)*(3-y*x(n)^2)/2
          a0 = r0.h*r2.l (FU);
          a0+= r0.l*r2.h (FU);
          a0 = a0>>16;

#if defined(__ADSPLPBLACKFIN__)
          r2 =(a0+=r0.h*r2.h) (IU);
#else
          /* Above instruction is not valid for a BF535 or its derivatives */
          a0+= r0.h*r2.h, r0.h = (a1+=r0.h*r2.h) (IU);
          r2 = a0 (FU);
#endif

_RsqrtfEnd:
          r2 <<= 3;               // r2 = 1/sqrt(y) = rsqrt(y)


       //******************* Convert from 1.31U to float *********************

       r7.l = -7;
       r7.l = r7.l + r1.l (ns);
       r0 = lshift r2 by r7.l;    // Clear the exponent field,
       bitclr(r0,23);             // and clear the implied bit
       r3 <<= 23;                 // Shift up,
       r0 = r0 | r3;              // and OR in the exponent


       //***************************** Exit **********************************

       (R7:6) = [SP++];           // Restore all registers that were saved

       rts;

       //************************Error Exit **********************************

_ErrRsqrtf:

       r0 = 0;
       rts;

.size __rsqrtf, .-__rsqrtf
