#!/bin/bash
# Runs the sample root app unless a real app is deployed (GIT_REPO) or it is disabled.
if [ -n "$GIT_REPO" ] || [ "$SAMPLE_APP" == "false" ]; then
  echo "Sample app disabled (GIT_REPO set or SAMPLE_APP=false)."
  exit 0
fi
exec node /root/sample-app/server.js
