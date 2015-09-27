/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
 ******************************************************************************
  File name       :  vecsdot.asm 
 
  Purpose         :  Real vector dot product for int data types.

  Description     :  This function multiplies each element of
                     input vector `a[]` to each element 
                     of input vector `b[]` and returns the sum.
                 
  Registers used  :  Operands in  R0 & R1
                     R0 - Index to vector A
                     R1 - Index to vector B
                     R2 - No of elements 
                     R3,I0,I1,P2,A0,A1

  Notes           :  Input vectors should be aligned on a 4-byte address
                     boundary and be allocated in different banks to achieve 
                     the cycle count given below.

  Cycle Count     :  33 + N/2 where N is the number of elements

**************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.file_attr libGroup      = vector.h;
.file_attr libFunc       = vecdot_fr16;
.file_attr libFunc       = __vecdot_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __vecdot_fr16;
#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif

.text;
.global __vecdot_fr16;
.align 2;

__vecdot_fr16:

            I0 = R0;                  // ADDRESS OF INPUT COMPLEX VECTOR1
            CC = R2 <= 0;             // CHECKS IF NO OF ELEMNETS IS ZERO
            IF CC JUMP RETURN_ZERO;   // IF TRUE THEN RETURN ZERO AND EXIT

            I1 = R1;                  // ADDRESS OF INPUT COMPLEX VECTOR2
            P2 = R2;                  // SET LOOP COUNTER
            CC = R2 == 1;                       
            IF CC JUMP SINGLE;        // IF N == 1, JUMP

            R1 = R0 | R1;             // CHECK THAT INPUT VECTORS ARE 
                                      // 32-BIT ALIGNED
            R3 = 3;
            R3 = R1 & R3;
            CC = R3 == 0;
            IF !CC JUMP NOT_ALIGNED;

#if defined(__WORKAROUND_CSYNC) || defined(__WORKAROUND_SPECULATIVE_LOADS)
            NOP;
            NOP;
            NOP;
#endif

#if defined(__WORKAROUND_BF532_ANOMALY38__)

        /* Start of BF532 Anomaly#38 Safe Code */
        
            A1 = A0 = 0 || R1 = [I0++];
            R3 = [I1++];  

            LSETUP(ST_VECDOT,END_VECDOT) LC0 = P2 >> 1;
               // DO MULTIPLICATION OF TWO ELEMENTS, FETCH NEXT ELEMENTS
ST_VECDOT:     R0.L=(A0+=R1.L*R3.L) , R0.H=(A1+=R1.H*R3.H) || R1 = [I0++];
END_VECDOT:    R3 = [I1++];

#else  /* End of BF532 Anomaly#38 Safe Code */

            A1 = A0 = 0 || R1 = [I0++] || R3 = [I1++];  

            LSETUP(ST_VECDOT,ST_VECDOT) LC0 = P2 >> 1;
               // DO MULTIPLICATION OF TWO ELEMENTS, FETCH NEXT ELEMENTS
ST_VECDOT:     R0.L=(A0+=R1.L*R3.L) , R0.H=(A1+=R1.H*R3.H) || 
                                             R1 = [I0++] || R3 = [I1++];

#if defined(__WORKAROUND_INFINITE_STALL_202)
            PREFETCH[SP];
            PREFETCH[SP];
#endif

#endif /* End of Alternative to BF532 Anomaly#38 Safe Code */

            CC = BITTST(R2,0);
            R2 = 0;
            IF !CC R1 = R2;           // IF N IS EVEN, R1 = 0
            R0.L=(A0+=R1.L*R3.L);     // ADD PRODUCT OF LAST ELEMENTS IF N IS 
                                      // ODD, ELSE ADD ZERO
            R0.L = R0.L + R0.H(S);    // ADD THE RESULT COMPUTED IN TWO MACs

RETURN:
            R0 = R0.L(X);             // SIGN EXTEND RESULT
            RTS;


NOT_ALIGNED:
SINGLE:
#if defined(__WORKAROUND_BF532_ANOMALY38__)

        /* Start of BF532 Anomaly#38 Safe Code when data is not optimally aligned */
        
            A0 = 0 || R1.L = W[I0++];
            R3.L = W[I1++];
            
            LSETUP(ST_VECDOT2,END_VECDOT2) LC0 = P2;
ST_VECDOT2:    A0 += R1.L*R3.L || R1.L = W[I0++];
END_VECDOT2:   R3.L = W[I1++];           

            R0.L = A0;
            JUMP RETURN;
                    
#else   /* End of BF532 Anomaly#38 Safe Code when data is not optimally aligned */
        
            A0 = 0 || R1.L = W[I0++] || R3.L = W[I1++];
            LSETUP(ST_VECDOT2,ST_VECDOT2) LC0 = P2;
ST_VECDOT2:    A0 += R1.L*R3.L || R1.L = W[I0++] || R3.L = W[I1++];           

#if defined(__WORKAROUND_INFINITE_STALL_202)
            PREFETCH[SP];
            PREFETCH[SP];
#endif  /* __WORKAROUND_INFINITE_STALL_202 */

            R0.L = A0;
            JUMP RETURN;

#endif /* End of Alternative to BF532 Anomaly#38 Safe Code when data is not optimally aligned */

RETURN_ZERO:   
            R0 = 0;
            RTS;
            
.size __vecdot_fr16, .-__vecdot_fr16
