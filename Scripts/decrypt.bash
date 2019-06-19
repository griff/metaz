set -o errexit
set -x

if [[ -n "$encrypted_407c52b0da85_key" ]]; then
  if [[ -n "$encrypted_407c52b0da85_iv" ]]; then
    openssl aes-256-cbc -K $encrypted_407c52b0da85_key -iv $encrypted_407c52b0da85_iv \
      -in sparkle_private.pem.enc -out sparkle_private.pem -d
  fi
fi
