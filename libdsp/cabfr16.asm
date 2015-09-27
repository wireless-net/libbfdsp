/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : cabfr16.asm
  Module Name    : complex absolute fraction
  Label name     :  __cabs_fr16
  Description    : This function computes the absolute value 
                   of a complex fractional  number:
                   |a| =  sqrt( a.real^2 + a.imag^2 )
  Operand        : R0  =  (R0.L=Real number, R0.H=Imaginary number)
  Registers Used : R0-3, R7
  Cycle count    : 28 .. 138 cycles depending on the input value
  Code Size      : 108 bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = complex_fns.h;
.file_attr libFunc       = __cabs_fr16;
.file_attr libFunc       = cabs_fr16;
/* Called by cartesian_fr16 */
.file_attr libFunc       = cartesian_fr16;
.file_attr libFunc       = __cartesian_fr16;

.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cabs_fr16;

#endif

.text;
.global    __cabs_fr16;
.align 2;  

__cabs_fr16:
             R0=ABS R0 (V);           // GET ABSOLUTE OF REAL, IMAGINARY
             R1=R0.L (Z);             // EXTRACT REAL 
             R2=R0>>16;               // EXTRACT IMAGINARY  

             CC= R1==0;               // CHECK IF REAL == 0
             IF CC JUMP RET_IMG;      // IF TRUE, RETURN ABS(IMAGINARY)  

             CC= R2==0;               // CHECK IF IMAGINARY == 0
             IF CC JUMP RET_REAL;     // IF TRUE, RETURN ABS(REAL)
         
             CC=R1==R2;               // CHECK IF REAL == IMAGINARY
             IF CC JUMP RE_EQ_IMG;    // BRANCH TO RE_EQ_IMG 

             [--SP] = R7;             // PUSH R7 ON STACK  
             CC=R1<R2;                // CHECK IF IMAGINARY > REAL
             IF !CC JUMP RE_GT_IMG;   // IF FALSE, BRANCH TO RE_GT_IMG 

             R0=R1;                   // LOAD R0 WITH REAL
             R1=R2;                   // LOAD R1 WITH IMAGINARY
             JUMP RE_LT_IMG;            

RE_GT_IMG:   R0=R2;                   // ALGORITHM USED: 
                                      // Z = Y * 2 * 
                                      //     SQRT( (1/4) + 
                                      //           ((REAL*REAL)/(IMAG*IMAG))/4) 
RE_LT_IMG:   R7=R1;                   // SAVE VALUE OF R1
             [--SP]=RETS;             // PUSH  RETS AND R1 STACK   
             CALL.X __div16;          // CALL DIV16 FUNCTION  
                                      // 16 BIT FRACTIONAL FOR DIVISION  
               
             R2=R0.L*R0.L;            // SQUARE THE RESULT 
             R2>>=0x12;               // RESULT IS STORED IN 16 BIT. 
                                      // SHIFTED RIGHT BY 2 TO DIVIDE BY 4 
             R3=0x2000;               // CONSTANT VALUE 1/4 IS STORED IN R3 
             R0=R3+R2;
             CALL.X __sqrt_fr16;      // CALL SQRT FUNCTION  

             RETS=[SP++];             // POP RETS FROM STACK
             R0=R7.L*R0.L;            
             R0>>= 0x0f;              // COMBINED ROUNDING AND MULTIPLY BY 2

             R3=0x7fff;
             CC=BITTST(R0,0x0f);      // CHECK FOR SATURATION
             IF CC R0=R3;             // RETURN SATURATED RESULT    

             R7=[SP++];               // POP R7 FROM STACK
             RTS;

RET_IMG:     R0=R2;                   // RETURN IMAGINARY 
             RTS;

RET_REAL:    R0=R1;                   // RETURN  REAL
             RTS;

RE_EQ_IMG:   R2=0x5a82;               // CONSTANT VALUE =0.707
             R0=0x7fff;
             CC=R2<=R1;               // If REAL >= 0.707 ==> OVERFLOW
             IF CC JUMP RE_EQ_IMG_EXIT;

             R0.L=R2.L*R1.l;          // RESULT=1.414 * REAL 
             R0<<=1;                  // MULTIPLY BY 2

RE_EQ_IMG_EXIT:
             RTS;

.size __cabs_fr16, .-__cabs_fr16

.extern __div16;
.extern __sqrt_fr16;

