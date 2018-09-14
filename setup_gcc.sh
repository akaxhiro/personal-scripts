#!/bin/bash

function print_usage {
echo "setup_gcc [-b][-l clag-version][-v gcc-version] [32|64]"
}

# Please debug this line.
#if [[ $0 != "\." ]]; then
#	echo "error: try . $0 $*"
#	exit 1
#fi

# POSIXLY_CORRECT=1
# TEMP=`getopt -o v: -n "setup_gcc" -- "$@"`
# unset POSIXLY_CORRECT

# default version
_VERSION=7.2
CLANG_VERSION=6.0

while true ; do
	case "$1" in
	-b)
		BE=_be; EB=eb; shift; ;;
	-l)
		case "$2" in
		3.8)
			CLANG_VERSION=$2; shift 2; ;;
		3.9)
			CLANG_VERSION=$2; shift 2; ;;
		4.0)
			CLANG_VERSION=$2; shift 2; ;;
		5.0)
			CLANG_VERSION=$2; shift 2; ;;
		6.0)
			CLANG_VERSION=$2; shift 2; ;;
		*)
			echo Clang version $2 not available
			print_usage; unset CLANG_VERSION; shift 2; ;;
		esac;;
	-v)
		case "$2" in
		4.9)
			_VERSION=$2; shift 2; ;;
		5.4)
			_VERSION=$2; shift 2; ;;
		6.3)
			_VERSION=$2; shift 2; ;;
		6.4)
			_VERSION=$2; shift 2; ;;
		7.1)
			_VERSION=$2; shift 2; ;;
		7.2)
			_VERSION=$2; shift 2; ;;
		*)
			echo Version $2 not available
			print_usage; unset _VERSION; shift 2; ;;
		esac;;
	-h)
		print_usage; unset _VERSION CLANG_VERSION; exit 1 ;;
	--)
		shift; break ;;
	*)
		break;;
	esac
done

if [[ $# == 0 || $1 == "64" ]] ; then
# by default, 64-bits
ARCH=arm64
CROSS_COMPILE=aarch64${BE}-linux-gnu-
#CS_ROOT=/opt/linaro/gcc-${_VERSION}-aarch64${BE}
CS_ROOT=/opt/gcc/gcc-${_VERSION}-aarch64

PATH=${CS_ROOT}/bin:${CS_ROOT}${BE}/bin:$PATH
MANPATH=${CS_ROOT}/share/man:$MANPATH

PS1=${_VERSION}_64${BE}-$PS1

elif [[ $1 == 32 ]] ; then
ARCH=arm
CROSS_COMPILE=arm${EB}-linux-gnueabihf-
#CS_ROOT=/opt/linaro/gcc-${_VERSION}-arm${EB}
CS_ROOT=/opt/gcc/gcc-${_VERSION}-arm

PATH=${CS_ROOT}/bin:${CS_ROOT}${BE}/bin:$PATH
MANPATH=${CS_ROOT}/share/man:$MANPATH

PS1=${_VERSION}_32${EB}-$PS1

else
	print_usage
	unset _VERSION CLANG_VERSION
	exit 1
fi

if [ "${CLANG_VERSION}" != "" ] ; then
	PATH=/opt/clang/clang-${CLANG_VERSION}/bin:$PATH
fi

# echo $ARCH
# echo $CROSS_COMPILE
# echo $CS_ROOT
# echo $PATH
# echo $MANPATH

export PATH ARCH CROSS_COMPILE MANPATH
unset _VERSION CLANG_VERSION
