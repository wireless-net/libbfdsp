/************************************************************************
 *
 * normfl32.s
 *
 * Copyright (C) 2000-2003 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

/*
** Normalise a 32-bit float.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = _norm_fl32;
.file_attr FuncName      = _norm_fl32;

#endif

.text;

.align 2;
_norm_fl32:
   R2.L = SIGNBITS R1;
   R2 = R2.L (X);
   R1 <<= R2;
   R0 = R0 - R1;
   RTS;
.size _norm_fl32, .-_norm_fl32
.global _norm_fl32;
.type _norm_fl32, STT_FUNC;

// end of file
