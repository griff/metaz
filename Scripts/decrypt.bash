set -o errexit

if [[ ( -n "$encrypted_8e7577110561_key" ) -a ( -n "$encrypted_8e7577110561_iv" ) ]]; then
  openssl aes-256-cbc -K $encrypted_8e7577110561_key -iv $encrypted_8e7577110561_iv \
    -in sparkle_private.pem.enc -out sparkle_private.pem -d
fi