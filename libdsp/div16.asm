/******************************************************************************
  Copyright (C) 2000-2004 Analog Devices, Inc. 
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
 ******************************************************************************
  File Name      : div16.asm
  Module Name    : Library Support Routine
  Label name     :  __div16

  Description    : This function performs signed division of a 
                   16 bit integer. DIVS and DIVQ are used to get 
                   the result in fractional 1.15 format

                   The numerator must be less than the denominator,
                   otherwise the result will overflow.  

  Operand        : R0 - Numerator,
                   R1 - Denominator

  Registers Used : R2-0, P0

  Cycle Count    : 35 Cycles  (BF532, Cycle Accurate Simulator)
  Code Size      : 32 Bytes.
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libFunc       = __div16;
/* Called by atan2_fr16 */
.file_attr libGroup      = math.h;
.file_attr libGroup      = math_bf.h;
.file_attr libFunc       = __atan2_fr16;
.file_attr libFunc       = atan2_fr16;
/* atan2_fr16: called by arg_fr16 */
.file_attr libGroup      = complex_fns.h;
.file_attr libFunc       = __arg_fr16;
.file_attr libFunc       = arg_fr16;
/* atan2_fr16: arg_fr16: called by cartesian_fr16 */
.file_attr libFunc       = __cartesian_fr16;
.file_attr libFunc       = cartesian_fr16;
/* Called by cabs_fr16 */
.file_attr libFunc       = __cabs_fr16;
.file_attr libFunc       = cabs_fr16;
/* Called by mean_fr16 */
.file_attr libGroup      = stats.h;
.file_attr libFunc       = __mean_fr16;
.file_attr libFunc       = mean_fr16;

.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __div16;

#endif

.text;
.global  ____div16;
.hidden  ____div16;

.global  __div16;

.align 2;
__div16:
____div16:

                   P0 = 15;                  // TO PERFORM DIVQ 15 TIMES
                   R2 = R0 ^ R1;             // SET FLAG R2 IF SIGNS DIFFER
                   R1 = ABS R1;              // ABS VALUE OF DENOMINATOR
                   R0 = ABS R0;              // ABS VALUE OF NUMERATOR
                   R0 <<= 16;                // ARRANGING FOR PROPER DIVISION.   
                   DIVS (R0, R1);            // CALL DIVS TO CLEAR AQ FLAG

                   LSETUP( DIV_START, DIV_START ) LC0 = P0;
DIV_START:           DIVQ (R0, R1);          // DIVQ IS DONE FOR 15 TIMES

                   R0 = R0.L (X);            // SIGN EXTENDING THE RESULT 

                   R1 = -R0;                 // NEGATED RESULT
                   CC = R2 < 0;
                   IF CC R0 = R1;            // NEGATE RESULT IF FLAG R2 SET

                   RTS;  
.size __div16, .-__div16

