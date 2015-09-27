/******************************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : vmax.asm
  Include File   : vector.h
  Label name     : __vecmax_fr16

  Description    : This function returns the largest array value

                   If the number of samples is 0, the return value
                   is set to zero.

  Operand        : R0 - Address of input array X,
                   R1 - Number of samples

  Registers Used : R0-3, P0-2

  Cycle count    : n = 24: 56 Cycles  (BF532, Cycle Accurate Simulator)

  Code size      : 78 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = vector.h;
.file_attr libFunc       = vecmax_fr16;
.file_attr libFunc       = __vecmax_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __vecmax_fr16;

#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_SPECULATIVE_LOADS)
#define __WORKAROUND_BF532_ANOMALY_050000245
#endif

.text;
.global __vecmax_fr16;

.align 2;
__vecmax_fr16:

       P0 = R0;              // P0 = Address of input array X
       P1 = R1;              // P1 = Loop counter (preset to number of samples)
       P2 = 2;

       R2 = 0;               // Set return value for number of samples == 0
       CC = R1 <= 0;
       IF CC JUMP DONE;      // Exit if number of samples == 0


       // Function needs to handle four different cases:
       //   1) &input 32-bit aligned, number of samples even
       //               => loading two data values before entering loop
       //                  and performing (number of samples / 2)
       //                  parallel comparisons within the loop body
       //                  Total comparissons for n = 10: (10 / 2) * 2 = 10
       //   2) &input 32-bit aligned, number of samples odd
       //               => loading two data values before entering loop
       //                  and performing (number of samples - 1) / 2
       //                  parallel comparisons within the loop body, 
       //                  final comparison after completing the loop
       //                  Total comparissons for n = 9: (8 / 2) * 2 + 1 = 9
       //   3) &input 16-bit aligned, number of samples even
       //               => loading one data value before entering loop,
       //                  performing one single comparison and
       //                  ((number of samples + 1) / 2) - 1
       //                  parallel comparisons within the loop body,
       //                  final comparison after completing the loop
       //                  Total comparissons for n = 10: 1+(((11/2)-1)*2)+1=10
       //   4) &input 16-bit aligned, number of samples odd 
       //               => loading one data value before entering loop,
       //                  performing one single comparison and
       //                  ((number of samples + 1) / 2) - 1
       //                  parallel comparisons within the loop body
       //                  Total comparissons for n = 9: 1+(((11/2)-1)*2)=9

       R3 = 1;
       R0 <<= 30;          
       R3 = R1 + R3;       
       CC = R0 == 0;
       IF !CC P2 = R2;       // If &input 16-bit aligned, set P2 to 0
       IF !CC P1 = R3;       // If &input 16-bit aligned, increment loop count
 
       R2 = W[P0++P2] (X);   // Load first input value
       CC = R1 == 1;
       IF CC JUMP DONE;      // Exit if number of samples == 1 

#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
       NOP;
       NOP;
       NOP;
#endif

       R3 = W[P0++] (X);     // Load second input value (&input 32-bit aligned)
                             // or reload first input value (16-bit aligned) 
       R2.H = R3.L >> 0;     // R2 set to input[0], input[1] if 32-bit aligned,
                             // or input[0], input[0] if &input 16-bit aligned   
       R0 = R2;

       // Loop for (number of samples / 2) if &input 32-bit aligned or
       //      for ((number of samples + 1) / 2) if &input 16-bit aligned
       LSETUP( ST_VMAX, ST_VMAX ) LC0 = P1 >> 1; 
ST_VMAX:  R0 = MAX( R2, R0 )(V) || R2 = [P0++]; 

       R1 = P1;              // Copy number of samples to DREG
       R2.H = R2.L >> 0;     // Ensure both 16-bit halfs of last sample
                             // read contain the same data
       CC = BITTST(R1,0);    
       IF !CC R2 = R0;      
       R0 = MAX( R2, R0 )(V);// If number of samples odd, compare
                             // result obtained in loop with last value read
 
       R1 = R0 >>> 16;       // Copy maximum value m1 to 32-bit DREG
       R2 = R0.L (X);        // Sign extend maximum value m2 to 32-bit 
       CC = R2 < R1;
       IF CC R2 = R1;        // If m1 < m2, set return value to m1

DONE:   
       R0 = R2;              // Copy return value to R0
       RTS;

.size __vecmax_fr16, .-__vecmax_fr16
