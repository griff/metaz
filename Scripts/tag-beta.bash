if [[ $GITHUB_REF != refs/tags/* ]]; then
  if [[ "$GITHUB_REF" != "refs/heads/develop" ]]; then
    echo "Skipping tag for $GITHUB_REF ref."
    export SKIP=1
  else
    VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "build/Release/MetaZ.app/Contents/Info.plist")

    git config --global user.email "builds@metaz.maven-group.org"
    git config --global user.name "CI"
    export GIT_TAG=v${VERSION}
    echo git tag $GIT_TAG -a -m "Generated tag from CI for build $GITHUB_RUN_NUMBER"
    git tag $GIT_TAG -a -m "Generated tag from CI for build $GITHUB_RUN_NUMBER"
    git push -q https://$SITE_TOKEN@github.com/griff/metaz --tags
    #export RELEASE_NAME="$(echo "$VERSION" | sed -e 's/.beta-/ Beta /')"
  fi
else
  echo "Build is a tag"
  VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "build/Release/MetaZ.app/Contents/Info.plist")
  #export RELEASE_NAME="$(echo "$VERSION" | sed -e 's/.beta-/ Beta /')"
  #export GIT_TAG="$TRAVIS_TAG"
  git fetch --tags
fi
#if [ -z "$SKIP" ]; then
#    Scripts/release-notes.rb
#    Scripts/release-notes.rb > build/Release/Release-notes.md
#    bundle exec Scripts/github_release.rb \
#        --secret "$SITE_TOKEN" \
#        --repo-slug griff/metaz \
#        --changelog-file build/Release/Release-notes.md \
#        --tag $GIT_TAG
#fi
