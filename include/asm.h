/************************************************************************
 *
 * asm.h
 *
 * Copyright (C) 2007 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#ifndef __BFIN_ASM__
#define __BFIN_ASM__

#ifdef __FDPIC__
# define LOAD(reg, sym) reg = [P3 + sym@GOT17M4]
# define LOAD_IND(reg, sym, scratch) LOAD(scratch, sym); reg = scratch
#else
# define LOAD(reg, sym) reg.l = sym; reg.h = sym
# define LOAD_IND(reg, sym, scratch) LOAD(reg, sym)
#endif

#endif
