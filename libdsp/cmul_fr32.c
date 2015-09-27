/************************************************************************
 *
 * cmul_fr32
 *
 * Copyright (C) 2006 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#include <fract_math.h>
#include <complex_typedef.h>

complex_fract32 cmul_fr32(complex_fract32 a,complex_fract32 b)
{
  complex_fract32 res;
  res.re=sub_fr1x32(mult_fr1x32x32(a.re,b.re),mult_fr1x32x32(a.im,b.im));
  res.im=add_fr1x32(mult_fr1x32x32(a.re,b.im),mult_fr1x32x32(a.im,b.re));
  return res;
}
