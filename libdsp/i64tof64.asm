/*
   Copyright (C) 2003-2005 Analog Devices, Inc.
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
  
   Convert signed long long to IEEE double-precision 64-bit
   floating point.

   long double __int64_to_float64(long long);

   How it works:
     Pretty much the same as u64tof64.asm, except if our long long is negative
     we save this information and negate the long long first.  At the end we
     set the sign bit if the long long was negative.

   1) Firstly we see if we're really converting a 32-bit value and if so call
      the appropriate 32-bit conversion routine.

   2) We then store whether the long long is negative, and if so record this
      and negate the long long.
     
   3) We then find out how much we'll have to shift then do the shift. 
      Unlike the unsigned case we know the most significant bit of R1 will
      be unset.

   4) We then do some of the rounding calculation.  IEEE 754 nearest-even
      rounding is used: 
        round to nearest & if both numbers are as near, round to even.

      So we add 1 to the most significant lost bit (which will ripple in lost
      bits if the most significant lost bit is set)

   5) We then right shift our number by 10 places; this leaves a bit in the
      least significant bit of the exponent
   
   6) If none of the lost bits are set (apart from the most significant one),
      we zero the lest significant bit of the result (as we have to round to
      even).

   7) We calculate the exponent and *add it in* to the mantissa.  We've not
      cleared the hidden bit so the mantissa will either be 1, or, in the case
      that the rounding caused an overflow of R1, 2.

   8) Finally we set the sign bit if our input number was negative
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libGroup      = integer_support;
.file_attr libName       = libf64ieee;
.file_attr FuncName      = ___floatdidf;
.file_attr libFunc       = ___floatdidf;

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
.align 2;

___floatdidf:
        // Check whether this is a 32-bit value, sign-extended
        // to 64-bits. If so, it's easier to call a different
        // conversion function.
        // 1)
        R2 = R0 >>> 31;
        CC = R1 == R2;
        IF CC JUMP .is_32bit;

        P1 = R7;                // Workspace

        // 2)
        P0 = R1;                // save sign for later
        R2 = -R0;               // Compute -val
        CC = CARRY;
        CC = !CC;
        R7 = CC;
        R3 = -R1;
        R3 = R3 - R7;
        CC = P0 < 0;            // and if val < 0
        IF CC R0 = R2;          // then use -val instead.
        IF CC R1 = R3;

        /* The above instruction maybe writes to R1 which will be used
        ** as an operand to the SIGNBITS instruction - to avoid Anomalies
        ** 05-00-127 and 05-00-209, the next instruction must not be the
        ** SIGNBITS instruction.
        */

        // There's a significant bit somewhere in the high half.
        
        // 3)
        R2 = 32;
        R7.L = SIGNBITS R1;
        R7 = R7.L (X);
        R2 = R7 - R2;
        R3 = LSHIFT R0 BY R2.L; // bits to be shifted from R0 to R1
        R0 <<= R7;
        R1 <<= R7;
        R1 = R1 | R3;

        // 4)
        R3 = R0 << 21;          // extract the bits that will be lost
        R2 = 0x200;
        R0 = R0 + R2;
        CC = CARRY;
        R2 = CC;
        R1 = R1 + R2;           // will never overflow - ms bit unset

        // 5)
        R2 = R1 << 22;
        R1 >>= 10;
        R0 >>= 10;
        R0 = R0 | R2;

        // 6)
        BITTGL(R3,31);
        CC = R3 == 0;
        R3 = CC;
        R3 = ~R3;
        R0 = R0 & R3;

        // 7)
        R3 = (1023+61) (Z);
        R7 = R3 - R7;
        R7 <<= 20;
        R1 = R1 + R7;

        // 8)
        CC = P0 < 0;
        R2 = CC;
        R2 <<= 31;
        R1 = R1 | R2;
        R7 = P1;
        RTS;
.is_32bit:
        JUMP.X ___floatsidf;

.size ___floatdidf, .-___floatdidf


.global ___floatdidf;
.type ___floatdidf,STT_FUNC;
.extern ___floatunsidf;
.extern ___floatsidf;
