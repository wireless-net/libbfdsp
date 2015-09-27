/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : cfft2d_fr16.asm
  Include File   : filter.h
  Label name     : __cfft2d_fr16

  Description    : 2D Complex Fast Fourier Transform

                        void cfft2d_fr16 (const complex_fract16 in[], 
                                                complex_fract16 t[], 
                                                complex_fract16 out[], 
                                          const complex_fract16 w[], 
                                          int wst, 
                                          int n, 
                                          int b, 
                                          int s );

                   The input, output and temporary matrix is expected 
                   to be of size n * n. The minimum fft size supported
                   is 4 x 4. If the input data can be overwritten, the
                   input matrix can be used as the temporary matrix as 
                   well.

                   The twiddle table must contain at least n elements.
                   The twiddle stride can then be determined as:

                                  size fft twiddle table computed for
                           wst = -------------------------------------
                                  size fft to be computed
 
                   For optimium performance, the temporary matrix and
                   the twiddle table should be located in different 
                   memory banks.

  Operand        : R0 - Address of input matrix
                   R1 - Address of temporary matrix,
                   R2 - Address of output matrix,
                   [Stack 1] - Address of twiddle table
                   [Stack 2] - Twiddle Stride
                   [Stack 3] - Size fft
                   [Stack 4] - For future use (Block exponent)
                   [Stack 5] - For future use (Scaling mode)

  Registers Used : R0-7, A0-1, P0-5, I0-3, M0-2, LC0-1

  Cycle count    :                           Cycles
                    Size fft       no chaching    using data cache
                      8 x 8            2931               6384
                     16 x 16          13876              44312  
                     32 x 32                            237692  
                     64 x 64                           1309292 
                    128 x 128                         13571592 
                    256 x 256                         65098107 

                   (measured using BF537 EZ-Kit, si revision 0.0)

  Code size      : 736 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = filter.h;
.file_attr libFunc       = __cfft2d_fr16;
.file_attr libFunc       = cfft2d_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cfft2d_fr16;

#endif

.text;
.global  __cfft2d_fr16;

.align 2;
__cfft2d_fr16:

       /* Function Prologue */

       [--SP] = (R7:4, P5:3);          //Saves preserved registers
       B0 = R0;                        //Start address of input data
       B2 = R1;                        //Start address of temporary array t
       R0 = [SP+40];                   //Start address of twiddle table 
       P0 = [SP+44];                   //Twiddle stride
       P1 = [SP+48];                   //Size fft

       I0 = B0;                        //Pointer to input array
       I1 = B2;                        //Pointer to temporary array 
       B3 = R0;                        //Pointer to twiddle table

       SP += -36;
       [SP+4] = P1;                    //Preserve size fft

       R0 = P1;                        //R0 = size fft
       R4 = R0.L * R0.L (IS) || [SP+24] = R2;                   
                                       //R4 = size fft * size fft
                                       //Preserve address of output data

       P2 = R4;                        //Set P2 = (size fft * size fft)
       CC = P1 <= 3;                   //Test for size fft < 4
       If CC Jump Terminate;           //Exit if size fft < 4


       /* Populate temporary buffer */

       R5 = [I0++];                    //Load first input value
       P2 += -1;                       //Set loop couter

       R6 = R5 >>> 2 (V) || R5 = [I0++];   
                                       //Load second input value
       P3 = P1;                        //Set P3 to size fft  
       I2 = B2;                        //Set I2 to &temp. buffer

       /* Copy and scale */
       lsetup(Copy_op, Copy_op) LC0 = P2;
Copy_op: 
          R6 = R5 >>> 2 (V) || R5 = [I0++] || [I1++] = R6;
 
       [I1++] = R6;  


       /* Compute m = log(size fft) / log(2) */

       R1 = P1;                        //Set to size fft
       R2 = R1 << 1;
       M2 = R2;                        //Set M2 (=offset1+le) to 2 * size fft
       P2 = 0;                         //Zero counter 
Find_m:
       P3 = P3 >> 1;                   //Compute size fft / 2
       P2 += 1;                        //Increment counter
       CC = P3 == 2;
       If !CC Jump Find_m;             //When finished, P2 contains (m - 1)


       /* First Stage */

       R1 = R1.L * R1.L (IS) || I2 += M2;  //Set I2 (=even-odd addr. butterfly)
       R1 = R1 << 1;           
       M1 = R1;                        //Set M1 (=offset2)  
       I1 = B2;
       [SP+16] = P2;                   //Preserve P2
       I0 = B2;                        //Set I0 (=even-even address butterfly)
                                       //and works as Even-even.
       R1 = R1 + R2 (NS)  || I1 += M1; //Set I1 (=odd-even address butterfly)
       M0 = R1;
       I3 = B2;                        //Set M0 (=offset2+le)
       P3 = B3;                        //Starting address of Twiddle table
       P5 = P0 << 2;                   //wst * 4 to get correct byte in buffer
       I3 += M0;                       //Set I3 (=odd-odd address butterfly)
    
       lsetup (First_n1_strt, First_n1_end) LC0 = P1 >> 1;   //Loop for n/2
First_n1_strt:
          P4 = B3;                     //Starting address of Twiddle table
          P2 = P3;                     //P4 as k2, P3 as k1 and P2 as k1+k2
          
          lsetup (First_n2_strt, First_n2_end) LC1 = P1 >> 1;    //Loop for n/2
First_n2_strt:

             //The values of address offset1 and offset1 + le are read. 
             //The upper half stores the imaginary data, while
             //the lower half stores the real part.
             R4 = [I0];
             R5 = [I2];
             R6 = [I1];

             //The registers are added with corresponding offsets. 
             //R6 works as temp1, R7 as temp3, R2 as temp2 and R4 as temp4.
             R2 = R4 +|+ R5, R3 = R4 -|- R5 (ASR) || R7 = [I3];
             R4 = R6 +|+ R7, R5 = R6 -|- R7 (ASR);
             R6 = R2 +|+ R4, R7 = R2 -|- R4 (ASR); 
             R2 = R3 +|+ R5, R4 = R3 -|- R5 (ASR) || R1 = [P3];

             //Multiplication of R7 with w[wst*k1]. The value of 
             //temp[offset1+le] is restored. At the same time the value of 
             //w[wst*(k1+k2)] is read in R3. I2 s incremented by 1 in offset.
             A1 = R7.L * R1.H, A0 = R7.L * R1.L;  
             R7.H= (A1 += R7.H * R1.L), R7.L= (A0 -= R7.H * R1.H) || R0= [P4];
 
             //Multiplication of R2 with w[wst*k2]. The value of 
             //temp[offset1] is restored. At the same time the value of 
             //w[wst*k1] is read in R1. I0 is incremented by 1 in offset.
             A1 = R2.L * R0.H, A0 = R2.L * R0.L || I0 += 4 || [I0] = R6;
             R2.H= (A1 += R2.H * R0.L), R2.L= (A0 -= R2.H * R0.H) || R3= [P2];

             //Multiplication of R4 with w[wst*(k1+k2)]. The value of 
             //temp[offset2] is restored. After multiplication the value of
             //temp[offset2+le] is also stored back and I1 and I3 are 
             //incremented by an offset value of 4.
             A1 = R4.L * R3.H, A0 = R4.L * R3.L || [I1++] = R7;
             R4.H= (A1 += R4.H * R3.L), R4.L= (A0 -= R4.H * R3.H) || [I2++]=R2;
             I3 += 4 || [I3] = R4;
             P2 = P2 + P5;             //P2 is incremented by 2*le.
First_n2_end:  
             P4 = P4 + P5;             //P4 is incremented by 2*le.

          //The value of I0, I1, I2, I3 are modified acoording to their role.
          I0 += M2; 
          I1 += M2;
          I2 += M2;
          I3 += M2;
First_n1_end: 
          P3 = P3 + P5;


       /* Middle Stages */

       P3 = P1 >> 1;                   //Use P3 for le
       P5 = 2;                         //Use P5 for twiddle factor index
       P2 = [SP+16];                   //Set P2 to m-1.
       I1 = B2;                        //Set I1 to temporary buffer[0]
       I2 = B2;                        //Set I2 to temporary buffer[0]
       I3 = B3;                        //Set I3 to twiddle table[0]

       CC = P2 == 1;                   //Test if middle stages required
       If CC Jump Last_Stage;          //Skip middle stages if m = 2

Loop_for_m:
       P3 = P3 >> 1;
       P1 = 0;                         //Set counter for Loop_for_k1.

Loop_for_k1:
          R3 = P0;                     //R3 = wst
          R4 = P5;                     //R4 = indx
          R3 *= R4;                    //R3 = wst * indx
          R4 = P1;                     //R4 = k1
          R3 *= R4;                    //R3 = wst * indx * k1
          R3 <<= 2;                
          B0 = R3;                     //B0 stores indx * k1 * wst * 4
          P4 = 0;                      //Set counter for Loop_for_k2.

Loop_for_k2:
             R3 = P0;                              //R3 = wst
             R4 = P5;                              //R4 = indx
             M0 = B0;                              //M0 = indx * k1 * wst * 4
             I3 += M0;
             R3 *= R4;                             //R3 = wst * indx
             R5 = P4;                              //R5 = k2
             R4 = [I3];
             R3 *= R5;                             //R3 = wst * indx * k2
             R3 = R3 << 2 || [SP+20] = R4;         //R3 = wst * indx * k2 * 4
             M1 = R3;                              //M1 = indx * k2 * wst * 4

             R0 = P1;                              //n1 = k1

             I3 += M1;
             I3 -= M0 || R6 = [I3]; 
             I3 -= M1 || R5 = [I3];

             //In the above the packed operations R4 stores w[k1], R5 w[k2], 
             //and R6 w[k1+k2]. Below they are saved to free registers R4-6.
             [SP+12] = R5; 
             [SP+8]  = R6;

             lsetup(Loop_n1_strt, Loop_n1_end) LC0 = P5;
Loop_n1_strt:
                R3 = P3;                                 //le
                R3 = R3 + R0 (S) || R2 = [SP+4];         //n1+le
                                                         //Set R2 to n

                R1 = P4;                                 //n2 = k2;

                R3 *= R2;                                //R3 = (n1+le) * n
                R2 *= R0;                                //R0 = n1 * n

                [SP+28] = R3;
                [SP+32] = R2;

                lsetup(Loop_n2_strt, Loop_n2_end) LC1 = P5;
Loop_n2_strt:
                   // R0 = N1, R1 = N2
                   // R3 = [SP+28] = (n1+le) * n, R5 = [SP+32] = n1 * n

                   R2 = R3 + R1 (S) || R5 = [SP+32];     //R2 = (n1+le) * n + n2
                                                         //R5 = n1 * n
                   R2 <<= 2;                             //Left shifted to get
                                                         //correct byte
                   M1 = R2;                              //M1 = offset2

                   R3 = R5 + R1;                         //R3 = (n1 * n) + n2
                   R3 <<= 2;
                   M0 = R3;                              //M0 = offset1
                   B1 = R3;

                   R7 = P3;                              //le
                   R7 = R7 << 2 || I2 += M1;

                   R5 = R7 + R2 (S) || R6 = [I2++M0];
                   M0 = R5;                              //M0 = offset2+le

                   R3 = R7 + R3;
                   M2 = R3;                              //M2 = offset1+le


                   //R4, R5, R6 and R7 holds the value of temp[offset1], 
                   //temp[offset1+le], temp[offset2] and temp[offset2+le] 
                   //respectively. After that they are all right shifted by 2
                   //to avoid overflow. The upper 16 bits of the registers
                   //contain the imaginary part, the lower 16 bits the
                   //real part.
                   I1 += M0;
                   I2 -= M1 || R7 = [I1];
                   I1 += M2 || R4 = [I2]; 
                   I1 -= M0;
                   R5 = [I1];

                   //The registers are added with corresponding offsets. 
                   //R6 works as temp1, R7 as temp3, R2 as temp2 
                   //and R4 as temp4.
                   R2 = R4 +|+ R5, R3 = R4 -|- R5 (ASR);
                   R4 = R6 +|+ R7, R5 = R6 -|- R7 (ASR);
                   R6 = R2 +|+ R4, R7 = R2 -|- R4 (ASR);
                   R2 = R3 +|+ R5, R4 = R3 -|- R5 (ASR);
                   R3 = [SP+12];                         //R3 = w[k2]

                   //The value of R2 is multiplied with w[k2]. 
                   //The value of temp[offset1] is stored back.
                   A1 = R2.L * R3.H, A0 = R2.L * R3.L || R5 = [SP+20];    
                                                         //R3 = w[k1]  
                   [--SP] = M0;
                   M0 = B1;
                   R2.H = (A1 += R2.H * R3.L), R2.L = (A0 -= R2.H * R3.H) || 
                                I2 -= M0 || [I2] = R6;  //temp[offset1] = temp1

                   //The value of R7 is multiplied with w[k1]. 
                   //The value of temp[offset1+le] is stored back.
                   A1 = R7.L * R5.H, A0 = R7.L * R5.L || I2 += M1 || [I1] = R2; 
                   M0 = [SP++];
                   R7.H = (A1 += R7.H * R5.L), R7.L = (A0 -= R7.H * R5.H) || 
                                                                      I1 -= M2;
                   R3 = [SP+8];  //R3 = w[k1+k]

                   //The value of R4 is multiplied with w[k1+k2]. 
                   //The value of temp[offset2] is stored back.
                   //The value of temp[offset2+le] is stored back also.
                   A1 = R4.L * R3.H, A0 = R4.L * R3.L || I2 -= M1 || [I2] = R7;
                   R4.H = (A1 += R4.H * R3.L), R4.L = (A0 -= R4.H * R3.H) || 
                                                                      I2 += M0;
                   R5 = P3;
                   R5 = R5 << 1 || I2 -= M0 || [I2] = R4;  //2*le
Loop_n2_end:       R1 = R1 + R5 (S) || R3 = [SP+28];      
                                                //n2 is incremented by 2*le

Loop_n1_end:    R0 = R0 + R5;                   //n1 is incremented by 2*le

             P4 += 1;                           //counter for k2 is incremented    
             CC = P4 == P3;
             If !CC Jump Loop_for_k2 (BP);

          P1 += 1;                              //counter for k1 is incremented
          CC = P1 == P3;
          If !CC Jump Loop_for_k1 (BP);

       P5 = P5 << 1;                            //indx is multiplied by 2
       P2 += -1;                                //counter for m is decremented
       CC = P2 == 1;
       If !CC Jump Loop_for_m (BP);


       /* Last Stage */

Last_Stage: 
       P5 = P5 << 1;                   //P5 = n
       P4 = P5 << 2;                   //Multiply P5 by 8.

       //All the address registers I0. I1, I2, I3 hold the starting address of
       //the temporary buffer. I0 works as offset1, I1 as offset2, 
       //I2 as offset1+le, and I3 as offset2+le.
       I0 = B2;
       I3 = B2;
       M1 = P4;
       I1 += M1;
       I2 = I0;
       I3 = I1;

       I2 += 4;
       I3 += 4;                        //I2 and I3 are incremented by 1
       M0 = 8;                         //To increment the address offset by 2

       lsetup(Last_n1_strt, Last_n1_end) LC0 = P5 >> 1;  
Last_n1_strt:

          lsetup(Last_n2_strt, Last_n2_end) LC1 = P5 >> 1; 
Last_n2_strt:

             //R4, R5, R6 and R7 hold the values of temp[offset1], 
             //temp[offset1+le], temp[offset2], temp[offset2+le] respectively.
             //After that they are all right shifted by 2 to avoid overflow.
             //The upper 16 bits contain the imaginary part, the lower 16 bits
             //the real part.
             R4 = [I0];
             R5 = [I2];
             R6 = [I1];
  
             //The registers are added with corresponding offsets. 
             //R6 works as temp1, R7 as temp3, R2 as temp2 and R4 as temp4.
             R2 = R4 +|+ R5, R3 = R4 -|- R5 (S) || R7 = [I3];
             R4 = R6 +|+ R7, R5 = R6 -|- R7 (S);
             R6 = R2 +|+ R4, R7 = R2 -|- R4 (S);
             R2 = R3 +|+ R5, R4 = R3 -|- R5 (S) || I0 += M0 || [I0] = R6;

             I2 += M0 || [I2] = R2; 
             I1 += M0 || [I1] = R7;
Last_n2_end: 
             I3 += M0 || [I3] = R4; 

          I0 += M1;
          I1 += M1;
          I2 += M1;
Last_n1_end: 
          I3 += M1;


       /* Bit reversal */

       R7 = [SP+24];                   //Start Address of output data
       P1 = [SP+4];                    //P1 stores back the value n
       I2 = B2;
       P4 = B2;
       I3 = R7;
       P5 = R7;
       I0 = 0;
       P2 = P1 << 1;
       M1 = P2;                        //M1 is used for bit reversing   
       R0 = P1;                        //R0 = n
       R1 = 0;                         //Counter for first loop

       lsetup (Copy_row_strt, Copy_row_end) LC0 = P1;  //k1
Copy_row_strt:
          R4 = I0;         //R4 = BR[k1];
          R3 = R1 << 2 || I0 += M1 (BREV);  //I0 stores the bit reversed value
                                            //k1*4

          R2 = 0;                           //Counter for second loop
          I1 = 0;

          R3 = R3.L * R0.L (IS);
          R4 = R4.L * R0.L (IS);

          lsetup (Copy_col_strt, Copy_col_end) LC1 = P1;  //k2
Copy_col_strt:
             R6 = I1;                       //R6 = BR[k2]
             R5 = R2 << 2 || I1 += M1 (BREV);  //I1 stores the bit reverse value
                                               //k2*4
             R5 = R5 + R3;
             R6 = R6 + R4;

             P3 = R5;                       //P3 = k1*n + k2
             M0 = R6;                       //M0 = BR[k1] * n + BR[k2]

             P4 = P4 + P3;
             I2 += M0;
             P5 = P5 + P3;
             R6 = [P4];
             I3 += M0 || R7 = [I2];
             P4 -= P3;
             [P5] = R7;
             P5 -= P3;
             I2 -= M0 || [I3] = R6;
             I3 -= M0;
Copy_col_end:
             R2 += 1;

Copy_row_end:
          R1 += 1;


       /* Restoring registers */
Terminate:
       SP += 36;                            //Restore stack pointer
       (R7:4, P5:3) = [SP++];               //Restore preserved registers
       RTS;                                 //Return

.size __cfft2d_fr16, .-__cfft2d_fr16
