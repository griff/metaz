set -o errexit
set -x

if [ "${CONFIGURATION}" != "Release" ]; then exit; fi
if [[ ! -f "sparkle_private.pem" ]] ; then 
  if [ -n "$SPARKLE_PRIVATE_KEY" ]; then
    echo "$SPARKLE_PRIVATE_KEY" > sparkle_private.pem
  else
    echo "No sparkle_private.pem found so skipping package sign"
    exit
  fi
fi

PATH=$PATH:/usr/local/bin:/usr/bin:/sw/bin:/opt/local/bin

VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "$BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/Info.plist")
FULLVERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleVersion" "$BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/Info.plist")
DOWNLOAD_BASE_URL="http://github.com/downloads/griff/metaz"
RELEASENOTES_URL="http://griff.github.com/metaz/release-notes.html#version-$VERSION"
MINIMUM_VERSION="$(/usr/libexec/PlistBuddy -c "print :LSMinimumSystemVersion" "$BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/Info.plist")"

ARCHIVE_FILENAME="$PROJECT_NAME-$VERSION.zip"
DOWNLOAD_URL="$DOWNLOAD_BASE_URL/$ARCHIVE_FILENAME"

WD=$PWD
cd "$BUILT_PRODUCTS_DIR"

SIZE=$(stat -f %z "$ARCHIVE_FILENAME")
PUBDATE=$(date +"%a, %d %b %G %T %z")
SIGNATURE=$(openssl dgst -sha1 -binary < "$ARCHIVE_FILENAME" | openssl dgst -dss1 -sign "$WD/sparkle_private.pem" | openssl enc -base64)

[ $SIGNATURE ] || { echo "Unable to load signing key from sparkle_private.pem"; false; }

cat > "$PROJECT_NAME-$VERSION.xml" <<EOF
			<enclosure
				sparkle:version="$FULLVERSION"
				sparkle:shortVersionString="$VERSION"
				length="$SIZE"
				sparkle:dsaSignature="$SIGNATURE"
			/>
EOF
cat > "$PROJECT_NAME-$VERSION.json" <<EOF
{
  "version": "$FULLVERSION",
  "shortVersionString": "$VERSION",
  "size": $SIZE,
  "dsaSignature": "$SIGNATURE",
  "minimumSystemVersion": "$MINIMUM_VERSION"
}
EOF
