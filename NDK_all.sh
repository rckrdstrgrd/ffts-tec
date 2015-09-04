#!/bin/bash
if [ $TARGET_ARCH == "all" ]; then
	echo "================================"
	echo "-abi armeabi -acc vec -c"
	echo "================================"
	./build_NDK_cmake.sh -abi armeabi -acc vec -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "================================"
	echo "-abi armeabi-v7a -acc neon -c"
	echo "================================"
	./build_NDK_cmake.sh -abi armeabi-v7a -acc neon -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "================================"
	echo "-abi arm64-v8a -acc vec -c"
	echo "================================"
	./build_NDK_cmake.sh -abi arm64-v8a -acc vec -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "================================"
	echo "-abi x86 -acc generic -c"
	echo "================================"
	./build_NDK_cmake.sh -abi x86 -acc generic -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "================================"
	echo "-abi x86_64 -acc neon -c"
	echo "================================"
	./build_NDK_cmake.sh -abi x86_64 -acc neon -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "================================"
	echo "-abi mips -acc generic -c"
	echo "================================"
	./build_NDK_cmake.sh -abi mips -acc vfp -c
	ret6=$?
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "================================"
	echo "-abi mips64 -acc generic -c"
	echo "================================"
	./build_NDK_cmake.sh -abi mips64 -acc vfp -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

else
	echo "================================"
	echo "-abi $TARGET_ARCH -acc generic -c"
	echo "================================"
	./build_NDK_cmake.sh -abi $TARGET_ARCH -c
	if [ "$?" != "0" ]; then
		exit -1
	fi
fi
#echo "00000"
exit 0
