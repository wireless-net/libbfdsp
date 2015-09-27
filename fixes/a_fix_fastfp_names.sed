# a_fix_fastfp_names.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt transform VDSP float function names to libgcc ones.

s/___float32_add/___addsf3/g
s/___float32_cmp/___cmpsf2/g
s/___float32_div/___divsf3/g
s/___float32_mul/___mulsf3/g
s/___float32_sub/___subsf3/g
s/___float32_to_float64/___extendsfdf2/g
s/___float32_to_int32_round_to_zero/___fixsfsi/g
s/___float32_to_unsigned_int32/___fixunssfsi/g
s/___float64_add/___adddf3/g
s/___float64_cmp/___cmpdf2/g
s/___float64_div/___divdf3/g
s/___float64_mul/___muldf3/g
s/___float64_sub/___subdf3/g
s/___float64_to_float32/___truncdfsf2/g
s/___float64_to_int32_round_to_zero/___fixdfsi/g
s/___float64_to_int64_round_to_zero/___fixdfdi/g
s/___float64_to_unsigned_int32_round_to_zero/___fixunsdfsi/g
s/___float64_to_unsigned_int64_round_to_zero/___fixunsdfdi/g
s/___int32_to_float32/___floatsisf/g
s/___int32_to_float64/___floatsidf/g
s/___int64_to_float64/___floatdidf/g
s/___unsigned_int32_to_float32/___floatunsisf/g
s/___unsigned_int32_to_float64/___floatunsidf/g
s/___unsigned_int64_to_float64/___floatundidf/g

/^___cmpsf2:$/a\
___eqsf2:\
___gesf2:\
___gtsf2:\
___lesf2:\
___ltsf2:\
___nesf2:
/^\.size ___cmpsf2, \.-___cmpsf2$/a\
.size ___eqsf2, .-___eqsf2\
.size ___gesf2, .-___gesf2\
.size ___gtsf2, .-___gtsf2\
.size ___lesf2, .-___lesf2\
.size ___ltsf2, .-___ltsf2\
.size ___nesf2, .-___nesf2
/^\.type ___cmpsf2, STT_FUNC;$/a\
.type ___eqsf2, STT_FUNC;\
.type ___gesf2, STT_FUNC;\
.type ___gtsf2, STT_FUNC;\
.type ___lesf2, STT_FUNC;\
.type ___ltsf2, STT_FUNC;\
.type ___nesf2, STT_FUNC;
/^\.global ___cmpsf2;$/a\
.global ___eqsf2;\
.global ___gesf2;\
.global ___gtsf2;\
.global ___lesf2;\
.global ___ltsf2;\
.global ___nesf2;

/^___cmpdf2:$/a\
___eqdf2:\
___gedf2:\
___gtdf2:\
___ledf2:\
___ltdf2:\
___nedf2:
/^\.size ___cmpdf2, \.-___cmpdf2$/a\
.size ___eqdf2, .-___eqdf2\
.size ___gedf2, .-___gedf2\
.size ___gtdf2, .-___gtdf2\
.size ___ledf2, .-___ledf2\
.size ___ltdf2, .-___ltdf2\
.size ___nedf2, .-___nedf2
/^\.type ___cmpdf2, STT_FUNC;$/a\
.type ___eqdf2, STT_FUNC;\
.type ___gedf2, STT_FUNC;\
.type ___gtdf2, STT_FUNC;\
.type ___ledf2, STT_FUNC;\
.type ___ltdf2, STT_FUNC;\
.type ___nedf2, STT_FUNC;
/^\.global ___cmpdf2;$/a\
.global ___eqdf2;\
.global ___gedf2;\
.global ___gtdf2;\
.global ___ledf2;\
.global ___ltdf2;\
.global ___nedf2;

