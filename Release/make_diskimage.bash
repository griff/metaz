PATH=$PATH:/usr/local/bin:/usr/bin:/sw/bin:/opt/local/bin
set -o errexit
#set -x

if [ "${CONFIGURATION}" != "Release" ]; then exit; fi

rm -f "$BUILT_PRODUCTS_DIR/$PROJECT_NAME"*.dmg

VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "$BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/Info.plist")
SOURCE_FILES=($CODESIGNING_FOLDER_PATH Thanks.txt License.txt)
TEMPLATE_DMG=$SRCROOT/Release/template.dmg
MASTER_DMG=$BUILT_PRODUCTS_DIR/$PROJECT_NAME-${VERSION}.dmg
WC_DMG=$CONFIGURATION_TEMP_DIR/wc.dmg
WC_DIR=$CONFIGURATION_TEMP_DIR/wc
ARCHIVE_FILENAME="$PROJECT_NAME-$VERSION.zip"
export GITV=`git log -n1 --pretty=oneline --format=%h`

if [ ! -f "${TEMPLATE_DMG}.zip" ]; then
  echo
  echo --------------------- Generating empty template --------------------
  mkdir "$CONFIGURATION_TEMP_DIR/template"
  hdiutil create -fs HFSX -layout SPUD -size 40m "$TEMPLATE_DMG" -srcfolder "$CONFIGURATION_TEMP_DIR/template" -format UDRW -volname   "$PROJECT_NAME" -quiet
  rmdir "$CONFIGURATION_TEMP_DIR/template"
  ditto -ck "$TEMPLATE_DMG" "${TEMPLATE_DMG}.zip"
  echo
fi

if [ -f "${TEMPLATE_DMG}.zip" ]; then
  ditto -xk "${TEMPLATE_DMG}.zip" "$SRCROOT/Release"
fi
cp "${TEMPLATE_DMG}" "$WC_DMG"
rm -r "${TEMPLATE_DMG}"
mkdir -p "$WC_DIR"

hdiutil attach "$WC_DMG" -noautoopen -quiet -mountpoint "$WC_DIR"
for i in $SOURCE_FILES; do
	base=`basename $i`
	rm -rf "$WC_DIR/$base"
	ditto -rsrc "$i" "$WC_DIR/$base"
done
#rm -f "$@"
#hdiutil create -srcfolder "$(WC_DIR)" -format UDZO -imagekey zlib-level=9 "$@" -volname "$(NAME) $(VERSION)" -scrub -quiet
WC_DEV=`hdiutil info | grep "$WC_DIR" | grep "Apple_HFS" | awk '{print $1}'` && \
	hdiutil detach $WC_DEV -quiet -force
rm -f "$MASTER_DMG"
hdiutil convert "$WC_DMG" -quiet -format UDZO -imagekey zlib-level=9 -o "$MASTER_DMG"
rm -rf "$WC_DIR"

if [ ! -z "${EULA_RSRC}" -a "${EULA_RSRC}" != "-null-" ]; then
  echo "adding EULA resources"
  hdiutil unflatten "$MASTER_DMG"
  /Developer/Tools/ResMerger -a "${EULA_RSRC}" -o "$MASTER_DMG"
  hdiutil flatten "$MASTER_DMG"
fi

app=`which seticon || echo 'non'`
if [ -x $app ] ; then 
	seticon "$WC_DMG" "$MASTER_DMG"
else
	echo warning Missing stuff
fi

WD=$PWD
cd "$BUILT_PRODUCTS_DIR"
rm -f "$PROJECT_NAME"*.zip
ditto -ck --keepParent "$PROJECT_NAME.app" "$ARCHIVE_FILENAME"

mkdir -p DSYMS
cp -R *.dSYM DSYMS/

#ditto -ck --keepParent "$PROJECT_NAME.app.dSYM" "$PROJECT_NAME-$VERSION-$GITV+dYSM.zip"
ditto -ck DSYMS "$PROJECT_NAME-$VERSION-$GITV+dYSM.zip"
rm -rf DSYMS


