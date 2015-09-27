# fix_copyright.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This script fixes misc wording on Copyright.

s/([cC])[ 	]*Copyright/Copyright (C)/

s/Copyright[ 	]*([cC])/Copyright (C)/

/^[ 	*/]*[Aa]ll [Rr]ights [Rr]eserved[. 	*/]*$/d

s/[ 	]*[Aa]ll [Rr]ights [Rr]eserved[. 	]*//

s/Analog Devices /Analog Devices, /

s/Inc$/Inc./

s/Inc\.,$/Inc./

/Development IP/d
/Collaboration Agreement/d

/Spectrum/,/spectrumsignal/d

s/[ 	]*IPDC BANGALORE, India\.[ 	]*//

