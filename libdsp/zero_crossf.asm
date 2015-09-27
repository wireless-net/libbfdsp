/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
*******************************************************************************
  File Name      : zero_crossf.asm
  Include File   : stats.h
  Label name     : __zero_crossf

  Description    : 

                   int zero_crossf (const float _samples[], 
                                    int _sample_length);

                   Counting the number of times the signal
                   contained in x[] crosses the zero line.

                   If the number of samples is less than two, zero is returned
                   If all input values are +/- zero, zero is returned

                   The function treats +/- Inf and +/-NaN like any other
                   number. Thus if x[i] = +Inf and x[i+1] = negative value, 
                   then a zero_crossing is counted.

  Operand        : R0 - Address of input array a[],
                   R1 - Number of samples

  Registers Used : R0-4, P1-3

  Cycle count    : n = 24, first value in array zero: 202 Cycles
                   (BF532, Cycle Accurate Simulator) 

                   26 + 15*nz + 7*nr 

                   where:
                     nz = Number of leading zeros in array
                     nr = Number of samples - nz
   
  Code size      : 76 Bytes 
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = stats.h;
.file_attr libFunc       = zero_crossf;
.file_attr libFunc       = __zero_crossf;
.file_attr libFunc       = zero_cross;   // from stats.h
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __zero_crossf;

#endif

.text;
.global   __zero_crossf;

.align 2;
__zero_crossf:     
   P1 = R0;                // Pointer to input array
   R0 = 0;                 // Reset result to 0 
   CC = R1 < 2;            // Terminate if number of samples < 2
   IF CC JUMP RET_ZERO;

   R1 += -1;
   P2 = R1;                // Number of samples to loop over

   R3 = [P1++];            // Read input 
   LSETUP (l1start,l1end) LC0=P2;
l1start:  R2 = R3 << 1;           // Remove sign
          CC = R2 == 0;           // Loop until first non-zero value  
          IF !CC JUMP skipped_zeros;
l1end:    R3 = [P1++];            // Read input
   RTS;                    // inputs all zeros, return

skipped_zeros:
   [--SP] = R4;            // Push R4 onto stack
                           // R3 is now non-zero
   R1 = R3 >> 31 || R4 = [P1++];          
                           // Remove mantissa and exponent
                           // and Read next input
   LSETUP (ST_LOOP,END_LOOP) LC0;
ST_LOOP:  R3 = R4 << 1;         // Remove sign
          R2 = R4 >> 31 || R4 = [P1++];
                                // Remove mantissa and exponent
                                // and read next input
          CC = R3 == 0;         // For zero-value data
          IF CC R2 = R1;        // force signs to be equal

          R3 = R1 ^ R2;         // R3 = 1 if signs differ 
          R0 = R0 + R3;         // Increment counter if signs differ

END_LOOP: R1 = R2;              // Copy new sign to old sign
          
   R4 = [SP++];            // Pop R4 from stack
RET_ZERO: 
   RTS;

.size __zero_crossf, .-__zero_crossf

