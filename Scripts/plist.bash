set -o errexit
set -x

[ -n "$CONFIGURATION_TEMP_DIR" ] || CONFIGURATION_TEMP_DIR="build/MetaZ.build/Debug"
[ -n "$TARGET_TEMP_DIR" ] || TARGET_TEMP_DIR="$CONFIGURATION_TEMP_DIR/Plist Marcos.build"
[ -n "$SCRIPT_INPUT_FILE_0" ] || SCRIPT_INPUT_FILE_0="Release/next_release.txt"
[ -n "$SCRIPT_OUTPUT_FILE_0" ] || SCRIPT_OUTPUT_FILE_0="$TARGET_TEMP_DIR/PlistMacros.h"

PATH=$PATH:/usr/local/bin:/usr/bin:/sw/bin:/opt/local/bin
buildid=`git log -n1 --pretty=oneline --format=%h`
release=`cat "$SCRIPT_INPUT_FILE_0"`
builddate=`date +%y.%m%d.%H%M`

major="$(echo $release | cut -d . -f 1 -)"
minor="$(echo $release | cut -d . -f 2 -)"

while git show-ref --tags --quiet --verify -- "refs/tags/v${major}.${minor}" ; do
  ((minor = $minor + 1))
done
if [[ -n "$GITHUB_REF" ]]; then
  if [[ $GITHUB_REF != refs/tags/* ]]; then
    number="$(git rev-list --count "$GITHUB_REF")"
    release="${major}.${minor}.beta-$number"
  else
    ((minors = $minor - 1))
    if [[ "$GITHUB_REF" == "refs/tags/v${major}.${minors}" ]]; then
      release="${major}.${minors}"
    else
      release=${GITHUB_REF#refs/tags/v}
      #release="${major}.${minor}"
    fi
  fi
else
  release="${major}.${minor}"
fi

if git show-ref --tags --quiet --verify -- "refs/tags/v$release"; then
  TAG="v$release"
elif git show-ref --tags --quiet --verify -- "refs/tags/$release"; then
  TAG="$release"
fi
if [ -n "$TAG" -a "$TAG" != "$(git tag --points-at HEAD | grep -e  "^${TAG}$" 2> /dev/null)" ]; then
  echo "Tag $TAG exists and HEAD is not on it so we can't build version $release"
  exit 1
fi
echo "#define BUILDID $buildid" > "$SCRIPT_OUTPUT_FILE_0"
echo "#define BUILDDATE $builddate" >> "$SCRIPT_OUTPUT_FILE_0"
echo "#define BUILDVERSION $builddate.$buildid" >> "$SCRIPT_OUTPUT_FILE_0"
echo "#define WHOAMI `whoami`" >> "$SCRIPT_OUTPUT_FILE_0"
echo "#define RELEASE $release" >> "$SCRIPT_OUTPUT_FILE_0" 

# Delete the intermediate Info.plist so that Xcode re-preprocesses the Info.plist with our updated macros.
# Use -f because after a clean build, this file doesn't exist yet, so a plain rm would fail and stop the build.
rm -f "${CONFIGURATION_TEMP_DIR}/MetaZ.build/Preprocessed-Info.plist"
