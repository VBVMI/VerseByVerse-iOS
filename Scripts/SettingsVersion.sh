#!/bin/bash

# This script automatically sets the version and short version string of
# into the Settings Bundle
#
# To use this script in Xcode, add the contents to a "Run Script" build
# phase for your application target, after the other phases.

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/${INFOPLIST_FILE}")

/usr/libexec/PlistBuddy "$SRCROOT/Letterboxd/Settings.bundle/Root.plist" -c "set PreferenceSpecifiers:1:DefaultValue $VERSION"