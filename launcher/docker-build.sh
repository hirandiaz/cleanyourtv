#!/usr/bin/env bash
# Build the launcher APK inside Docker, so the host needs no JDK or Android SDK.
# Output: app/build/outputs/apk/release/app-release.apk
# Gradle cache and the debug signing key live in named volumes, so later builds are fast and every
# APK is signed with the same key (an install over a different key fails).
#
# Usage: launcher/docker-build.sh
set -euo pipefail
cd "$(dirname "$0")"
IMAGE=tvhome-builder:1
docker build --platform linux/amd64 -t "$IMAGE" docker/
docker run --rm --platform linux/amd64 \
  -v "$PWD":/src \
  -v tvhome-gradle:/cache/gradle \
  -v tvhome-android:/root/.android \
  "$IMAGE" ./gradlew assembleRelease --no-watch-fs --console=plain -q
ls -l app/build/outputs/apk/release/app-release.apk
