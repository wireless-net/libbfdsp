// Copyright (C) 2000-2003 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/**************************************************************
   Func Name:    conj_fr16

   Description:  conjungate the complex input
                    re(result) = re(a)
                    im(result) = - im(a)

**************************************************************/

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =conj_fr16")
#pragma file_attr("libFunc  =__conj_fr16")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")


#include <fract_math.h>
#include <fract_complex.h>

complex_fract16 _conj_fr16 ( complex_fract16 a )
{	
  complex_fract16 c;
  
  c.re = a.re;
  c.im = negate_fr1x16(a.im);

  return (c); 
}

/*end of file*/
