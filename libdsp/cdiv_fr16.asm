/************************************************************************
 *
 * cdiv_fr16.asm
 *
 * Copyright (C) 2000-2004 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#if 0
  Include File   : complex_fns.h
  Label Name     : __cdiv_fr16

  Description    : This function performs division of two complex
                   numbers a and b in fractional 1.15 format.
                      complex_fract16 c = a/ b;
                   
  Operand        : R0 - Numerator,
                   R1 - Denominator

  Registers Used : R0-7, A0-1

  Cycle Count    : 550 .. 987 Cycles  (BF532, Cycle Accurate Simulator)
  Code Size      : 94 Bytes.
#endif

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = complex_fns.h;
.file_attr libFunc       = __cdiv_fr16;
.file_attr libFunc       = cdiv_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cdiv_fr16;

#endif

.text;

.global  __cdiv_fr16;

.extern ___div32;

.align 2;
__cdiv_fr16:   
   /* 
    * DENOMINATOR 
    *   Denum = b.re * b.re + b.im * b.im
    */
      A0 = R1.L * R1.L (IS);
      R2 = (A0 += R1.H * R1.H) (IS);
      CC = R2 <= 0;
      IF CC JUMP CDIV_ERR;

      [--SP] = (R7:4);        // PUSH R4-7, RETS ONTO STACK
      [--SP] = RETS;

      R4 = R2 >>> 15;         // DENOMINATOR

   /* 
    * NUMERATOR
    *   Num.re = (a.re * b.re + a.im * b.im)
    *   Num.im = (a.im * b.re - a.re * b.im)
    */
      A1 = R0.H * R1.L (IS);
      R5 = (A1 -= R0.L * R1.H) (IS);
                              // NUMERATOR IMAGINARY

      A0 = R0.L * R1.L (IS);
      R0 = (A0 += R0.H * R1.H) (IS);
                              // NUMERATOR REAL

      R1 = R4;
      CALL.X  ____div32;       // NUM.RE / DENUM

      R6 =  32767;            // MAX FRACT16 = 0x7FFF
      R7 = -32768;            // MIN FRACT16 = 0x8000

      CC = R6 < R0;          
      IF CC R0 = R6;          // ROUND TO MAX ON +OVERFLOW
      
      CC = R0 < R7;
      IF CC R0 = R7;          // ROUND TO MIN ON -OVERFLOW

      R1 = R4;
      R4 = R0.L (Z);          // RESULT REAL
      R0 = R5;
      CALL.X  ____div32;       // NUM.IMAG / DENUM

      CC = R6 < R0;
      IF CC R0 = R6;          // ROUND TO MAX ON +OVERFLOW

      CC = R0 < R7;
      IF CC R0 = R7;          // ROUND TO MIN ON -OVERFLOW

      R2 = R0 << 16;          // RESULT IMAGINARY
      R0 = R2 | R4;           // ASSEMBLE RESULT

      RETS = [SP++];          // POP RETS, R4-7 FROM STACK                 
      (R7:4) = [SP++];                    

CDIV_RET:          
      RTS;  

CDIV_ERR:          
      R0 = R0 -|- R0;         // SET RESULT (0,0)
      RTS;

     .size __cdiv_fr16, .-__cdiv_fr16
