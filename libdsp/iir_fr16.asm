/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
*******************************************************************************

  Description :   This program implements a biquad, transposed Direct Form II,
                  IIR filter for 1.15 format data and coefficients. 
                  The coefficient buffer that is passed should be in the order
                  a2,a1,b2,b1,b0,Aa2,Aa1,Bb2,Bb1,Bb0........ . The value of
                  a0 is assumed to be one.

                  The delay line buffer must be ordered as w(n-2), w(n-1)
                  for each stage, where w(n) is the intermediate result of
                  each stage in the DF2 implementation.

                  The equation implemented is:
                     y(n) = b0 * x(n) + b1 * x(n-1) + b2 * x(n-2) 
                             - a1 * y(n-1) - a2 * y(n-2)

                  For a transposed DF2 implementation, the equation becomes:
                     W(n) =   x(n)     -  a1 * W(n-1)  -  a2 * W(n-2).
                     y(n) = b0 * W(n)  +  b1 * W(n-1)  +  b2 * W(n-2)

                  where x(n) = input samples,
                        y(n) = output samples, and
                        W(n) = intermediate result (in delay line buffer)

                  Input buffer(in), Output buffer(out), 
                  Delay line Buffer(delay) and filter coefficient buffer(h)
                  all have to be aligned to a 4 byte(word) boundary.

                  For optimium performance, the coefficient buffer must be 
                  located in a memory bank different from that in
                  which the input and the delay line buffer are initialized.


  Registers used: R0,R1, R2, R3, R6, R7

                  I0 -> Address of the input buffer x[]
                  I1 -> Address of delay line buffer d[]
                  I2 -> Address of coefficient buffer c[]
                  I3 -> Address of Output y[]

                  P0 -> No: of input samples+1 (2*outer loop counter)
                  P1 -> Number of stages (inner loop counter)
                  P2 -> General Purpose, and in the end used to point 
                                         to the stack where zero is pushed.

  Function Prototype :

                  #include <filter.h>
                  void iir_fr16(const fract16 x[],
                                      fract16 y[],
                                      int Ni,
                                      iir_state_fr16 *s);

                  where:
                      x[]  -  input array
                      y[]  -  output array
                      Ni   -  number of input samples(even)
                      s    -  pointer to filter state which is defined as:

                              typedef struct {
                                  fract16 c[];    (coefficients)
                                  fract16 d[];    (delay line buffer)
                                  int B;          (number of bi-quad stages)
                              } iir_state_fr16;


  Cycle count:   Execution time for Number of Samples= Ni and
                 Number of biquad stages = B

                 For odd number (No) of input samples :
                   Initialization      :    39 + 4 + 9 = 52
                   Kernal Cycle Count  :    3*(No-1)*B + 1.5*(No-1) + 5*B + 3

                 For even number (Ne) of input samples :
                   Initialization      :    40 + 18 = 58
                   Kernal Cycle Count  :    3*Ne*B + 1.5*Ne

  Code size :    258 bytes (IIR filter code)
                 126 bytes (IIR filter core)

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.file_attr libGroup = filter.h;
.file_attr libName = libdsp;
.file_attr prefersMem = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc  = __iir_fr16;
.file_attr libFunc  = iir_fr16;
.file_attr FuncName = __iir_fr16;
#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_SPECULATIVE_LOADS)
#define __WORKAROUND_BF532_ANOMALY_050000245
#endif

.text;
.global __iir_fr16;
.align 2;
__iir_fr16:

        [--SP] = (R7:6);            // Push R7-R6

        P0 = [SP+20];               // Address of the structure 's'
        CC = R2 < 1;                // Check if number of input samples <= 0
        IF CC JUMP _iir_LAST;

        I0 = R0;                    // Address of input sample
        I3 = R1;                    // Address to store output
        B3 = R1;                    // Set output buffer as a circular buffer
        P2 = [P0++];                // Address of coefficients
        A1 = A0 = 0 || R7 = [P0++]; // Address of delay
        P1 = [P0++];                // Number of Stages

        R1 = PACK(R2.H,R2.L) || R3.L = W[I0++];
                                    // Copy number of samples to R1
                                    // Fetch x(0) to R3
        I2 = P2;                    // Address of the coefficients

        R6 = P1;                    // R6 = Number of Stages
        CC = R6 < 1;                // Check if number of stages <= 0
        IF CC JUMP _iir_LAST;

        I1 = R7;                    // Address of the delay line buffer
        B1 = R7;                    // Set delay line as a circular buffer
        R0 = 10(Z);                 // No. of bytes of coeffs per stage = 2 * 5
        R7 = R6 << 2 || R2.H=W[I2++];
                                    // No. of bytes of delay line= 2*2*No_stages
                                    // Fetch a2 in R2.H
        L1 = R7;                    // Set the length of the delay line buffer 
                                    // to 2 * 2 * No_stages


        R7.L = R0.L * R6.L(IS);     // No. of bytes for coeff. array = 
                                    // 10 * no. of stages
        L2 = R7;                    // Set the length of the coefficient buffer 
                                    // to 2*5*No_stages

        P0 = R1;                    // Number of samples
        B2 = P2;                    // Set the coefficient buffer as a 
                                    // circular buffer

        R7 = R1 >> 1 || R0.L=W[I1++];
                                    // Fetch W(-2) into R0.L
        R7 <<=2;                    // No. of bytes for output buffer = 2*Ni
        L3 = R7;                    // Set the length of the output buffer to 2*Ni
                                    // if Ni is even else set the length to 2*(Ni-1)

        R7 = 0X7FFF;                // To make R7.H=0 and R7.L=1 in fractional domain

        CC = R1 == 1;
        IF CC JUMP _iir_SINGLESAMP;

#if defined(__WORKAROUND_CSYNC)                 || \
    defined(__WORKAROUND_SPECULATIVE_LOADS)     || \
    defined(__WORKAROUND_BF532_ANOMALY_050000245)
        NOP;
        NOP;
        NOP;
#endif

/*****************************************************************/

        R6=A0 || I3-=4 || R3.H=W[I0++];
                                    // Make R6=0,
                                    // Clear R2.L,
                                    // Make I3 point to end of output buffer,
                                    // Fetch x(1) to R3
        CC = BITTST(R1,0);          // Check even or odd
        [--SP] = R6;                // Push zero to stack
        P2 = SP;                    // Make P2 point to zero(in stack)


#if defined(__WORKAROUND_BF532_ANOMALY38__)

        /* ---------- Start of BF532 Anomaly#38 Safe Code ----------      **
        **                                                                **
        ** which implements the IIR filter for an even number of samples  **
        **                                                                **
        */

        //Loop for (number of samples)/2
        LSETUP (_iir_START_B,_iir_END_B) LC0 = P0 >> 1;
_iir_START_B:
                // A1 = x(1)*1 and A0 = x(0)*1
                // Store y(-2) and y(-1) to output buffer
                // Set R2.L to zero                
                A1 = R3.H*R7.L, A0 = R3.L*R7.L || [I3++] = R6 || R2.L = W[P2];

                // Loop for no. of biquad stages
                LSETUP (_iir_BSTART,_iir_BEND) LC1 = P1;
_iir_BSTART:
                        // A1 += b0 * Wprev(1), A0 -= a2*W(-2),
                        // Fetch W(-1) into the upper half of R0,
                        // Fetch a1 into the lower half of R2. 
                        A1+=R2.L*R0.H, A0-=R2.H*R0.L || R0.H=W[I1--];

                        // Fetch a1 into the lower half of R2.
                        R2.L = W[I2++];

                        // A1 -= a2*W(-1), W(0)=(A0-=(-1),
                        // W(0) is stored in the lower half of R0,
                        // Fetch W(-2) and W(-1) into R1. 
                        A1-=R2.H*R0.H, R0.L=(A0-=R2.L*R0.H) || R1=[I1];

                        // Fetch b2 into the upper half of R3
                        R3.H = W[I2++];

                        // A0 = b2*W(-2), 
                        // Fetch b1 into the upper half of R2
                        // Update the delay line
                        A0=R3.H*R1.L || R2.H=W[I2++] || W[I1++]=R0.L;

                        // W(1) = (A1-=a1*W(0)), A0 += b1*W(-1),
                        // Fetch b0 into the lower half of R2
                        R0.H=(A1-=R2.L*R0.L), A0+=R2.H*R0.H || R2.L=W[I2++];

                        // A1=b2*W(-1), 
                        // Update the delay line by replacing W(-2 and W(-1) 
                        // with W(0) and W(1) respectively.
                        A1=R3.H*R1.H || W[I1++]=R0.H;

                        // A1 += b1*W(0), y(0) = A0+=b0*W(0),
                        // Fetch W(-2) of next stage into R0.L 
                        A1+=R2.H*R0.L, R6.L=(A0+=R2.L*R0.L) || R0.L=W[I1++];

_iir_BEND:
                        // Fetch Aa2 into the upper half of R2
                        R2.H=W[I2++];

_iir_END_B:
                // y(0) = A1+ =b0*W(1), 
                // Fetch x(2) and x(3) to R3
                R6.H=(A1+=R2.L*R0.H) || R3 = [I0++];


#else  /* End of BF532 Anomaly#38 Safe Code */

        /* ---------- Start of NON BF532 Anomaly#38 Safe Code ---------- **
        **                                                               **
        ** which implements the IIR filter for an even number of samples **
        **                                                               **
        */

        // Loop for (number of samples)/2
        LSETUP (_iir_START_B,_iir_END_B) LC0 = P0 >> 1;
_iir_START_B:
                // A1 = x(1)*1 and A0 = x(0)*1
                // Store y(-2) and y(-1) to output buffer
                // Set R2.L to zero
                A1 = R3.H*R7.L, A0 = R3.L*R7.L || [I3++] = R6 || R2.L = W[P2];

                // Loop for no. of biquad stages
                LSETUP (_iir_BSTART,_iir_BEND) LC1 = P1;
_iir_BSTART:
                        // A1 += b0 * Wprev(1), A0 -= a2*W(-2),
                        // Fetch W(-1) into the upper half of R0,
                        // Fetch a1 into the lower half of R2
                        A1+=R2.L*R0.H, A0-=R2.H*R0.L 
                        || R0.H=W[I1--] || R2.L=W[I2++];

                        // A1 -= a2*W(-1), W(0) = (A0-=a1*W(-1)),
                        // Fetch W(-2) and W(-1) into the R1
                        // Fetch b2 into the upper half of R3
                        A1-=R2.H*R0.H, R0.L=(A0-=R2.L*R0.H) 
                        || R1=[I1] || R3.H=W[I2++];

                        // A0 = b2*W(-2)
                        // Fetch b1 into the upper half of R2
                        A0=R3.H*R1.L || R2.H=W[I2++] || W[I1++]=R0.L;

                        // W(1) = (A1-=a1*W(0)), A0 += b1*W(-1),
                        // Fetch b0 into the lower half of R2  
                        R0.H=(A1-=R2.L*R0.L), A0+=R2.H*R0.H || R2.L=W[I2++];

                        // A1 = b2*W(-1), 
                        // Update the delay line by replacing W(-2) and W(-1) 
                        // with W(0) and W(1) respectively
                        A1=R3.H*R1.H || W[I1++]=R0.H;

_iir_BEND:
                        // A1 += b1*W(0), y(0)=A0+=b0*W(0),
                        // Fetch W(-2) of next stage into R0.L,
                        // Fetch Aa2into the upper half of R2  
                        A1+=R2.H*R0.L, R6.L=(A0+=R2.L*R0.L) 
                        || R0.L=W[I1++] || R2.H=W[I2++];

_iir_END_B:
                // y(0) = A1+=b0*W(1),
                // Fetch x(2) and x(3) to R3
                R6.H=(A1+=R2.L*R0.H) || R3 = [I0++];


#if defined(__WORKAROUND_INFINITE_STALL_202)
        PREFETCH[SP];
#endif

#endif /* End of Alternative to BF532 Anomaly#38 Safe Code */

        L3 = 0;                     // Clear the circular buffering of I3
        [I3++] = R6;                // Store the last two outputs
        R6 = [SP++];                // Restore stack pointer

        IF !CC JUMP _iir_LAST;


/*****************************************************************/

_iir_SINGLESAMP:
        A0 = R3.L*R7.L;             // A0 = x(0)*1


#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
        NOP;
#endif


#if defined(__WORKAROUND_BF532_ANOMALY38__)

        /* ---------- Start of BF532 Anomaly#38 Safe Code ----------     **
        **                                                               **
        ** which handles the last sample if the number of samples is odd **
        **                                                               **
        */

        // Loop for no. of biquad stages
        LSETUP (_iir_SBSTART,_iir_SBEND) LC1 = P1;

_iir_SBSTART:
             
                // Fetch W(-1) into the upper of R0
                R0.H=W[I1--];

                // A0 -= a2*W(-2),
                // Fetch a1 into the lower half of R2 
                A0-=R2.H*R0.L || R2.L=W[I2++];

                // Fetch b2 into the upper half of R3  
                R3.H=W[I2++];
 
                // W(0) = (A0-=a1*W(-1)),
                // Fetch W(-2) into the lower half of R1 
                R0.L=(A0-=R2.L*R0.H) || R1.L=W[I1];

                // A0 = b2*W(-2), 
                // Fetch b1 into the upper half of R2,
                // Update the delay line
                A0=R3.H*R1.L || R2.H=W[I2++] || W[I1++]=R0.H;

                // A0 += b1*W(-1), 
                // Fetch b0 into the lower half of R2,
                // Update the delay line
                A0+=R2.H*R0.H || R2.L=W[I2++] || W[I1++]=R0.L;

                // Fetch a2 into the upper half of R2
                R2.H=W[I2++];

_iir_SBEND:
                // y(0) = A0+=b0*W(0), 
                // Fetch W(-2) of next stage into R0.L
                R6.L=(A0+=R2.L*R0.L) || R0.L=W[I1++];


#else  /* End of BF532 Anomaly#38 Safe Code */

        /* ---------- Start of NON BF532 Anomaly#38 Safe Code ---------- **
        **                                                               **
        ** which handles the last sample if the number of samples is odd **
        **                                                               **
        */

        // Loop for no. of biquad stages
        LSETUP (_iir_SBSTART,_iir_SBEND) LC1 = P1;

_iir_SBSTART:
                // A0 -= a2*W(-2),
                // Fetch W(-1) into the upper half of R0
                // Fetch a1 into the lower half of R2
                A0-=R2.H*R0.L || R0.H=W[I1--] || R2.L=W[I2++];

                // W(0) = (A0-=a1*W(-1)), 
                // Fetch W(-2) into the lower half of R1
                // Fetch b2 into the upper half of R3
                R0.L=(A0-=R2.L*R0.H) || R1.L=W[I1] || R3.H=W[I2++];

                // A0 = b2*W(-2),
                // Fetch b1 into the upper half of R2,
                // Update the delay line
                A0=R3.H*R1.L || R2.H=W[I2++] || W[I1++]=R0.H;

                // A0 += b1*W(-1),
                // Fetch b0 into the lower half of R2
                // Update the delay line
                A0+=R2.H*R0.H || R2.L=W[I2++] || W[I1++]=R0.L;

_iir_SBEND:
                // y(0) = A0+=b0*W(0)
                // Fetch W(-2) of next stage into R0.L
                // Fetch a2 into the upper half of R2. 
                R6.L=(A0+=R2.L*R0.L) || R0.L=W[I1++] || R2.H=W[I2++];


#endif /* End of Alternative to BF532 Anomaly#38 Safe Code */

        W[I3]=R6.L;                 // Store the last output


/*****************************************************************/

_iir_LAST:

        L1=0;                       // Clear the length registers
        L2=0;
        L3=0;

        (R7:6) = [SP++];            // Pop R7-R6
        RTS;

.size __iir_fr16, .-__iir_fr16
