/************************************************************************
 *
 * f32toi32z.asm
 *
 * Copyright (C) 2003-2004 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU General
 * Public License. See the file COPYING for more details.
 *
 * In addition to the permissions in the GNU General Public License,
 * Analog Devices gives you unlimited permission to link the
 * compiled version of this file into combinations with other programs,
 * and to distribute those combinations without any restriction coming
 * from the use of this file.  (The General Public License restrictions
 * do apply in other respects; for example, they cover modification of
 * the file, and distribution when not linked into a combine
 * executable.)
 *
 * Non-GPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#if 0
    This program converts a floating point number to a 32-bit integer.

    Does not support:
      denormalized numbers 

    returns:
      0 for -0.0
      0 for NaN's
      0x7fffffff for Inf 
      0x80000000 for -Inf 

    Registers used :
     R0 - Input/output parameter 
     R1 - R3, CC

    !!NOTE- Uses non-standard clobber set in compiler:
            DefaultClobMinusPABIMandLoopRegs

    Also if you change this clobber set you'll need to change the #pragma
    regs_clobbered in f32toi32r.c in SOFTFLOAT
#endif

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libGroup      = integer_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";     
.file_attr libFunc = ___fixsfsi;
.file_attr FuncName      = ___fixsfsi;

#endif

.text;

.align 2;
___fixsfsi:
         
     
                                     // Check for zero input
   R2 = R0 << 1;                     // remove sign bit
   CC = R2 == 0;
   IF CC JUMP .ret_zero;
       
                                     // Check for other exceptional values.
   R3 = 0xff (Z);
   R3 <<= 24;
   CC = R3 <= R2 (IU);
   IF CC JUMP .inf_or_nan;

   CC = BITTST(R0,31);               // see if float is negative 
   
   R2 = R2 >> 24;                    // Bring exponent to LSB
   
   R1 = 150;                         // 127 + 23 offset for float to int
   R3 = R2 - R1;                     // unbiased exponent

   R1 = -1;                          // set R1 to 0x007fffff - mantissa mask
   R1.H = 0x007f;
   R0 = R0 & R1;                     // R1 masks off the exponent bits in R0
   BITSET(R0,23);                    // Implicit 1 for hidden bit made explicit

                                     // clip the shift magnitude. No need to
                                     // do clip of R3 to +31 as if R3 > 31 at
                                     // this point the C standard says
   R2 = -32;                         // the behaviour is undefined.
   R3 = MAX(R2,R3);                  // -32 <= R3

   R0 = ASHIFT R0 BY R3.L (S);       // shift the mantissa into place.
   R1 = - R0;
   IF CC R0 = R1;
   RTS;    

.inf_or_nan:
   // It's an Inf or a NaN. If it's an Inf, then mantissa will be all zero.

   CC = R3 < R2 (IU);
   IF CC JUMP .is_nan;

   CC = BITTST(R0, 31);              // Check for sign of input 
   IF CC JUMP .neg_inf;              // if negative, return negative inf

   R0.H = 0x7FFF;
   R0.L = 0xFFFF;
   RTS;

.neg_inf:
   R0 = 0;                           // return R0 = 0x80000000
   BITSET(R0,31);
   RTS;

.is_nan:
.ret_zero:                           // if we jump here R0==(+/-)0.0/NaN
                                     // We just return zero.
   R0 = 0;
   RTS;
.size ___fixsfsi, .-___fixsfsi

.global ___fixsfsi;
.type ___fixsfsi, STT_FUNC;

// end of file
