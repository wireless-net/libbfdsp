/*************************************************************************
 *
 * vmaxlocf.c
 *
 * Copyright (C) 2000-2002 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

/*
   This function finds maximum value index from given float vector
*/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =vecmaxlocf")
#pragma file_attr("libFunc  =__vecmaxlocf") // from vector.h
#pragma file_attr("libFunc  =vecmaxloc")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <vector.h>

int vecmaxlocf(const float a[], int n)
{
   int max_loc = 0;      /* index of location of maximum no in a vector */
   float max = a[0];
   int i;

   for(i=1; i<n; i++)
   {
      if(a[i]>max)
      {
         max = a[i];
         max_loc = i;
      }
   }
   return max_loc;
}

/* end of file */
