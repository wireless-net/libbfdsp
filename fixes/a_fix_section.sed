# a_fix_section.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt transform VDSP section names into GAS ones

s/\.[Ss][Ee][Cc][Tt][Ii][Oo][Nn][ 	]*program;/.text;/
s/\.[Ss][Ee][Cc][Tt][Ii][Oo][Nn]\/DOUBLEANY[ 	]*program;/.text;/
s/\.[Ss][Ee][Cc][Tt][Ii][Oo][Nn][ 	]*data1;/.data;/
s/\.[Ss][Ee][Cc][Tt][Ii][Oo][Nn]\/DOUBLEANY[ 	]*data1;/.data;/
s/\.[Ss][Ee][Cc][Tt][Ii][Oo][Nn][ 	]*constdata;/.section .rodata;/
s/\.[Ss][Ee][Cc][Tt][Ii][Oo][Nn]\/DOUBLEANY[ 	]*constdata;/.section .rodata;/
