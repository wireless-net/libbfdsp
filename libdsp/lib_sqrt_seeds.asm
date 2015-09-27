/***************************************************************************
 *
 * lib_sqrt_seeds.asm
 *
 * Copyright (C) 2006 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 **************************************************************************/

/* Seed lookup table for the sqrtf, sqrtd, rsqrtf and rsqrtd functions */

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = math_bf.h;
.file_attr libGroup = math.h;
.file_attr libName  = libdsp;
.file_attr Content  = ConstData;

      /* Called from acosf */
.file_attr libFunc  = acosf;
.file_attr libFunc  = __acosf;
.file_attr libFunc  = acos;

      /* Called from acosd */
.file_attr libFunc  = acosd;
.file_attr libFunc  = __acosd;
.file_attr libFunc  = acosl;

      /* Called from asinf */
.file_attr libFunc  = asinf;
.file_attr libFunc  = __asinf;
.file_attr libFunc  = asin;

      /* Called from asind */
.file_attr libFunc  = asind;
.file_attr libFunc  = __asind;
.file_attr libFunc  = asinl;

      /* Called from cabsf */
.file_attr libGroup = complex_fns.h;
.file_attr libFunc  = cabsf;
.file_attr libFunc  = __cabsf;
.file_attr libFunc  = cabs;

      /* Called from cabsd */
.file_attr libFunc  = cabsd;
.file_attr libFunc  = __cabsd;

      /* cabsf is called by cartesianf */
.file_attr libFunc  = cartesianf;
.file_attr libFunc  = __cartesianf;
.file_attr libFunc  = cartesian;

      /* cabsd is called by cartesiand */
.file_attr libFunc  = cartesiand;
.file_attr libFunc  = __cartesiand;

      /* Called by gen_kaiser_fr16 */
.file_attr libGroup = window.h;
.file_attr libFunc  = gen_kaiser_fr16;
.file_attr libFunc  = __gen_kaiser_fr16;

      /* cabsf is called by normf */
.file_attr libFunc  = normf;
.file_attr libFunc  = __normf;
.file_attr libFunc  = norm;

      /* cabsf is called by normd */
.file_attr libFunc  = normd;
.file_attr libFunc  = __normd;

      /* Called from rmsf */
.file_attr libGroup = stats.h;
.file_attr libFunc  = rmsf;
.file_attr libFunc  = __rmsf;
.file_attr libFunc  = rms;

      /* Called from rmsd */
.file_attr libFunc  = rmsd;
.file_attr libFunc  = __rmsd;

      /* Called from rqrtf */
.file_attr libFunc  = rsqrtf;
.file_attr libFunc  = __rsqrtf;

      /* Called from rqrtd */
.file_attr libFunc  = rsqrtd;
.file_attr libFunc  = __rsqrtd;
.file_attr libFunc  = rsqrt;

      /* Called from sqrtf */
.file_attr libFunc  = sqrtf;
.file_attr libFunc  = __sqrtf;

      /* Called from sqrtd */
.file_attr libFunc  = sqrtd;
.file_attr libFunc  = __sqrtd;
.file_attr libFunc  = sqrtl;
.file_attr libFunc  = sqrt;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif

.section .rodata;
.global  ___SQRT_Seed_Table;

.align 1;

	.type	___SQRT_Seed_Table, @object
	.size	___SQRT_Seed_Table, 256-32
___SQRT_Seed_Table:
	.byte /*  32 - 32 */ 0xB5, 0xB2, 0xAF, 0xAD, 0xAA, 0xA8, 0xA6, 0xA3;
	.byte /*  40 - 32 */ 0xA1, 0x9F, 0x9E, 0x9C, 0x9A, 0x98, 0x96, 0x95;
	.byte /*  48 - 32 */ 0x93, 0x92, 0x90, 0x8F, 0x8E, 0x8C, 0x8B, 0x8A;
	.byte /*  56 - 32 */ 0x88, 0x87, 0x86, 0x85, 0x84, 0x83, 0x82, 0x81;
	.byte /*  64 - 32 */ 0x80, 0x7F, 0x7E, 0x7D, 0x7C, 0x7B, 0x7A, 0x79;
	.byte /*  72 - 32 */ 0x78, 0x77, 0x77, 0x76, 0x75, 0x74, 0x73, 0x73;
	.byte /*  80 - 32 */ 0x72, 0x71, 0x71, 0x70, 0x6F, 0x6F, 0x6E, 0x6D;
	.byte /*  88 - 32 */ 0x6D, 0x6C, 0x6B, 0x6B, 0x6A, 0x6A, 0x69, 0x69;
	.byte /*  96 - 32 */ 0x68, 0x67, 0x67, 0x66, 0x66, 0x65, 0x65, 0x64;
	.byte /* 104 - 32 */ 0x64, 0x63, 0x63, 0x62, 0x62, 0x62, 0x61, 0x61;
	.byte /* 112 - 32 */ 0x60, 0x60, 0x5F, 0x5F, 0x5F, 0x5E, 0x5E, 0x5D;
	.byte /* 120 - 32 */ 0x5D, 0x5D, 0x5C, 0x5C, 0x5B, 0x5B, 0x5B, 0x5A;
	.byte /* 128 - 32 */ 0x5A, 0x5A, 0x59, 0x59, 0x59, 0x58, 0x58, 0x58;
	.byte /* 136 - 32 */ 0x57, 0x57, 0x57, 0x56, 0x56, 0x56, 0x55, 0x55;
	.byte /* 144 - 32 */ 0x55, 0x55, 0x54, 0x54, 0x54, 0x53, 0x53, 0x53;
	.byte /* 152 - 32 */ 0x53, 0x52, 0x52, 0x52, 0x51, 0x51, 0x51, 0x51;
	.byte /* 160 - 32 */ 0x50, 0x50, 0x50, 0x50, 0x4F, 0x4F, 0x4F, 0x4F;
	.byte /* 168 - 32 */ 0x4F, 0x4E, 0x4E, 0x4E, 0x4E, 0x4D, 0x4D, 0x4D;
	.byte /* 176 - 32 */ 0x4D, 0x4C, 0x4C, 0x4C, 0x4C, 0x4C, 0x4B, 0x4B;
	.byte /* 184 - 32 */ 0x4B, 0x4B, 0x4B, 0x4A, 0x4A, 0x4A, 0x4A, 0x4A;
	.byte /* 192 - 32 */ 0x49, 0x49, 0x49, 0x49, 0x49, 0x48, 0x48, 0x48;
	.byte /* 200 - 32 */ 0x48, 0x48, 0x48, 0x47, 0x47, 0x47, 0x47, 0x47;
	.byte /* 208 - 32 */ 0x47, 0x46, 0x46, 0x46, 0x46, 0x46, 0x45, 0x45;
	.byte /* 216 - 32 */ 0x45, 0x45, 0x45, 0x45, 0x45, 0x44, 0x44, 0x44;
	.byte /* 224 - 32 */ 0x44, 0x44, 0x44, 0x43, 0x43, 0x43, 0x43, 0x43;
	.byte /* 232 - 32 */ 0x43, 0x43, 0x42, 0x42, 0x42, 0x42, 0x42, 0x42;
	.byte /* 240 - 32 */ 0x42, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41;
	.byte /* 248 - 32 */ 0x41, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40;

.size ___SQRT_Seed_Table, .-___SQRT_Seed_Table
