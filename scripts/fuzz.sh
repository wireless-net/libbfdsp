#!/bin/sh
# this needs the ctags and delta packages installed

cd ${0%/*}/../include || exit 1

gccvers="4.3.3 4.1.2"

numjobs=$(getconf _NPROCESSORS_ONLN)
: ${numjobs:=1}
: $((numjobs *= 2))

cppflags="-I. -D__CYCLE_COUNT_BF_DEFINED"
cflags="-c -o /dev/null"
FLcc="bfin-uclinux-gcc"
FDcc="bfin-linux-uclibc-gcc"

rm -rf tmp
mkdir -p tmp/logs

logdir=$PWD/tmp/logs
test_idx=0
test_pids=
_test() {
	# _test(format, compiler, compiler-ver, file)
	local fmt cc file ver log out
	fmt=$1 cc=$2 ver=$3 file=$4
	log="${file}.log.${fmt}.${ver}"
	if ! out=$($cc -V $ver $cflags $cppflags "$file" 2>&1) ; then
		echo "${out}" > "${log}"
	fi
}
test() {
	test_file="$logdir"/fuzz${test_idx}.c
	log_file="${test_file}.log"
	printf "$@" > "${test_file}"
	for v in $gccvers ; do
		_test "flat" "$FLcc" "$v" "${test_file}" &
		set -- ${test_pids} $!
		_test "fdpic" "$FDcc" "$v" "${test_file}" &
		set -- ${test_pids} $!
		if [ $# -ge ${numjobs} ] ; then
			wait $1 $2
			shift 2
		fi
		test_pids="$*"
	done
	: $((test_idx += 1))
}

for h in *.h ; do
	echo "Testing $h"

	# first filter headers
	grep -v '#pragma once' $h | \
		bfin-uclinux-cpp $cppflags -E -P - | \
		topformflat | \
		sed -r \
			-e '/^[[:space:]]*$/d' \
			-e 's:[[:space:]]+: :g' \
			-e 's:^[[:space:]]*::' \
			-e 's:[[:space:]]*$::' \
			-e 's:[[:space:]]*;:;:' \
		> tmp/$h

	# test headers by themselves
	logdir=tmp/logs
	test '#include "%s"\n' $h

	cd tmp
	logdir=logs
	# test "cleaned" headers by themselves
	test '#include "%s"\n' $h

	# test funcs in each header
	grep ') {' $h | egrep -v -e 'gnu_dev_(minor|major|makedev)' | \
		sed \
			-e 's:__\(inline\|extension\)__ ::' \
			-e 's:__\(inline\|extension\) ::' \
			-e 's:__attribute__ ((always_inline)) ::' \
			-e 's:__attribute__ ((__nothrow__)) ::' \
			-e 's:^\(static\|extern\) ::' \
			-e 's:[[:space:]]*\([(),]\)[[:space:]]*: \1 :g' \
		> $h.parsed.h
	while read line ; do
		set -- $line
		ret=$1
		func=$2
		proto=$(echo "$line" | sed -e 's:^[^(]*([[:space:]]*::' -e 's:^\([^)]*\).*:\1:' -e 's:[[:space:]]*::')
#		echo "func $
#		echo "$*"
#		echo " {$ret} {$func} {$proto}"
#		echo " -> $ret $func ( ${proto} )"
		printf " -> %20s %20s ( %s )\n" "$ret" "$func" "$proto"

		set -- $proto
		decls=$(echo "$*;" | sed 's:,:;:g')
		invok=$(echo $(i=0;for x;do [ "$x" = "," ] && continue; : $((i+=1)); [ $((i%2)) -eq 0 ] && echo $x;done))
		set -- ${invok}
		invok_cnt=$#
		arg_invok=$(printf '%s,' "$@")
		arg_invok=${arg_invok%,}
#		printf "   $decls / $invok / $arg_invok / $invok_cnt\n"

		# implicit funcs by themselves (many are builtins)
		for t in "" "123" "(float)123" "(long)123" ; do
			test 'f(){%s(%s);}\n' $func "$t"
			test 'f(){return %s(%s);}\n' $func "$t"
			test 'f(){%s();return %s(%s);}\n' $func $func "$t"
			test 'f(){%s(%s);return %s();}\n' $func "$t" $func
			test 'f(){%s(%s);return %s(%s);}\n' $func "$t" $func "$t"
		done

		# again, but with header
		test '#include "%s"\nf(){%s%s(%s);}\n' $h "$decls" $func "$invok"

		# now casted to random types
		set -- $ret $(ctags -x --c-kinds=t $h | awk '{print $1}')
		set -- "$@" float double
		for t in char short int long "long long" ; do
			set -- "$@" $t "signed $t" "$unsigned $t"
		done
		for r ; do
			test '#include "%s"\n%s f(){%sreturn (%s)%s(%s);}\n' $h "$r" "$decls" "$r" $func "$arg_invok"
			test '#include "%s"\n%s f(){%s%s(%s);return (%s)%s(%s);}\n' $h "$r" "$decls" $func "$arg_invok" "$r" $func "$arg_invok"

			# try and use combination of constants/vars
			i=0
			imax=$((invok_cnt * invok_cnt))
			[ ${imax} -eq 1 ] && imax=2
			while [ ${i} -lt ${imax} ] ; do
				mix_invok=
				set -- ${invok}
				j=0
				while [ ${j} -lt ${invok_cnt} ] ; do
					if [ $((i & (1 << j))) -eq 0 ] ; then
						mix_invok="${mix_invok}, $1"
					else
						mix_invok="${mix_invok}, ($r)123"
					fi
					shift
					: $((j+=1))
				done
				mix_invok=${mix_invok#, }

#				printf "$i = $mix_invok\n"
				test '#include "%s"\n%s f(){%sreturn (%s)%s(%s);}\n' $h "$r" "$decls" "$r" $func "$mix_invok"

				: $((i+=1))
			done
		done
	done < $h.parsed.h

	cd ..
done
logdir=tmp/logs

find "${logdir}" -size 0 -print0 | xargs -0 rm -f
exit 0
