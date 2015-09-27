# c_fix_pragmas.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt transform VDSP pragmas into GCC attribute syntax.
#
#   #pragam align n
#   #pragma always_inline
#   #pragma inline
#
# are transformed.
#
#   #pragma once
#   #pragma system_header
#
# are not (intentionally).

s/^#pragam align \([0-9]*\)[ 	]*$/__attribute__ ((aligned (\1)))/
s/^#pragma always_inline[ 	]*$/__attribute__ ((always_inline))/
s/^#pragma inline[ 	]*$/__inline__/
