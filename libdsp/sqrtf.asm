/******************************************************************************
  Copyright (C) 2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : sqrtf.asm
  Include File   : math.h
  Label name     : __sqrtf

  Description    : This routine computes a single-precision, floating
                   point square root.

                   It returns 0 for denormalized inputs, negative inputs,
                   NaN's, and Inf's.

  Operand        : R0 - Input value, Return value

  Registers Used : R0-3, R6, R7, A0 (A1 for BF535 only), P0-2

  Cycle count    : 103
                   (BF532, Cycle Accurate Simulator)

  Code size      : 172 Bytes (188 Bytes for BF535)

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = math_bf.h;
.file_attr libGroup = math.h;
.file_attr libName  = libdsp;
.file_attr FuncName = __sqrtf;

.file_attr libFunc  = sqrtf;
.file_attr libFunc  = __sqrtf;
.file_attr libFunc  = sqrt;

      /* Called from acosf */
.file_attr libFunc  = acosf;
.file_attr libFunc  = __acosf;
.file_attr libFunc  = acos;

      /* Called from asinf */
.file_attr libFunc  = asinf;
.file_attr libFunc  = __asinf;
.file_attr libFunc  = asinf;

      /* Called from cabsf */
.file_attr libGroup = complex_fns.h;
.file_attr libFunc  = cabsf;
.file_attr libFunc  = __cabsf;
.file_attr libFunc  = cabs;

      /* cabsf is called by cartesianf */
.file_attr libFunc  = cartesianf;
.file_attr libFunc  = __cartesianf;
.file_attr libFunc  = cartesian;

      /* Called by gen_kaiser_fr16 */
.file_attr libGroup = window.h;
.file_attr libFunc  = gen_kaiser_fr16;
.file_attr libFunc  = __gen_kaiser_fr16;

      /* cabsf is called by normf */
.file_attr libFunc  = normf;
.file_attr libFunc  = __normf;
.file_attr libFunc  = norm;

      /* Called from rmsf */
.file_attr libGroup = stats.h;
.file_attr libFunc  = rmsf;
.file_attr libFunc  = __rmsf;
.file_attr libFunc  = rms;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif

.text;
.global  __sqrtf;

.extern  ___SQRT_Seed_Table;

.align 2;
__sqrtf:

       //************************** Check Input ******************************

       r2 = r0 >>> 23;            // expose the exponent
       CC = r2 <= 0;
       if CC jump _ErrSqrtf;      // if input<=0 or input is a denorm, return 0

          /* Note: we now know that the input value is +ve
          **       and therefore the sign bit is zero
          **       and therefore R2 contains (just) the exponent
          */

       r3 = 0x00ff;
       CC = r2 == r3;
       if CC jump _ErrSqrtf;      // if input=Inf or NaN, return 0

       [--SP] = (R7:6);           // Save registers R6,R7


       //****************** Convert from float to 1.31U **********************

       r3.l = 0x7f;               // 0x7f = offset
       r1 = r2+|+r3, r2 = r2-|-r3 (ASR);
       r3.l = r2.l + r3.l (ns);

       CC = bittst(r0,23);        // exponent odd?
       r1 = CC;
       r1 += -1;

       r0 <<= 9;                  // clear the exponent
       r0 >>= 2;
       bitset(r0,30);             // set implicit bit
       r7 = lshift r0 by r1.l;    // r7 = y = normalized input


       //**************************** Get seed *******************************

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


       //****************** Iterate Newton Approximation *********************

       lsetup(_SqrtfStart, _SqrtfEnd) lc0 = p1;

_SqrtfStart:
          // r0 = x0^2
          a0 = r2.h*r2.l (FU);
          a0 = a0>>15;

#if defined(__ADSPLPBLACKFIN__)
          r0 = (a0+=r2.h*r2.h) (IU);
#else
          /* Above instruction is not valid for a BF535 or its derivatives */
          a0+= r2.h*r2.h, r0.h = (a1+=r2.h*r2.h) (IU);
          r0 = a0 (FU);
#endif

          // r0 = y*x0^2/2
          a0 = r0.h*r7.l (FU);
          a0+= r0.l*r7.h (FU);
          a0 = a0>>16;

#if defined(__ADSPLPBLACKFIN__)
          r0 = (a0+=r0.h*r7.h) (IU);
#else
          /* Above instruction is not valid for a BF535 or its derivatives */
          a0+= r0.h*r7.h, r0.h = (a1+=r0.h*r7.h) (IU);
          r0 = a0 (FU);
#endif

          // r0 = (3.0-y*x(n)^2)/2
          r0 = r6-r0 (ns);

          // r0 = x(n+1) = x(n)*(3-y*x(n)^2)/2
          a0 = r0.h*r2.l (FU);
          a0+= r0.l*r2.h (FU);
          a0 = a0>>16;

#if defined(__ADSPLPBLACKFIN__)
          r2 = (a0+=r0.h*r2.h) (IU);
#else
          /* Above instruction is not valid for a BF535 or its derivatives */
          a0+= r0.h*r2.h, r0.h = (a1+=r0.h*r2.h) (IU);
          r2 = a0 (FU);
#endif

_SqrtfEnd:
          r2 <<= 3;

       // r0 = y/sqrt(y) = sqrt(y)
       a0 = r2.h*r7.l (FU);
       a0+= r2.l*r7.h (FU);
       a0 = a0>>16;

#if defined(__ADSPLPBLACKFIN__)
       r0 = (a0+=r2.h*r7.h) (IU);
#else
       /* Above instruction is not valid for a BF535 or its derivatives */
       a0+= r2.h*r7.h, r0.h = (a1+=r2.h*r7.h) (IU);
       r0 = a0 (FU);
#endif


       //****************** Convert from 1.31U to float **********************

       r2.l = -6;
       r2.l = r2.l - r1.l (ns);
       r0 = lshift r0 by r2.l;    // Clear exponent field
       bitclr(r0,23);             // and clear implied bit
       r3 <<= 23;                 // Shift up
       r0 = r0 | r3;              // and OR in the exponent


       //**************************** Exit ***********************************

_EndSqrtf:

       (R7:6) = [SP++];           // Restore all registers that were saved

       rts;

       //************************Error Exit **********************************

_ErrSqrtf:

       r0 = 0;
       rts;

.size __sqrtf, .-__sqrtf
