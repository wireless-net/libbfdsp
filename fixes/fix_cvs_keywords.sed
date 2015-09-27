# fix_cvs_keywords.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This script remove CVS keywords.

/^[ 	:]*\$Revision.*$/d
s/[ 	:]*\$Revision.*//
