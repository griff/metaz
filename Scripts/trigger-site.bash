body="{
\"request\": {
\"branch\":\"master\",
\"message\": \"MetaZ build $TRAVIS_BUILD_NUMBER\"
}}"

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token $SITE_TOKEN" \
   -d "$body" \
   https://api.travis-ci.org/repo/griff%2Fmetaz.io/requests