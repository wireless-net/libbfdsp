/******************************************************************************
  Copyright (C) 2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
 ******************************************************************************

  Implementation : FIR based decimation filter 

  Prototype      : #include <filter.h>
                   void fir_decima_fr16 (const fract16 input[],
                                               fract16 output[], 
                                               int     length,
                                       _fir_fr16_state *filter_state);

  Description    : This function implements a finite impulse response(FIR)
                   filter defined by the coefficients and the delay line that
                   are supplied in the call of fir_decima_fr16. 

                   The function produces the filtered response of its input 
                   data and then decimates. The characteristics of the filter  
                   are dependant on the coefficient values, the number of taps 
                   and the decimation index supplied by the calling program.

                   The size of the input array is specified by the argument
                   length. The size of the output array is length / decimation
                   index. The length of the input array is expected to be a 
                   multiple of the decimation index.

                   The filter state structure is defined as:

                   typedef struct
                   {
                       fract16 *h;      // filter coefficients       //
                       fract16 *d;      // start of delay line       //
                       fract16 *p;      // read/write pointer        //
                       int k;           // number of coefficients    //
                       int l;           // decimation index          //
                   } _fir_fr16_state;

                   It is initialized using the function:
                       fir_init(state, coeffs, delay, ncoeffs, index)

                   Each filter should have its own structure, which has to 
                   be initialized before the function is called for the first 
                   time.

                   The coefficients are stored in vector `s.h`.
                   The array of coefficients is of size k.

                   The delay line is of size k too. Before the first call, all
                   elements have to be set to zero. The read/write pointer is
                   used by the function to mark the next location in the delay
                   line to which to write to. The pointer should not be
                   modified outside this function. It is needed to support
                   the restart facility, whereby the function can be called
                   repeatedly, carrying over previous input samples using the
                   delay line.                                    


                   The algorithm is based on:

                         write first input to the delay line

                         loop for number of output samples - 1
                             loop for number of coefficients - 1
                                  apply coefficients to the values in 
                                  the delay line to compute filter response

                             compute final filter response

                             loop for decimation index
                                  copy decimation index input samples to
                                  the delay line

                             write result to the output array

                         <final output sample>
                         loop for number of coefficients - 1
                             apply coefficients to the values in the
                             delay line to compute filter response

                         compute final filter response
   
                         write result to the output array

                         loop for decimation index - 1
                             copy decimation index - 1 input samples to
                             the delay line


  Cycle count    : Using the cycle accurate ADSP-BF533 simulator 
                   without any silicon revisions enabled. The
                   cycle count includes the cost of calling the 
                   function and argument passing.


                   Main loop (for decimation index > 3):
                   (num outputs - 1) * (5 + (k coeffs - 1) + decimation index)

                   Unrolled loop (decimation index > 1):
                   9 + (k coeffs - 1) + (decimation index - 1)

                   Total cycle count = 89 + Main loop + Unrolled loop


                   256 input samples, 16 coefficients, decimation index of 4:
                        1628  cycles     ( =  89 + 1512 + 27)                      


  Code size      : 200 Bytes 

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.file_attr libGroup      = filter.h;
.file_attr libFunc       = __fir_decima_fr16;
.file_attr libFunc       = fir_decima_fr16;
.file_attr libName       = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __fir_decima_fr16;
#endif


#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_SPECULATIVE_LOADS)
#define __WORKAROUND_BF532_ANOMALY_050000245
#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif


#define   OFFSET_COEFFS        0
#define   OFFSET_DELAY         4
#define   OFFSET_RESTART       8
#define   OFFSET_NUM_COEFFS   12
#define   OFFSET_DECIMATION   16

.text;
.global   __fir_decima_fr16;

.align 2;
__fir_decima_fr16:

        [--SP] = ( R7:4, P5:3 );          // Preserve reserved registers

        P2 = [SP+40];                     // Load &filter descriptor 

        P0 = R0;                          // Pointer to input buffer
        P1 = R1;                          // Pointer to output buffer

        P5 = 16;                          // Loop counter division 

        CC = R2 <= 0;                     // Test for num samples <= 0

        R3 = [P2 + OFFSET_NUM_COEFFS];    // Load num coeffs 
        R4 = [P2 + OFFSET_DECIMATION];    // Load decimation ratio 

        R0 = R3 << 1                      // Size array coeffs / array delay
        || R5 = [P2 + OFFSET_COEFFS];     // and Load &coefficients

        R6 = [P2 + OFFSET_DELAY];         // Load &delay line
        R7 = [P2 + OFFSET_RESTART];       // Load restart pointer 

        
        B0 = R5;                          // Configure array coeffs as
        I0 = R5;                          // circular buffer
        L0 = R0;

        B1 = R6;                          // Configure array delay as
        I1 = R7;                          // circular buffer
        L1 = R0;        


        IF CC JUMP _fir_decima_end;       // Exit if num samples <= 0

        CC = R4 <= 0;                     // Test for decimation ratio <= 0
        IF CC JUMP _fir_decima_end;       // Exit if decimation ratio <= 0

        CC = R3 <= 0;                     // Test for num coeffs <= 0
        IF CC JUMP _fir_decima_end;       // Exit if num coeffs <= 0


        /* Compute size output buffer
              =  num samples / decimation ratio 
        */
        DIVS( R2, R4 );
        LSETUP( _fir_decima_div, _fir_decima_div ) LC0 = P5;
_fir_decima_div:
           DIVQ( R2, R4 );

        R2 = R2.L(Z);
        R3 += -1;
        R2 += -1;  
        P5 = R2;                          // Loop counter num outputs - 1
        P3 = R3;                          // Loop counter num coeffs - 1
        P4 = R4;                          // Loop counter decimation ratio 

  
        R1 = W[P0++](Z)                   // Read input[0]
        || R0.L = W[I0--];                // and position pointer coeffs
                                          // using dummy read

        A0 = 0                            // Reset Accumulator
        || R0.L = W[I0--]                 // and load coeff[0]
        || W[I1++] = R1.L;                // and write input[0] to delay line 
              
        CC = P5 == 0;                     // Skip loop for num outputs = 1
                                          // Move test before load from delay 
                                          // line to avoid
                                          // __WORKAROUND_INFINITE_STALL_202 

        R1.L = W[I1++];                   // Load from delay line

        IF CC JUMP _fir_decima_one;


#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
        NOP;
#endif


        /* Loop for num outputs - 1 */
        LSETUP( _fir_decima_out_s, _fir_decima_out_e ) LC0 = P5;
_fir_decima_out_s:
 
           /* Loop for num coeffs */
#if defined(__WORKAROUND_BF532_ANOMALY38__)

           LSETUP( _fir_decima_coeff_s, _fir_decima_coeff_e ) LC1 = P3;
_fir_decima_coeff_s:
              A0 += R0.L * R1.L || R0.L = W[I0--];
_fir_decima_coeff_e:
              R1.L = W[I1++] ;
#else

           LSETUP( _fir_decima_coeff, _fir_decima_coeff ) LC1 = P3;
_fir_decima_coeff:
              A0 += R0.L * R1.L 
              || R0.L = W[I0--] || R1.L = W[I1++] ;

#endif  /* __WORKAROUND_BF532_ANOMALY38__ */


           R2.L = (A0 += R0.L * R1.L )
           || R1 = W[P0++](Z);            // Read next input

           /* Loop for decimation ratio  
                Fill delay line with input samples 
           */
           LSETUP( _fir_decima_fill, _fir_decima_fill ) LC1 = P4;
_fir_decima_fill:
              W[I1++] = R1.L || R1 = W[P0++](Z);

           R1.L = W[I1++]                 // Load from delay line
           || W[P1++] = R2;               // and save filtered response

_fir_decima_out_e:
           A0 = 0                         // Reset Accumulator
           || R0.L = W[I0--]              // and load coeff[0]           
           || R2 = W[P0--](Z);            // and position pointer input
                                          // using dummy read 


        /* Unroll last iteration */

_fir_decima_one:
        P4 += -1;                         // Decrement loop count decimation


#if defined(__WORKAROUND_BF532_ANOMALY38__)

        LSETUP( _fir_decima_coeff_s2, _fir_decima_coeff_e2 ) LC1 = P3;
_fir_decima_coeff_s2:
           R2.L = (A0 += R0.L * R1.L) || R0.L = W[I0--];
_fir_decima_coeff_e2:
           R1.L = W[I1++] ;
#else

        /* Loop for num coeffs */
        LSETUP( _fir_decima_coeff_2, _fir_decima_coeff_2 ) LC1 = P3;
_fir_decima_coeff_2:
           R2.L = (A0 += R0.L * R1.L )
           || R0.L = W[I0--] || R1.L = W[I1++] ;

#endif  /* __WORKAROUND_BF532_ANOMALY38__ */


        R2.L = (A0 += R0.L * R1.L )
        || R1 = W[P0++](Z);              // Read next input

        W[P1++] = R2;                    // Save filtered response        

        CC = P4 == 0;                    // Do not modify delay line for
        IF CC JUMP _fir_decima_update;   // a decimation ratio of one 


#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
        NOP;
        NOP;
#endif

        /* Loop for decimation ratio - 1
             Fill delay line with input samples
        */
        LSETUP( _fir_decima_fill_2, _fir_decima_fill_2 ) LC1 = P4;
_fir_decima_fill_2:
           W[I1++] = R1.L || R1 = W[P0++](Z);


_fir_decima_update:

        /* Update filter descriptor */
        R2 = I1;

        [P2 + OFFSET_RESTART] = R2;       // Save restart pointer
                            

_fir_decima_end:  
        (R7:4, P5:3) = [SP++];            // Restore reserved registers

        L0 = 0;                           // Reset circular buffers
        L1 = 0;

        RTS;

.size __fir_decima_fr16, .-__fir_decima_fr16
