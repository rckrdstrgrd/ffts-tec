#!/bin/bash
# Make sure you have NDK_ROOT defined in .bashrc or .bash_profile

#export CMAKE_BUILD_TYPE "Debug"
export CMAKE_BUILD_TYPE="Release"

#get cpu counts
case $(uname -s) in
  Darwin)
    CONFBUILD=i386-apple-darwin`uname -r`
    HOSTPLAT=darwin-x86
    CORE_COUNT=`sysctl -n hw.ncpu`
  ;;
  Linux)
    CONFBUILD=x86-unknown-linux
    HOSTPLAT=linux-`uname -m`
    CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
  ;;
CYGWIN*)
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
  *) echo $0: Unknown platform; exit
esac

if [ -z "${FFTS_SRC}" ];then
export FFTS_SRC=`pwd`
fi

BUILD_FFTS_GENERIC=1
BUILD_FFTS_VEC=0
BUILD_FFTS_NEON=0
BUILD_FFTS_CUDA=0

while [ $# -ge 1 ]; do
	case $1 in
	-acc|-ACC)
		shift
		case $1 in
		GENERIC|generic)
			BUILD_FFTS_GENERIC=1
			;;
		VEC|vec)
			BUILD_FFTS_VEC=1
			;;

		NEON|neon)
			BUILD_FFTS_NEON=1
			;;

		CUDA|cuda)
			BUILD_FFTS_CUDA=1
			;;

		*)
			BUILD_FFTS_GENERIC=1
			;;
		esac
		shift
		;;
	-clean|-c|-C) #
		echo "\$1=-c,-C,-clean"
		clean_build=1
		shift
		;;
	-l|-L)
		echo "\$1=-l,-L"
		local_build=1
		;;
	--help|-h|-H)
		# The main case statement will give a usage message.
		echo "$0 -c|-clean -abi=[armeabi, armeabi-v7a, armv8-64,mips,mips64el, x86,x86_64]"
		exit 1
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done
if [ -z "$FFTS_OUT" ]; then
	export FFTS_DIR=`pwd`
	export FFTS_OUT=${FFTS_OUT:-$FFTS_DIR/build}
fi

#check if it needs a clean build?
if [ -d "$FFTS_OUT/$TARGET_ARCH" ]; then
	if [ -n "$clean_build" ]; then
		rm -rf $FFTS_OUT/$TARGET_ARCH/*
	fi
else
	mkdir -p $FFTS_OUT/$TARGET_ARCH
fi

#export FFTS_LIB_NAME=ffts
#-DFFTS_LIB_NAME=${FFTS_LIB_NAME}

pushd ${FFTS_OUT}/$TARGET_ARCH

#-DFFTS_TRIGO_LUT=1  ==> lookup table does not make good precision
cmake -DFFTS_DIR:FILEPATH=${FFTS_DIR} -DFFTS_OUT:FILEPATH=${FFTS_OUT} \
	-DDSPCORE_OUT:FILEPATH=${DSPCORE_OUT} -DDSPCORE_DIR:FILEPATH=${DSPCORE_DIR} \
	${FFTS_DIR}

ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 cmake error!!!!"
exit -1
fi

make -j${CORE_COUNT}

ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi

popd
pushd ${FFTS_OUT}

mkdir -p libs/$TARGET_ARCH
rm -rf libs/$TARGET_ARCH/*

ln -s ${FFTS_OUT}/$TARGET_ARCH/lib/libffts.a libs/$TARGET_ARCH/

popd
exit 0
