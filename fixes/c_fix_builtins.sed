# c_fix_builtins.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt transform VDSP builtin functions into GCC ones.
#
s/\<__builtin_\([_0-9a-zA-Z]*\)\>/__builtin_bfin_\1/g
