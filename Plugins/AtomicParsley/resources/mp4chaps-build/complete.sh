
sh scripts/build.sh ppc
sh scripts/build.sh i386
sh scripts/build.sh x86_64

LINK=`readlink -n scripts`
lipo -create -arch ppc code/ppc/mp4chaps -arch i386 code/i386/mp4chaps  -arch x86_64 code/x86_64/mp4chaps -output $LINK/../mp4chaps