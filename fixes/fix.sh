#!/bin/sh

LIBBFFASTFP_ASRCS="addfl64.asm \
	cmpfl64.asm \
	divfl64.asm \
	f32tof64.asm \
	f32toi32z.asm \
	f32tou32z.asm \
	f64tof32.asm \
	f64toi32z.asm \
	f64toi64z.asm \
	f64tou32z.asm \
	f64tou64z.asm \
	fltcmp.asm \
	fltsif.asm \
	fltuif.asm \
	fpadd.asm \
	fpdiv.asm \
	fpmult.asm \
	i32tof64.asm \
	i64tof64.asm \
	mulfl64.asm \
	subfl64.asm \
	u32tof64.asm \
	u64tof64.asm"

A_FIXES="a_fix_section.sed \
	a_fix_byte_op.sed \
	a_fix_size_op.sed \
	a_fix_file_attr_op.sed \
	a_fix_fastfp_names.sed"

C_FIXES="c_fix_linkage_name.sed \
	c_fix_linkage_name2.sed \
	c_fix_pragmas.sed \
	c_fix_builtins.sed"

FIXES="fix_cvs_keywords.sed"

fixpath=`dirname $0`

fix_one_file ()
{
    echo "Fixing $1 ..."
    filename=`basename $1`
    if [[ $filename == *.c  || $filename == *.h ]]; then
	ALL_FIXES="$C_FIXES $FIXES"
    elif [[ $filename == *.asm || $filename == *.S ]]; then
	ALL_FIXES="$A_FIXES $FIXES"
    fi

    echo $LIBBFFASTFP_ASRCS | grep -q -w $filename
    if [ $? -eq 1 ]; then
	ALL_FIXES="fix_copyright_lgpl.sed $ALL_FIXES"
    else
	ALL_FIXES="fix_copyright_gpl_with_exception.sed $ALL_FIXES"
    fi

    ALL_FIXES="fix_copyright.sed $ALL_FIXES"

    grep -q Copyright $1
    if [ $? -eq 1 ]; then
	ALL_FIXES="fix_add_copyright.sed $ALL_FIXES"
    fi

    FIXCMD="cat $1"

    for fix in $ALL_FIXES
    do
	FIXCMD="$FIXCMD | sed -f $fixpath/$fix"
    done

    FIXCMD="$FIXCMD > /tmp/fix$$; mv /tmp/fix$$ $1"
    echo $FIXCMD | sh
}



if [ ! -e $1 ]; then
	echo "$1 does not exist"
	exit 1
elif [ -f $1 ]; then
	fix_one_file $1
elif [ -d $1 ]; then
	FILES=`find $1 -type f \( -name '*.h' -o -name '*.c' -o -name '*.asm' -o -name '*.S' \) | grep -v '\.svn'`
	for file in $FILES
	do
		fix_one_file $file
	done
else
	echo "$1 is not a file nor a directory"
fi

