/* Copyright (C) 2007 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 */
/*
** Float32 abs
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libFunc       = _abs_fl32;
.file_attr libFunc       = abs_fl32;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = _abs_fl32;

#endif

.text;
.align 2;
_abs_fl32:
	R1 = ABS R1;
	RTS;
.size _abs_fl32, .-_abs_fl32
.global _abs_fl32;
.type _abs_fl32, STT_FUNC;
