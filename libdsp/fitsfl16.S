/*
** Whether a float will fit into a float16 without losing precision.
** Copyright (C) 2003 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = float16.h;
.file_attr libFunc       = _fits_in_fl16;
.file_attr libFunc       = fits_in_fl16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = _fits_in_fl16;

#endif

.text;
.align 2;
_fits_in_fl16:
	R1 = R0.B (X);
	R0 = 0;
	CC = R1 == 0;
	R0 = ROT R0 BY 1;
	RTS;
.size _fits_in_fl16, .-_fits_in_fl16
.global _fits_in_fl16;
.type _fits_in_fl16, STT_FUNC;
