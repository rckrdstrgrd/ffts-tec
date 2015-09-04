#!/bin/bash
# Compiles ffts for Android
# Make sure shell ENV NDK_ROOT defined
# 'armeabi' ABI corresponds to an ARMv5TE based CPU with software floating point operations.
#APP_ABI = all armeabi armeabi-v7a arm64-v8a x86 x86_64 mips mips64
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

#INSTALL_DIR="`pwd`/java/android/bin"

# Modify INSTALL_DIR to suit your situation
#Lollipop	5.0 - 5.1	API level 21, 22
#KitKat	4.4 - 4.4.4	API level 19
#Jelly Bean	4.3.x	API level 18
#Jelly Bean	4.2.x	API level 17
#Jelly Bean	4.1.x	API level 16
#Ice Cream Sandwich	4.0.3 - 4.0.4	API level 15, NDK 8
#Ice Cream Sandwich	4.0.1 - 4.0.2	API level 14, NDK 7
#Honeycomb	3.2.x	API level 13
#Honeycomb	3.1	API level 12, NDK 6
#Honeycomb	3.0	API level 11
#Gingerbread	2.3.3 - 2.3.7	API level 10
#Gingerbread	2.3 - 2.3.2	API level 9, NDK 5
#Froyo	2.2.x	API level 8, NDK 4

if [ -z "${NDK_ROOT}"  ]; then
	export NDK_ROOT=${HOME}/NDK/android-ndk-r10e
	#export NDK_ROOT=${HOME}/NDK/android-ndk-r9
fi
export ANDROID_NDK=${NDK_ROOT}

while [ $# -ge 1 ]; do
	case $1 in
	-ABI|-abi)
		echo "\$1=-abi"
		shift
		APP_ABI=$1
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
echo APP_ABI=$APP_ABI
export APP_ABI

if [[ ${NDK_ROOT} =~ .*"-r9".* ]]
then
#ANDROID_APIVER=android-8
#ANDROID_APIVER=android-9
#android 4.0.1 ICS and above
ANDROID_APIVER=android-14
#TOOL_VER="4.6"
#gfortran is in r9d V4.8.0
TOOL_VER="4.8.0"
else
#r10d : android 4.0.1 ICS and above
if [ "$APP_ABI" = "arm64-v8a" -o \
	"$APP_ABI" = "x86_64" ]; then
	ANDROID_APIVER=android-21
else
	ANDROID_APIVER=android-14
fi
TOOL_VER="4.9"
fi

#default is arm
#export PATH="$NDK_ROOT/toolchains/${TARGPLAT}-${TOOL_VER}/prebuilt/${HOSTPLAT}/bin/:\
#$NDK_ROOT/toolchains/${TARGPLAT}-${TOOL_VER}/prebuilt/${HOSTPLAT}/${TARGPLAT}/bin/:$PATH"
case $APP_ABI in
  armeabi)
    TARGPLAT=arm-linux-androideabi
    TOOLCHAINS=arm-linux-androideabi
    ARCH=arm
	#enable VFP only
  ;;
  armeabi-v7a)
    TARGPLAT=arm-linux-androideabi
    TOOLCHAINS=arm-linux-androideabi
    ARCH=arm
	#enable NEON
  ;;
  arm64-v8a)
    TARGPLAT=aarch64-linux-android
    TOOLCHAINS=aarch64-linux-android
    ARCH=arm64
	#enable NEON
  ;;
  x86)#atom-32
    TARGPLAT=i686-linux-android
    TOOLCHAINS=x86
    ARCH=x86
	#specify assembler for x86 SSE3, but ffts's sse.s needs 64bit x86.
	#intel atom z2xxx and the old atoms are 32bit
	#http://forum.cvapp.org/viewtopic.php?f=13&t=423&sid=4c47343b1de899f9e1b0d157d04d0af1
	export  CCAS="${TARGPLAT}-as"
	export  CCASFLAGS="--32 -march=i686+sse3"
	echo "$APP_ABI is not supported in FFTS yet!!!"
  ;;
  x86_64)
    TARGPLAT=x86_64-linux-android
    TOOLCHAINS=x86_64
    ARCH=x86_64
    #specify assembler for x86 SSE3, but ffts's sse.s needs 64bit x86.
	#atom-64 or x86-64 devices only.
	#http://forum.cvapp.org/viewtopic.php?f=13&t=423&sid=4c47343b1de899f9e1b0d157d04d0af1
	export  CCAS="${TARGPLAT}-as"
#	export  CCASFLAGS="--64 -march=i686+sse3"
	export  CCASFLAGS="--64"
  ;;
  mips)
	## probably wrong
	TARGPLAT=mipsel-linux-android
	TOOLCHAINS=mipsel-linux-android
	ARCH=mips
	echo "$APP_ABI is not supported in FFTS yet!!!"
  ;;
  mips64)
	## probably wrong
	TARGPLAT=mips64el-linux-android
	TOOLCHAINS=mips64el-linux-android
	ARCH=mips64
	echo "$APP_ABI is not supported in FFTS yet!!!"
  ;;
  *) echo $0: Unknown target; exit
esac
echo "Using: $NDK_ROOT/toolchains/${TOOLCHAINS}-${TOOL_VER}/prebuilt/${HOSTPLAT}/bin"
export PATH="${NDK_ROOT}/toolchains/${TOOLCHAINS}-${TOOL_VER}/prebuilt/${HOSTPLAT}/bin/:$PATH"

export SYS_ROOT="${NDK_ROOT}/platforms/${ANDROID_APIVER}/arch-${ARCH}/"
export CC="${TARGPLAT}-gcc --sysroot=$SYS_ROOT"
export LD="${TARGPLAT}-ld"
export AR="${TARGPLAT}-ar"
export RANLIB="${TARGPLAT}-ranlib"
export STRIP="${TARGPLAT}-strip"
#export CFLAGS="-Os -fPIE"
export CFLAGS="-Os -fPIE --sysroot=$SYS_ROOT"
export CXXFLAGS="-fPIE --sysroot=$SYS_ROOT"
export FORTRAN="${TARGPLAT}-gfortran --sysroot=$SYS_ROOT"

#!!! quite importnat for cmake to define the NDK's fortran compiler.!!!
#Don't let cmake decide it.
export FC=${FORTRAN}
export AM_ANDROID_EXTRA="-llog -fPIE -pie"

#Some influential environment variables to configure
#export LIBS="-lc -lgcc -llog -fPIE -pie"
#export LDFLAGS="-mhard-float -D_NDK_MATH_NO_SOFTFP=1 -march=armv7-a -mfloat-abi=hard"
#export CFLAGS="-mhard-float -D_NDK_MATH_NO_SOFTFP=1 -march=armv7-a -mfloat-abi=hard"
#mkdir -p $INSTALL_DIR

if [ -z "$FFTS_DIR" ]; then
	export FFTS_DIR=`pwd`
fi

if [ -z "$FFTS_OUT" ]; then
	export FFTS_OUT=$FFTS_DIR/build
	export local_build=1
fi

#check if it needs a clean build?

if [ -d "$FFTS_OUT/$APP_ABI" ]; then
	rm -rf $FFTS_OUT/$APP_ABI/*
else
	mkdir -p $FFTS_OUT/$APP_ABI
fi

if [ ! -d ${FFTS_OUT}/libs/$APP_ABI ]; then
	mkdir -p ${FFTS_OUT}/libs/$APP_ABI
else
	rm -f ${FFTS_OUT}/libs/$APP_ABI/*
fi
#if [ -f ${FFTS_OUT}/libs/libffts-${ARCH}.a ]; then

#rm -f $FFTS_OUT/$APP_ABI/src/.libs/libffts.a
#rm -f $FFTS_OUT/$APP_ABI/src/libffts.la
#	rm -rf ${FFTS_OUT}/src/.libs
#fi
#ls -alR $FFTS_OUT
#read
#clone the upper repo but discard .git
#git clone --depth=1 ${FFTS_DIR} ${FFTS_OUT}/$APP_ABI
#rm -rf .git .gitignore
#cp -rf ${FFTS_DIR}/* ${FFTS_OUT}/$APP_ABI/
pwd
ls
read
cp -rf * ${FFTS_OUT}/$APP_ABI/
pushd ${FFTS_OUT}/$APP_ABI
cp Makefile.am.and Makefile.am
cp tests/Makefile.am.and tests/Makefile.am

#generating "configure" by configure.ac
#http://www.delorie.com/gnu/docs/autoconf/autoconf_13.html
#autoconf

case $APP_ABI in
  armeabi)
	./configure --enable-vfp  --host=armv5
  ;;
  armeabi-v7a)
    ./configure --enable-neon --host=armv7
	#enable NEON
  ;;
  arm64-v8a)
	./configure --enable-neon --host=armv8
	#enable NEON
  ;;
  x86)#atom-32
	./configure --enable-sse --enable-single --host=x86
  ;;
  x86_64)
	./configure --enable-sse --enable-single
  ;;
  mips)
	echo "$APP_ABI is not supported in FFTS yet!!!"
  ;;
  mips64)
	echo "$APP_ABI is not supported in FFTS yet!!!"
  ;;
  *) echo $0: Unknown target; exit
esac

automake --add-missing
make

ln -s $FFTS_OUT/$APP_ABI/src/.libs/libffts.a ${FFTS_OUT}/libs/$APP_ABI/libffts.a
ls -l ${FFTS_OUT}/libs/$APP_ABI/
popd
