set -o errexit

if [ -z "$BUILT_PRODUCTS_DIR" ] ; then
  BUILT_PRODUCTS_DIR=build/Debug/
fi
if [ -z "$PROJECT_NAME" ] ; then
  PROJECT_NAME=MetaZ
fi
OUTPUT=$BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/Info.plist

for k in $BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/PlugIns/*.mzdataprovider ; do
  if [ -n "$(/usr/libexec/PlistBuddy -c "print :CFBundleDocumentTypes" $k/Contents/Info.plist)" ] ; then
    /usr/libexec/PlistBuddy -c "Add :PluginCFBundleDocumentTypes dict" "$OUTPUT"
    /usr/libexec/PlistBuddy -c "Merge $k/Contents/Info.plist :PluginCFBundleDocumentTypes" "$OUTPUT"
    while /usr/libexec/PlistBuddy -c "Copy :PluginCFBundleDocumentTypes:CFBundleDocumentTypes:0 CFBundleDocumentTypes:0" "$OUTPUT" 2> /dev/null ; do
      /usr/libexec/PlistBuddy -c "Delete :PluginCFBundleDocumentTypes:CFBundleDocumentTypes:0" "$OUTPUT"
    done
    /usr/libexec/PlistBuddy -c "Delete :PluginCFBundleDocumentTypes" "$OUTPUT"
  fi
done
