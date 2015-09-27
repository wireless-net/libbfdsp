/******************************************************************************
  Copyright (C) 2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : lib_mult64.asm
  Label name     : ___SQRT_Mult64

  Description    : This routine performs a 64 bit unsigned multiply
                   of 1.63 x 1.63 => 1.63

                   This function is a support function used by the sqrtd()
                   and rsqrtd() functions. It does not conform to the Blackfin
                   C/C++ runtime model and therefore its use should be
                   confined to the sqrtd() and rsqrtd() functions.

  Operand        : Input [R1:R0], [R3:R2], P5 -> Temp, P0 -> _Zero
                   Output [R1:R0], P5 -> Temp

  Registers Used : R0-7, P0, P5, A0, A1

  Code size      : 122 Bytes (134 Bytes for BF535)

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = math_bf.h;
.file_attr libGroup = math.h;
.file_attr libName  = libdsp;

      /* Called from acosd */
.file_attr libFunc  = acosd;
.file_attr libFunc  = __acosd;
.file_attr libFunc  = acosl;
.file_attr libFunc  = acos;

      /* Called from asind */
.file_attr libFunc  = asind;
.file_attr libFunc  = __asind;
.file_attr libFunc  = asinl;
.file_attr libFunc  = asin;

      /* Called from cabsd */
.file_attr libFunc  = cabsd;
.file_attr libFunc  = __cabsd;
.file_attr libFunc  = cabs;

      /* cabsd is called by cartesiand */
.file_attr libFunc  = cartesiand;
.file_attr libFunc  = __cartesiand;
.file_attr libFunc  = cartesian;

      /* cabsf is called by normd */
.file_attr libFunc  = normd;
.file_attr libFunc  = __normd;
.file_attr libFunc  = norm;

      /* Called from rmsd */
.file_attr libFunc  = rmsd;
.file_attr libFunc  = __rmsd;
.file_attr libFunc  = rms;

      /* Called from rqrtd */
.file_attr libFunc  = rsqrtd;
.file_attr libFunc  = __rsqrtd;
.file_attr libFunc  = rsqrt;

      /* Called from sqrtd */
.file_attr libFunc  = sqrtd;
.file_attr libFunc  = __sqrtd;
.file_attr libFunc  = sqrtl;
.file_attr libFunc  = sqrt;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif

.text;
.global   ___SQRT_Mult64;

.align 2;
___SQRT_Mult64:
        // Compute r1*r3 => [r7:r6]
        a1 = r1.l*r3.l, a0 = r1.h*r3.l (FU) || r4.l = w[p0];
        a1 = a1>>16;
        a1+= r1.h*r3.l, a0+= r1.l*r3.h (FU);
        a0 = a0<<16;
        a0.x= r4.l;
        a1+= r1.l*r3.h, a0+= r1.l*r3.l (FU);
        a0.x= r4.l;
        a1 = a1>>16;


#if defined(__ADSPLPBLACKFIN__)
        r7 = (a1+=r1.h*r3.h) (IU);
        r6 = a0 (FU);
#else
        /* Above instruction is not valid for a BF535 or its derivatives */
        r6 = a0 (FU);
        a0+= r1.h*r3.h, r7.h =(a1+=r1.h*r3.h) (IU);
        r7 = a1 (FU);
#endif

        // Compute r0*r3 => [r4:-]
        a0 = r0.h*r3.l (FU) || [p5++] = r6;
        a0+= r0.l*r3.h (FU) || [p5] = r7;
        a0 = a0>>16;

#if defined(__ADSPLPBLACKFIN__)
        r4 = (a0+=r0.h*r3.h) (IU);
#else
        /* Above instruction is not valid for a BF535 or its derivatives */
        a0+= r0.h*r3.h, r4.h =(a1+=r0.h*r3.h) (IU);
        r4 = a0 (FU);
#endif

        // Compute r1*r2 => [r7:-]
        a1 = r1.h*r2.l (FU);
        a1+= r1.l*r2.h (FU);
        a1 = a1>>16;

#if defined(__ADSPLPBLACKFIN__)
        r7 = (a1+=r1.h*r2.h) (IU);
#else
        /* Above instruction is not valid for a BF535 or its derivatives */
        a0+= r1.h*r2.h, r7.h = (a1+=r1.h*r2.h) (IU);
        r7 = a1 (FU);
#endif


        //-----------------------------------
        // Current Temp Storage:  (R1*R3).L
        //                        (R1*R3).H
        //                        (R0*R3).H
        //-----------------------------------

        r4 = r7+r4 (ns) || r5=[p5--]; // R4 = (R1*R2).H + (R0*R3).H,
                                      // R5 = (R1*R3).H, P5-> (R1*R3).L
#if defined(__ADSPLPBLACKFIN__)
        CC = AC0;
#else
        CC = AC;
#endif
        r7 = CC;                      // R7 = Carry

        r5 = r5+r7 (ns) || r7=[p5++]; // R5 = (R1*R3).H + C.H.H,
                                      // R7 = (R1*R3).L, P5 -> (R1*R3).H

        r0 = r4+r7 (ns) || r7=[p5--]; // R4 = (R1*R2) + (R0*R3).H + (R1*R3).L,
                                      // P5 -> (R1*R3).L
#if defined(__ADSPLPBLACKFIN__)
        CC = AC0;
#else
        CC = AC;
#endif
        r7 = CC;                      // R7 = Carry

        r1 = r5+r7 (ns);              // R5 = (R1*R3).H + C1 + C2

        rts;

.size ___SQRT_Mult64, .-___SQRT_Mult64
