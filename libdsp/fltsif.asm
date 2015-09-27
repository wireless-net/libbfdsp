/************************************************************************
 *
 * fltsif.asm
 *
 * Copyright (C) 2000-2005 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU General
 * Public License. See the file COPYING for more details.
 *
 * In addition to the permissions in the GNU General Public License,
 * Analog Devices gives you unlimited permission to link the
 * compiled version of this file into combinations with other programs,
 * and to distribute those combinations without any restriction coming
 * from the use of this file.  (The General Public License restrictions
 * do apply in other respects; for example, they cover modification of
 * the file, and distribution when not linked into a combine
 * executable.)
 *
 * Non-GPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#if 0
   This function converts a integer to a floating point number. 

   As floating point number is represented by 23 bits of mantissa, 
   converted value is accurate only  to 23 most significant bits 
   (MSB) of the given integer number excluding sign bit. 
   if the given number is power of 2,then float value of it matches
   exactly.    
    
   Registers used  :
    R0 -         Input/output  parameter
    R1-R3, P1   
    
   The comment in fltuif.asm may help your understanding of this function

   !!NOTE- Uses non-standard clobber set in compiler:
           DefaultClobMinusPABIMandLoopRegs

   Changing this register set also affects the #pragma regs_clobbered in
   softfloat
#endif

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libGroup      = integer_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___floatsisf;
.file_attr FuncName      = ___floatsisf;

#endif

.text;

.align 2;
___floatsisf:
        R1 = R0 << 1;
        CC = AZ;                        // input either 0x0 or 0x80000000 ?
        IF CC JUMP .ret_min_or_zero;

        R2 = ABS R0;                    // Absolute of input   
        P1 = R0;                        // Save original input for later;
        R1.L = SIGNBITS R2;             // Get redundant sign bits 

                                        // Note:
                                        // anomalies 05-00-209 and 05-00-127
                                        // require the input for the sign bits 
                                        // to be created more than one instr 
                                        // earlier
        R1 = R1.L (Z);
        R2 = ASHIFT R2 BY R1.L;         // Normalize input 
        R0 = 156 (Z);                                       
        R1 = R0 - R1;                   // Compute biased exponent

        R0 += (127/*0x7F*/ - 156);      // calculate rounding bits
        R3 = R0 & R2;                   // from significand & 0x7F
        R2 += 63;                       // significand + round increment
        R2 += 1;
        R2 >>= 7;                       // shift significand to normal position
        BITTGL(R3, 6);                  // round to nearest even as follows: 
        CC = R3 == 0;                   // sig &= ~((round bits ^ 0x40)==0) 
        R3 = CC;
        R3 = ~R3;
        R2 = R2 & R3;  
        R0 = R1 << 23;                  // Shift exponent into position
        R0 = R2 + R0;   

        CC = P1 < 0;                    // Test for negative input
        IF CC JUMP .putsign;
        RTS;                            // if positive, return result 

.putsign:    
        BITSET(R0,31);                  // if negative, set sign bit 
        RTS; 

.ret_min_or_zero:
        CC = BITTST(R0,31);
        R0.H = 0xCF00;                  // Exponent and sign for min int
        IF !CC R0 = R1;                 // Input was zero 
        RTS;

.size ___floatsisf, .-___floatsisf

.global ___floatsisf;
.type ___floatsisf, STT_FUNC;

// end of file
