#!/bin/bash
if [ -z "$MESSAGE" ]; then
  export MESSAGE="MetaZ build $TRAVIS_BUILD_NUMBER"
fi
body="{
\"request\": {
\"branch\":\"master\",
\"message\": \"$MESSAGE\"
}}"

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token $SITE_TOKEN" \
   -d "$body" \
   https://api.travis-ci.org/repo/griff%2Fmetaz.io/requests
