/* Copyright (C) 2007 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 */
/*
** Float32 negate
*/
#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = floating_point_support;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr libFunc = _negate_fl32;
.file_attr FuncName      = _negate_fl32;

#endif

.text;
.align 2;
_negate_fl32:
	R1 = -R1;
	RTS;
.size _negate_fl32, .-_negate_fl32
.global _negate_fl32;
.type _negate_fl32, STT_FUNC;
