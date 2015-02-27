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
while getopts ":ntc:" OPTNAME
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
    "?")
      echo "$0 -c [Debug|Release] -n"
      echo "       -c sets configuration (default=Debug)"
      echo "       -n no test run (default)"
      echo "       -t test run"
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
BOLTS_OSX_BINARY=$BOLTS_BUILD/${BUILDCONFIGURATION}/Bolts.framework

# -----------------------------------------------------------------------------

progress_message Building Framework.

# -----------------------------------------------------------------------------
# Compile binaries 
#
test -d $BOLTS_BUILD \
  || mkdir -p $BOLTS_BUILD \
  || die "Could not create directory $BOLTS_BUILD"

test -d $BOLTS_IOS_BUILD \
  || mkdir -p $BOLTS_IOS_BUILD \
  || die "Could not create directory $BOLTS_IOS_BUILD"

test -d $BOLTS_OSX_BUILD \
  || mkdir -p $BOLTS_OSX_BUILD \
  || die "Could not create directory $BOLTS_OSX_BUILD"

cd $BOLTS_SRC
function xcode_build_target() {
  echo "Compiling for platform: ${1}."
  $XCODEBUILD \
    -target "${3}Bolts" \
    -sdk $1 \
    -configuration "${2}" \
    SYMROOT=$BOLTS_BUILD \
    CURRENT_PROJECT_VERSION=$BOLTS_VERSION_FULL \
    clean build \
    || die "XCode build failed for platform: ${1}."
}

xcode_build_target "iphonesimulator" "${BUILDCONFIGURATION}"
xcode_build_target "iphoneos" "${BUILDCONFIGURATION}"
xcode_build_target "macosx" "${BUILDCONFIGURATION}" "Mac"

# -----------------------------------------------------------------------------
# Merge lib files for different platforms into universal binary
#
progress_message "Building Bolts univeral library using lipo."

mkdir -p $(dirname $BOLTS_IOS_BINARY)

# Copy/Paste iOS Framework to get structure/resources/etc
cp -av \
  "$BOLTS_BUILD/${BUILDCONFIGURATION}-iphoneos/Bolts.framework" \
  "$BOLTS_BUILD/${BUILDCONFIGURATION}-universal"
rm "$BOLTS_BUILD/${BUILDCONFIGURATION}-universal/Bolts.framework/Bolts"

# Combine iOS/Simulator binaries into a single universal binary.
$LIPO \
  -create \
    $BOLTS_BUILD/${BUILDCONFIGURATION}-iphonesimulator/Bolts.framework/Bolts \
    $BOLTS_BUILD/${BUILDCONFIGURATION}-iphoneos/Bolts.framework/Bolts \
  -output $BOLTS_IOS_BINARY \
  || die "lipo failed - could not create universal static library"

# Copy/Paste created iOS Framework to final location
cp -av "$(dirname $BOLTS_IOS_BINARY)" "$BOLTS_IOS_FRAMEWORK"

# Copy/Paste OSX framework, as this is already built for us
cp -av "$BOLTS_OSX_BINARY" "$BOLTS_OSX_FRAMEWORK"

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

progress_message "Framework version info:" `perl -pe "s/.*@//" < $BOLTS_SRC/Bolts/Common/BoltsVersion.h`
common_success
