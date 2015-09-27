/*****************************************************************************
  Copyright (C) 2000-2004 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : histogram_fr16.asm
  Include File   : stats.h
  Label Name     :  __histogram_fr16

  Description    : The function counts the number of input samples that fall
                   into each of the output bins.
                   The size of the output vector is equal to the number of 
                   bins.

                   The function uses the stack as temporary output array
                   (size = number of bins + 2).

  Operands       : R0 - Address of input array A, 
                   R1 - Address of output array C,
                   R2 - Maximum value
                   Stack - Minimum value
                   Stack - Number of input samples
                   Stack - Number of bins

  Registers Used : R0-7, I1, I3, P0-3

  Cycle count    : 2576 Cycles (all input samples evenly 
                                distributed accross all bins)

                   1008 Cycles (all input samples located in bin 0)
                   4144 Cycles (all input samples located in bin max)

                   n = 32, bin = 8 (BF532, Cycle Accurate Simulator)
  Code Size      : 144 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = stats.h;
.file_attr libName = libdsp;
.file_attr prefersMem = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc  = histogram_fr16;
.file_attr libFunc  = __histogram_fr16;
.file_attr FuncName = __histogram_fr16;

#endif

.text;
.global   __histogram_fr16;

.extern ____udiv32;

.align 2;
__histogram_fr16:
                   [--SP] = (R7:4);        // PUSH R7-R4, P3, RETS ONTO STACK
                   [--SP] = P3;
                   [--SP] = RETS;
                   R7 = [SP+36];           // MINIMUM VALUE FOR BINS
                   P3 = [SP+40];           // NUMBER OF INPUT SAMPLES
                   R5 = [SP+44];           // NUMBER OF BINS
                   R4 = R0;                // ADDRESS INPUT ARRAY
                   R6 = R1;                // ADDRESS OUTPUT ARRAY


                 // ERROR HANDLING  

                   CC = P3 <= 0;           // CHECK IF INPUT SAMPLES IS ZERO
                   IF CC JUMP HISTO_RETURN;// IF TRUE, BRANCH TO RET_ZERO

                   CC = R5 <= 0;           // CHECK IF BIN VALUE IS ZERO 
                   IF CC JUMP HISTO_RETURN;// IF TRUE, BRANCH TO ZERO

                   CC = R2 <= R7;          // CHECK IF MAXIMUM < MINIMUM 
                   IF CC JUMP HISTO_RETURN;// IF TRUE, BRANCH TO RET_ZERO


                 // BIN SIZE = (MAX. BIN - MIN. BIN) / NUMBER OF BINS 

                   R0 = R2 - R7 (NS);      // RANGE = MAX. BIN - MIN. BIN
                   R1 = R5;                // NUMBER OF BINS
                   CALL.X ____udiv32;      // SIZE/BIN = RANGE/NUMBER OF BINS

                   CC = R0 == 0;           // CHECK IF SIZE/BIN == 0 
                   IF CC JUMP HISTO_RETURN;// IF TRUE, BRANCH TO RET_ZERO


                 // ALLOCATE SPACE ON THE STACK FOR TEMPORARY ARRAY 

                   R2 = R5;                // NUMBER OF BINS
                   R2 += 2;                // NUMBER OF BINS + 2 BINS
                                           // TO LOG OUT-OF-RANGE

                   P2 = R2;                // LOOP COUNTER INIT TEMPORARY
                   R2 = -R2;
                   P1 = R2;                // STACK GROWS DOWN 

                   P0 = SP;
                   P0 = P0 + (P1 << 2);   
                   SP = P0;                // ALLOCATE SPACE ON THE STACK
                                           // FOR TEMPORARY ARRAY              
                   I1 = P0;                // ADDRESS TEMPORARY ARRAY
                   I3 = P0;

      
                 // COMPLETE SET-UP

                   R1 = 0;
                   P1 = R4;                // ADDRESS INPUT ARRAY

                 
                 // INITIALISE TEMP ARRAY TO ZERO

                   // LOOP FOR NUMBER OF BINS
                   LSETUP( INIT, INIT ) LC0 = P2;
INIT:                [I1++] = R1;          
                   

                 // COMPUTE HISTOGRAM 

                   I3 -= 4;                // CORRECTION OR I1 OFF BY 4
                   R2 = -32768;            // MIN(FRACT16) = 0x8000

                   // LOOP FOR NUMBER OF SAMPLES
                   LSETUP( HISTO_START, HISTO_END ) LC0 = P3;
HISTO_START:         R1 = W[P1++](X);      // GET INPUT VALUE                     
                     I1 = I3;              // ADDRESS OUTPUT ARRAY
                     R3 = R7.L(X);         // MINIMUM VALUE OF BIN
                     R4 = P2;

ITERATE_BINS:        R4 += -1;             
                     CC = R4 == 0;         // CHECK FOR MAX BIN REACHED
                     IF CC R1 = R2;        // WILL FORCE SUBSEQUENT CC TO TRUE                     

                     CC = R1 < R3;         // CHECK IF INPUT VALUE < MAXIMUM    
                                           // VALUE OF CURRENT BIN
                     R3 = R3 + R0(NS) || I1 += 4;
                                           // INCREASE MIN VALUE TO NEXT BIN
                                           // AND SET POINTER TO CURRENT BIN
                     IF !CC JUMP ITERATE_BINS; 
                                           // IF RIGHT BIN NOT FOUND CONTINUE

#if defined(__WORKAROUND_CSYNC) || defined(__WORKAROUND_SPECULATIVE_LOADS)
                     NOP;
                     NOP;
                     NOP;
#endif

                     R4 = [I1];            // GET THE PREVIOUS COUNT
                     R4 += 1;              // INCREMENT THE COUNT
HISTO_END:           [I1] = R4;            // STORE INCREMENTED VALUE BACK


                 // COPY RESULT TO OUTPUT ARRAY

                   P2 = R5;                // SET LOOP COUNTER=NUMBER OF BINS
                   I3 += 4;                // REVERSE CORRECTION
                   P0 = R6;                // ADDRESS OUTPUT ARRAY 
                   R0 = [I3++];            // COUNT BELOW MINIMUM

                   // LOOP FOR NUMBER OF BINS 
                   LSETUP( START_COPY, END_COPY ) LC0 = P2;
START_COPY:          R4 = [I3++];          // MOVE RESULT FROM STACK 
END_COPY:            [P0++] = R4;          // TO THE OUTPUT ARRAY

                   R4 = [I3++];            // COUNT BEYOND MAXIMIUM
                   R0 = R0 + R4;


                   SP = I3;                // PUSH TEMP ARRAY OFF THE STACK
                   
HISTO_RETURN:      RETS = [SP++];          // POP RETS, P3, R7-R4 FROM STACK
                   P3 = [SP++];
                   (R7:4) = [SP++];        
                   RTS;

.size __histogram_fr16, .-__histogram_fr16
