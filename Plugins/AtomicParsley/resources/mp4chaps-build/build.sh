export MACOSX_DEPLOYMENT_TARGET=10.5
export CFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk"
export CXXFLAGS="-isysroot /Developer/SDKs/MacOSX10.5.sdk"
ARCH=$1
mkdir -p code/$ARCH
cd code/$ARCH
../../../configure --enable-static --disable-gch --enable-ub=$ARCH
make

./libtool --tag=CXX   --mode=link g++ -Wall -Wformat -isysroot /Developer/SDKs/MacOSX10.5.sdk -fvisibility=hidden -arch $ARCH -o mp4chaps util/mp4chaps.o .libs/libmp4v2.a
