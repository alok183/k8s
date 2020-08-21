#!/bin/bash

b64="base64 --wrap=0"

cat <<-EOF >secret-example.cm.yml
apiVersion: v1
kind: Secret
metadata:
  name: example-secret
  namespace: default
type: Opaque
data:
  example.yaml: $(cat example.yml | $b64)
EOF
