#~/bin/bash
if [ -z "$TARGET_ARCH" ];then
	export TARGET_ARCH=x86_64
fi
export ARCH=x86
#check if build_x86 exists,
#if it's build_x86, rmdir and copy a fresh one and rebuild again
#mkdir ../build_$ARCH
#cp -rf * ../build_x86
#mv ../build_x86 .
if [ -z "$FFTS_DIR" ]; then
	export FFTS_DIR=`pwd`
fi

if [ -z "$FFTS_OUT" ]; then
	export FFTS_OUT=$FFTS_DIR/build
fi

#clean build
if [ ! -d $FFTS_OUT ]; then
	mkdir -p $FFTS_OUT
fi

if [ -d ${FFTS_OUT}/$TARGET_ARCH ]; then
	rm -rf ${FFTS_OUT}/$TARGET_ARCH
fi

if [ ! -d ${FFTS_OUT}/libs/$TARGET_ARCH ]; then
	mkdir -p ${FFTS_OUT}/libs/$TARGET_ARCH
else
	rm -rf ${FFTS_OUT}/libs/$TARGET_ARCH/*
fi

#clone the upper repo but discard .git
git clone --depth=1 ${FFTS_DIR} ${FFTS_OUT}/$TARGET_ARCH
pushd ${FFTS_OUT}/$TARGET_ARCH
rm -rf .git .gitignore

cp Makefile.am.${ARCH} Makefile.am
cp tests/Makefile.am.${ARCH} tests/Makefile.am
autoconf

#confiure and build
./configure --enable-sse --enable-single
automake --add-missing
make

ln -s $FFTS_OUT/$TARGET_ARCH/src/.libs/libffts.a ${FFTS_OUT}/libs/$TARGET_ARCH/libffts.a
