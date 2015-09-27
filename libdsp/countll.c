// Copyright (C) 2004 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.
/******************************************************************************
  Func name   : llcountones

  Purpose     : This function is counting the number of one bits 
                in a long long integer.

  Domain      : ~ a = [LLONG_MIN ... LLONG_MAX]

******************************************************************************/

#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =llcountones")
#pragma file_attr("libFunc  =__llcountones")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <math.h>

int  _llcountones( long long  a ) 
{
  union { long b[2]; long long bb; } v;
  int  onecount;

  v.bb = a;
  onecount  = __builtin_bfin_ones((int) v.b[0]);
  onecount += __builtin_bfin_ones((int) v.b[1]);

  return  onecount;

}

/*end of file*/
