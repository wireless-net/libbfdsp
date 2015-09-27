/*
** Copyright (C) 2003-2006 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU General
** Public License. See the file COPYING for more details.
**
** In addition to the permissions in the GNU General Public License,
** Analog Devices gives you unlimited permission to link the
** compiled version of this file into combinations with other programs,
** and to distribute those combinations without any restriction coming
** from the use of this file.  (The General Public License restrictions
** do apply in other respects; for example, they cover modification of
** the file, and distribution when not linked into a combine
** executable.)
**
** Non-GPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
**
** 64-bit IEEE floating-point subtraction.
**
** This function implements subtraction for the long double type.
** long double __float64_sub(long double X, long double Y);
** X is passed in R1:0, Y is passed in R2 and on the stack.
** The result is returned in R1:0.
**
** !!NOTE- Uses non-standard clobber set in compiler:
**         DefaultClobMinusLoopRegs
**
** Changing this register set also affects the #pragma regs_clobbered in
** softfloat
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libf64ieee;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = ___subdf3;
.file_attr FuncName      = ___subdf3;

#endif

.text;
.align 2;

___subdf3:
	R3 = [SP+12];
	BITTGL(R3, 31);
	JUMP.X ___adddf3_inregs;
.size ___subdf3, .-___subdf3

.global ___subdf3;
.type ___subdf3, STT_FUNC;
.extern ___adddf3_inregs;
.type ___adddf3_inregs, STT_FUNC;
