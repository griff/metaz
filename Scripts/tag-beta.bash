if [[ "$TRAVIS_BRANCH" != "$TRAVIS_TAG" ]]; then
  VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "build/Release/MetaZ.app/Contents/Info.plist")

  git config --global user.email "builds@travis-ci.com"
  git config --global user.name "Travis CI"
  export GIT_TAG=v${VERSION}.beta-$TRAVIS_BUILD_NUMBER
  echo git tag $GIT_TAG -a -m "Generated tag from TravisCI for build $TRAVIS_BUILD_NUMBER"
  git tag $GIT_TAG -a -m "Generated tag from TravisCI for build $TRAVIS_BUILD_NUMBER"
  git push -q https://$GITHUB_TOKEN@github.com/griff/metaz --tags
else
  echo "Skipping because build is a tag"
fi