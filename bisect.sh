xcodebuild -activetarget -activeconfiguration clean
rm -rf build
xcodebuild -activetarget -activeconfiguration
build/Debug/MetaZ.app/Contents/MacOS/MetaZ