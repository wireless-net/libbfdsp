# a_fix_size_op.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt create .size directive from VDSP function end symbol.

s/\([ 	]*\)\.\([_a-zA-Z0-9]*\)\.end:[ 	]*$/\1.size \2, .-\2/
