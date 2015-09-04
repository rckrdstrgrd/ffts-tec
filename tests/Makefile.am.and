#NDK hard still doesn't work well: -mhard-float -D_NDK_MATH_NO_SOFTFP=1 -march=armv7-a -mfloat-abi=hard
AM_LDFLAGS = -llog -fPIE -pie
noinst_PROGRAMS = test
test_SOURCES = test.c
test_LDADD = $(top_builddir)/src/libffts.la
