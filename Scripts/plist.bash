set -o errexit

#[ -n "$CONFIGURATION_TEMP_DIR" ] || CONFIGURATION_TEMP_DIR="build/MetaZ.build/Debug"
#[ -n "$TARGET_TEMP_DIR" ] || TARGET_TEMP_DIR="$CONFIGURATION_TEMP_DIR/Plist\ Marcos.build"
#[ -n "$SCRIPT_INPUT_FILE_0" ] || SCRIPT_INPUT_FILE_0="Release/next_release.txt"
#[ -n "$SCRIPT_INPUT_FILE_1" ] || SCRIPT_INPUT_FILE_1="Plugins/Amazon/Access.h"
#[ -n "$SCRIPT_OUTPUT_FILE_0" ] || SCRIPT_OUTPUT_FILE_0="$TARGET_TEMP_DIR/PlistMacros.h"

PATH=$PATH:/usr/local/bin:/usr/bin:/sw/bin:/opt/local/bin
buildid=`git log -n1 --pretty=oneline --format=%h`
release=`cat $SCRIPT_INPUT_FILE_0`
builddate=`date +%y.%m.%d.%H`

if git show-ref --tags --quiet --verify -- "refs/tags/v$release"; then
  TAG="v$release"
elif git show-ref --tags --quiet --verify -- "refs/tags/$release"; then
  TAG="$release"
fi
if [ -n "$TAG" -a "$TAG" != "$(git describe --exact-match --tags HEAD 2> /dev/null)" ]; then
  echo "Tag $TAG exists and HEAD is not on it so we can't build version $release"
  exit 1
fi
env|sort
echo "#define BUILDID $buildid" > "$SCRIPT_OUTPUT_FILE_0"
echo "#define BUILDDATE $builddate" >> "$SCRIPT_OUTPUT_FILE_0"
echo "#define BUILDVERSION $builddate.$buildid" >> "$SCRIPT_OUTPUT_FILE_0"
echo "#define WHOAMI `whoami`" >> "$SCRIPT_OUTPUT_FILE_0"
echo "#define RELEASE $release" >> "$SCRIPT_OUTPUT_FILE_0" 
cat $SCRIPT_INPUT_FILE_1 >> "$SCRIPT_OUTPUT_FILE_0" 

# Delete the intermediate Info.plist so that Xcode re-preprocesses the Info.plist with our updated macros.
# Use -f because after a clean build, this file doesn't exist yet, so a plain rm would fail and stop the build.
rm -f "${CONFIGURATION_TEMP_DIR}/MetaZ.build/Preprocessed-Info.plist"
