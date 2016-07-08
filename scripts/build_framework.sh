#!/bin/sh
#
# Copyright 2010-present Facebook.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script builds Bolts.framework.

. ${BOLTS_SCRIPT:-$(dirname $0)}/common.sh

# process options, valid arguments -c [Debug|Release] -n 
BUILDCONFIGURATION=Debug
NOEXTRAS=1
WATCHOS=0
TVOS=0
while getopts ":ntc:-:" OPTNAME
do
  case "$OPTNAME" in
    "c")
      BUILDCONFIGURATION=$OPTARG
      ;;
    "n")
      NOEXTRAS=1
      ;;
    "t")
      NOEXTRAS=0
      ;;
    -)
      case "${OPTARG}" in
        "with-watchos")
          WATCHOS=1
        ;;
        "with-tvos")
          TVOS=1
        ;;
        *)
        # Should not occur
          echo "Unknown error while processing options"
          die
          ;;
      esac
    ;;
    "?")
      echo "$0 -c [Debug|Release] -n --with-watchos --with-tvos"
      echo "       -c sets configuration (default=Debug)"
      echo "       -n no test run (default)"
      echo "       -t test run"
      echo "       --with-watchos Add watchOS framework"
      echo "       --with-tvos Add tvOS framework"
      die
      ;;
    ":")
      echo "Missing argument value for option $OPTARG"
      die
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options"
      die
      ;;
  esac
done

test -x "$XCODEBUILD" || die 'Could not find xcodebuild in $PATH'
test -x "$LIPO" || die 'Could not find lipo in $PATH'

BOLTS_IOS_BINARY=$BOLTS_BUILD/${BUILDCONFIGURATION}-universal/Bolts.framework/Bolts
BOLTS_MACOS_BINARY=$BOLTS_BUILD/${BUILDCONFIGURATION}/Bolts.framework
BOLTS_TVOS_BINARY=$BOLTS_BUILD/${BUILDCONFIGURATION}-appletv-universal/Bolts.framework/Bolts
BOLTS_WATCHOS_BINARY=$BOLTS_BUILD/${BUILDCONFIGURATION}-watch-universal/Bolts.framework/Bolts

# -----------------------------------------------------------------------------

progress_message Building Framework.

# -----------------------------------------------------------------------------
# Compile binaries 
#
test -d "$BOLTS_BUILD" \
  || mkdir -p "$BOLTS_BUILD" \
  || die "Could not create directory $BOLTS_BUILD"

test -d "$BOLTS_IOS_BUILD" \
  || mkdir -p "$BOLTS_IOS_BUILD" \
  || die "Could not create directory $BOLTS_IOS_BUILD"

test -d "$BOLTS_MACOS_BUILD" \
  || mkdir -p "$BOLTS_MACOS_BUILD" \
  || die "Could not create directory $BOLTS_MACOS_BUILD"

if [ $WATCHOS -eq 1 ]; then
  test -d "$BOLTS_WATCHOS_BUILD" \
    || mkdir -p "$BOLTS_WATCHOS_BUILD" \
    || die "Could not create directory $BOLTS_WATCHOS_BUILD"
fi

if [ $TVOS -eq 1 ]; then
  test -d "$BOLTS_TVOS_BUILD" \
    || mkdir -p "$BOLTS_TVOS_BUILD" \
    || die "Could not create directory $BOLTS_TVOS_BUILD"
fi

cd "$BOLTS_SRC"
function xcode_build_target() {
  echo "Compiling for platform: ${1}."
  "$XCODEBUILD" \
    -target "${3}" \
    -sdk $1 \
    -configuration "${2}" \
    SYMROOT="$BOLTS_BUILD" \
    CURRENT_PROJECT_VERSION="$BOLTS_VERSION_FULL" \
    clean build \
    || die "Xcode build failed for platform: ${1}."
}

xcode_build_target "iphonesimulator" "${BUILDCONFIGURATION}" "Bolts-iOS"
xcode_build_target "iphoneos" "${BUILDCONFIGURATION}" "Bolts-iOS"
xcode_build_target "macosx" "${BUILDCONFIGURATION}" "Bolts-macOS"
if [ $WATCHOS -eq 1 ]; then
  xcode_build_target "watchsimulator" "${BUILDCONFIGURATION}" "Bolts-watchOS"
  xcode_build_target "watchos" "${BUILDCONFIGURATION}" "Bolts-watchOS"
fi
if [ $TVOS -eq 1 ]; then
  xcode_build_target "appletvsimulator" "${BUILDCONFIGURATION}" "Bolts-tvOS"
  xcode_build_target "appletvos" "${BUILDCONFIGURATION}" "Bolts-tvOS"
fi

# -----------------------------------------------------------------------------
# Merge lib files for different platforms into universal binary
#
progress_message "Building Bolts univeral library using lipo."

mkdir -p "$(dirname "$BOLTS_IOS_BINARY")"

if [ $WATCHOS -eq 1 ]; then
  mkdir -p "$(dirname "$BOLTS_WATCHOS_BINARY")"
fi

if [ $TVOS -eq 1 ]; then
  mkdir -p "$(dirname "$BOLTS_TVOS_BINARY")"
fi

# Copy/Paste iOS Framework to get structure/resources/etc
cp -av \
  "$BOLTS_BUILD/${BUILDCONFIGURATION}-iphoneos/Bolts.framework" \
  "$BOLTS_BUILD/${BUILDCONFIGURATION}-universal"
rm "$BOLTS_BUILD/${BUILDCONFIGURATION}-universal/Bolts.framework/Bolts"

if [ $WATCHOS -eq 1 ]; then
  # Copy/Paste watchOS framework to get structure/resources/etc
  cp -av \
    "$BOLTS_BUILD/${BUILDCONFIGURATION}-watchos/Bolts.framework" \
    "$BOLTS_BUILD/${BUILDCONFIGURATION}-watch-universal"
  rm "$BOLTS_BUILD/${BUILDCONFIGURATION}-watch-universal/Bolts.framework/Bolts"
fi

if [ $TVOS -eq 1 ]; then
  # Copy/Paste tvOS framework to get structure/resources/etc
  cp -av \
    "$BOLTS_BUILD/${BUILDCONFIGURATION}-appletvos/Bolts.framework" \
    "$BOLTS_BUILD/${BUILDCONFIGURATION}-appletv-universal"
  rm "$BOLTS_BUILD/${BUILDCONFIGURATION}-appletv-universal/Bolts.framework/Bolts"
fi

# Combine iOS/Simulator binaries into a single universal binary.
"$LIPO" \
  -create \
    "$BOLTS_BUILD/${BUILDCONFIGURATION}-iphonesimulator/Bolts.framework/Bolts" \
    "$BOLTS_BUILD/${BUILDCONFIGURATION}-iphoneos/Bolts.framework/Bolts" \
  -output "$BOLTS_IOS_BINARY" \
  || die "lipo failed - could not create universal static library"

if [ $WATCHOS -eq 1 ]; then
  # Combine watchOS/Simulator binaries into a single universal binary.
  "$LIPO" \
    -create \
      "$BOLTS_BUILD/${BUILDCONFIGURATION}-watchsimulator/Bolts.framework/Bolts" \
      "$BOLTS_BUILD/${BUILDCONFIGURATION}-watchos/Bolts.framework/Bolts" \
    -output "$BOLTS_WATCHOS_BINARY" \
    || die "lipo failed - could not create universal static library"
fi

if [ $TVOS -eq 1 ]; then
  # Combine tvOS/Simulator binaries into a single universal binary.
  "$LIPO" \
    -create \
      "$BOLTS_BUILD/${BUILDCONFIGURATION}-appletvsimulator/Bolts.framework/Bolts" \
      "$BOLTS_BUILD/${BUILDCONFIGURATION}-appletvos/Bolts.framework/Bolts" \
    -output "$BOLTS_TVOS_BINARY" \
    || die "lipo failed - could not create universal static library"
fi

# Copy/Paste created iOS Framework to final location
cp -av "$(dirname "$BOLTS_IOS_BINARY")" $BOLTS_IOS_FRAMEWORK

# Copy/Paste macOS framework, as this is already built for us
cp -av "$BOLTS_MACOS_BINARY" $BOLTS_MACOS_FRAMEWORK

if [ $WATCHOS -eq 1 ]; then
  # Copy/Paste watchOS Framework
  cp -av "$(dirname "$BOLTS_WATCHOS_BINARY")" $BOLTS_WATCHOS_FRAMEWORK
fi

if [ $TVOS -eq 1 ]; then
  # Copy/Paste tvOS Framework
  cp -av "$(dirname "$BOLTS_TVOS_BINARY")" $BOLTS_TVOS_FRAMEWORK
fi

# -----------------------------------------------------------------------------
# Run unit tests 
#

if [ ${NOEXTRAS:-0} -eq  1 ];then
  progress_message "Skipping unit tests."
else
  progress_message "Running unit tests."
  cd $BOLTS_SRC
  $BOLTS_SCRIPT/run_tests.sh -c $BUILDCONFIGURATION MacBolts
fi

# -----------------------------------------------------------------------------
# Done
#

common_success
