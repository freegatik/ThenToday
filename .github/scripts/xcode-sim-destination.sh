#!/bin/bash
set -euo pipefail
# PROJECT / SCHEME kept for callers; UDID uniquely identifies the destination and avoids
# xcodebuild "multiple matching destinations" when name+OS appears twice.
_PROJECT="${1:?}"
_SCHEME="${2:?}"
UDID="${3:?}"

echo "platform=iOS Simulator,id=${UDID}"
