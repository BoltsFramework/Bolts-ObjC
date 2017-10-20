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

# This script sets up a consistent environment for the other scripts in this directory.

# Set up paths for a specific clone of the SDK source
if [ -z "$BOLTS_SCRIPT" ]; then
  # ---------------------------------------------------------------------------
  # Versioning for the SDK
  #
  BOLTS_VERSION_MAJOR=0
  BOLTS_VERSION_MINOR=1
  test -n "$BOLTS_VERSION_BUILD" || BOLTS_VERSION_BUILD=$(date '+%Y%m%d')
  BOLTS_VERSION=${BOLTS_VERSION_MAJOR}.${BOLTS_VERSION_MINOR}
  BOLTS_VERSION_FULL=${BOLTS_VERSION}.${BOLTS_VERSION_BUILD}

  # ---------------------------------------------------------------------------
  # Set up paths
  #

  # The directory containing this script
  # We need to go there and use pwd so these are all absolute paths
  pushd "$(dirname $BASH_SOURCE[0])" >/dev/null
  BOLTS_SCRIPT="$(pwd)"
  popd >/dev/null

  # The root directory where Bolts is cloned
  BOLTS_ROOT=$(dirname "$BOLTS_SCRIPT")

  # Path to source files for Bolts
  BOLTS_SRC=$BOLTS_ROOT

  # The directory where the target is built
  BOLTS_BUILD=$BOLTS_ROOT/build
  BOLTS_IOS_BUILD=$BOLTS_ROOT/build/ios
  BOLTS_MACOS_BUILD=$BOLTS_ROOT/build/osx
  BOLTS_WATCHOS_BUILD=$BOLTS_ROOT/build/watchOS
  BOLTS_TVOS_BUILD=$BOLTS_ROOT/build/tvOS
  BOLTS_BUILD_LOG=$BOLTS_BUILD/build.log

  # The name of the Bolts framework
  BOLTS_FRAMEWORK_NAME=Bolts.framework

  # The path to the built Bolts .framework file
  BOLTS_IOS_FRAMEWORK=$BOLTS_IOS_BUILD/$BOLTS_FRAMEWORK_NAME
  BOLTS_MACOS_FRAMEWORK=$BOLTS_MACOS_BUILD/$BOLTS_FRAMEWORK_NAME
  BOLTS_WATCHOS_FRAMEWORK=$BOLTS_WATCHOS_BUILD/$BOLTS_FRAMEWORK_NAME
  BOLTS_TVOS_FRAMEWORK=$BOLTS_TVOS_BUILD/$BOLTS_FRAMEWORK_NAME

  # The name of the docset
  BOLTS_DOCSET_NAME=Bolts.docset

  # The path to the framework docs
  BOLTS_FRAMEWORK_DOCS=$BOLTS_BUILD/$BOLTS_DOCSET_NAME
  
  # Archive name for distribution
  BOLTS_DISTRIBUTION_ARCHIVE=Bolts-iOS.zip

fi

# Set up one-time variables
if [ -z $BOLTS_ENV ]; then
  BOLTS_ENV=env1
  BOLTS_BUILD_DEPTH=0

  # Explains where the log is if this is the outermost build or if
  # we hit a fatal error.
  function show_summary() {
    test -r "$BOLTS_BUILD_LOG" && echo "Build log is at $BOLTS_BUILD_LOG"
  }

  # Determines whether this is out the outermost build.
  function is_outermost_build() {
      test 1 -eq $BOLTS_BUILD_DEPTH
  }

  # Calls show_summary if this is the outermost build.
  # Do not call outside common.sh.
  function pop_common() {
    BOLTS_BUILD_DEPTH=$(($BOLTS_BUILD_DEPTH - 1))
    test 0 -eq $BOLTS_BUILD_DEPTH && show_summary
  }

  # Deletes any previous build log if this is the outermost build.
  # Do not call outside common.sh.
  function push_common() {
    test 0 -eq $BOLTS_BUILD_DEPTH && \rm -f $BOLTS_BUILD_LOG
    BOLTS_BUILD_DEPTH=$(($BOLTS_BUILD_DEPTH + 1))
  }

  # Echoes a progress message to stderr
  function progress_message() {
      echo "$@" >&2
  }

  # Any script that includes common.sh must call this once if it finishes
  # successfully.
  function common_success() { 
      pop_common
      return 0
  }

  # Call this when there is an error.  This does not return.
  function die() {
    echo ""
    echo "FATAL: $*" >&2
    show_summary
    exit 1
  }

  test -n "$XCODEBUILD"   || XCODEBUILD=$(which xcodebuild)
  test -n "$LIPO"         || LIPO=$(which lipo)
  test -n "$PACKAGEMAKER" || PACKAGEMAKER=$(which PackageMaker)
  test -n "$CODESIGN"     || CODESIGN=$(which codesign)
  test -n "$APPLEDOC"     || APPLEDOC=$(which appledoc)

  # < XCode 4.3.1
  if [ ! -x "$XCODEBUILD" ]; then
    # XCode from app store
    XCODEBUILD=/Applications/XCode.app/Contents/Developer/usr/bin/xcodebuild
  fi

  if [ ! -x "$PACKAGEMAKER" ]; then
    PACKAGEMAKER=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker
  fi

  if [ ! -x "$PACKAGEMAKER" ]; then
    PACKAGEMAKER=/Applications/PackageMaker.app/Contents/MacOS/PackageMaker
  fi
fi

# Increment depth every time we . this file.  At the end of any script
# that .'s this file, there should be a call to common_success to decrement.
push_common
