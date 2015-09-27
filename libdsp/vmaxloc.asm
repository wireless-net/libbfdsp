/******************************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : vmaxloc.asm
  Include File   : vector.h
  Label name     : __vecmaxloc_fr16

  Description    : This function returns the index of 
                   the largest array value

                   For best performance, the input vector should be
                   32-bit aligned.

                   If the number of samples is 0, the return value
                   is set to zero.

  Operand        : R0 - Address of input array X,
                   R1 - Number of samples

  Registers Used : R0-4, P0-1

  Cycle count    : n = 24: 57 Cycles  (BF532, Cycle Accurate Simulator)

  Code size      : 118 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = vector.h;
.file_attr libFunc       = vecmaxloc_fr16;
.file_attr libFunc       = __vecmaxloc_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __vecmaxloc_fr16;

#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_SPECULATIVE_LOADS)
#define __WORKAROUND_BF532_ANOMALY_050000245
#endif

.text;
.global __vecmaxloc_fr16;

.align 2;
__vecmaxloc_fr16:


#if defined(__WORKAROUND_WB_DCACHE)
       SSYNC;
#endif

       [--SP] = R4;          // Preserve reserved register

       R2 = 0;               // Set return value for number of samples <= 1
       CC = R1 <= 1;
       IF CC JUMP DONE;      // Exit if number of samples <= 1

       P0 = R0;              // P0 = Address of X[0]
       R4 = R0;              // Preserve the starting address of input array X
       P1 = R1;              // P1 = Loop counter (preset to number of samples)

       R0 <<= 30;            // Test for alignment
       R1 = W[P0++] (X);     // Load first input value

       // At this point:
       //    - R1 must contain X[0]
       //    - R2 must be zero
       //    - P1 must be set to number of samples
       CC = R0 == 0;
       IF !CC JUMP SEARCH16; // Execute alternative algorithm for input vector
                             // with 16-bit alignment

#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
       NOP;
       NOP;
       NOP;
#endif

       A0 = R1 || R1 = W[P0--] (X);  
                             // Load second input value
       A1 = R1 || R1 = [P0++];

       R2 = P0;              // Store location of data values read
       R3 = P0;            
       [--SP] = R1;          // Preserve first search value


       // Loop for (number of samples / 2) 
       LSETUP( ST_VMAXLOC, ST_VMAXLOC ) LC0 = P1 >> 1; 
ST_VMAXLOC:  (R2, R3) = SEARCH R1 (GT) || R1 = [P0++]; 

       R0 = P1;              // Copy number of samples to DREG
       CC = BITTST(R0,0);
       R0 = [SP++];          // Load first input again
       IF !CC R1 = R0;       // If number of samples even, 
                             // search for first sample again (==NOP)

       R1.H = 0x8000;        // Ensure that last element read is ignored

       (R2, R3) = SEARCH R1 (GT);   // Perform last search OP (odd case)


       CC = A0 < A1;
       R2 += -2;             // Adjust pointer, rewind by one word
       R3 += -4;             // Adjust pointer, rewind by two words 
       IF !CC R2 = R3;       // Set return value to address of largest input

       R2 = R2 - R4;         // Compute &x[0] - &x[largest element]

DONE:   
       R0 = R2 >> 1;         // Complete index conversion

DONE16:
       R4 = [SP++];          // Restore preserved registers 

       RTS;


SEARCH16:
       // The SEARCH() instruction relies on 32-bit alignment of the input 
       // data. This is an alternative code that does not have the alignment 
       // requirement

       // R1 = largest value in array (pre-set to X[0])
       // R0 = index largest value 
       // R2 = current index (pre-set to zero)
       // R3 = current input value X[i]
       // R4 = 1 (constant) 
       // P1 = number of samples - 1

       P1 += -1;
       R4 = 1;
       R0 = 0;

       // Loop for number of samples
       //    Increment current index, load X[i]
       //    GT comparison X[largest] and X[i]
       //    Update X[largest] 
       //    Update index largest value
       LSETUP( ST_VMAXLOC_16, END_VMAXLOC_16 ) LC0 = P1;
ST_VMAXLOC_16:    R2 = R2 + R4 (S) || R3 = W[P0++] (X);  
                  CC = R1 < R3;
                  R1 = MAX( R1, R3 );
END_VMAXLOC_16:   IF CC R0 = R2;

       JUMP DONE16;


.size __vecmaxloc_fr16, .-__vecmaxloc_fr16
