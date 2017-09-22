if [[ "$TRAVIS_BRANCH" != "$TRAVIS_TAG" ]]; then
  VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "build/Release/MetaZ.app/Contents/Info.plist")

  git config --global user.email "builds@travis-ci.com"
  git config --global user.name "Travis CI"
  export GIT_TAG=v${VERSION}
  echo git tag $GIT_TAG -a -m "Generated tag from TravisCI for build $TRAVIS_BUILD_NUMBER"
  git tag $GIT_TAG -a -m "Generated tag from TravisCI for build $TRAVIS_BUILD_NUMBER"
  git push -q https://$GITHUB_TOKEN@github.com/griff/metaz --tags
  export RELEASE_NAME="$(echo "$VERSION" | sed -e 's/.beta-/ Beta /')"
else
  export RELEASE_NAME=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "build/Release/MetaZ.app/Contents/Info.plist")
  echo "Skipping because build is a tag"
fi
Scripts/release-notes.rb
Scripts/release-notes.rb > build/Release/Release-notes.md
bundle exec Scripts/github_release.rb \
  --secret "$GITHUB_TOKEN" \
  --repo-slug griff/metaz \
  --changelog-file build/Release/Release-notes.md \
  --tag $GIT_TAG