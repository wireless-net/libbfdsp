/************************************************************************
 *
 * mulfl32.s
 *
 * Copyright (C) 2000-2003 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = _mul_fl32;
.file_attr FuncName      = _mul_fl32;

#endif

/*
** Takes 2 non-IEEE 32.32 floats and multiplies them
*/

#if defined(__ADSPBLACKFIN__) && !defined(__ADSPLPBLACKFIN__)
/* __ADSPBF535__ core only */
#define OVERFLOW AV0
#else
#define OVERFLOW V
#endif

.text;
.align 2;
_mul_fl32:
   R3 = [SP+12];   // get mantissa of second input
   R0 = R0 + R2;   // Add exponents

   // 32-bit fractional multiply
   // R1 = R1 * R3
   R2 = PACK(R1.L, R3.L);
   CC = R2 == 0;
   CC = !CC;
   A1 = R1.L * R3.L (FU);
   A1 = A1 >> 16;
   A0 = R1.H * R3.H, A1 += R1.H * R3.L (M);
   CC &= OVERFLOW;
   A1 += R3.H * R1.L (M);
   A1 = A1 >>> 15;
   R3 = CC;
   R1 = (A0 += A1);
   R1 = R1 + R3;

   // Normalise
#if defined(__WORKAROUND_SIGNBITS) || defined(__WORKAROUND_DREG_COMP_LATENCY)
   NOP;
#endif
   R2.L = SIGNBITS R1;
   R2 = R2.L (X);
   R1 <<= R2;
   R0 = R0 - R2;

   CC = R1 == 0;
   IF CC R0 = R1;
   RTS;
.size _mul_fl32, .-_mul_fl32
.global _mul_fl32;
.type _mul_fl32, STT_FUNC;

// end of file
