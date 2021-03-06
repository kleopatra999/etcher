#!/bin/bash

###
# Copyright 2016 resin.io
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###

set -u
set -e

OS=$(uname -o 2>/dev/null || true)
if [[ "$OS" != "Msys" ]]; then
  echo "This script is only meant to be run in Windows" 1>&2
  exit 1
fi

./scripts/build/check-dependency.sh unzip

function usage() {
  echo "Usage: $0"
  echo ""
  echo "Options"
  echo ""
  echo "    -p <electron package>"
  echo "    -n <application name>"
  echo "    -d <application description>"
  echo "    -v <application version>"
  echo "    -c <application copyright>"
  echo "    -l <application license file>"
  echo "    -m <company name>"
  echo "    -a <application asar (.asar)>"
  echo "    -i <application icon (.ico)>"
  echo "    -w <download directory>"
  echo "    -o <output directory>"
  exit 1
}

ARGV_ELECTRON_PACKAGE=""
ARGV_APPLICATION_NAME=""
ARGV_APPLICATION_DESCRIPTION=""
ARGV_VERSION=""
ARGV_COPYRIGHT=""
ARGV_LICENSE=""
ARGV_COMPANY_NAME=""
ARGV_ASAR=""
ARGV_ICON=""
ARGV_DOWNLOAD_DIRECTORY=""
ARGV_OUTPUT=""

while getopts ":p:n:d:v:c:l:m:a:i:w:o:" option; do
  case $option in
    p) ARGV_ELECTRON_PACKAGE="$OPTARG" ;;
    n) ARGV_APPLICATION_NAME="$OPTARG" ;;
    d) ARGV_APPLICATION_DESCRIPTION="$OPTARG" ;;
    v) ARGV_VERSION="$OPTARG" ;;
    c) ARGV_COPYRIGHT="$OPTARG" ;;
    l) ARGV_LICENSE="$OPTARG" ;;
    m) ARGV_COMPANY_NAME="$OPTARG" ;;
    a) ARGV_ASAR="$OPTARG" ;;
    i) ARGV_ICON="$OPTARG" ;;
    w) ARGV_DOWNLOAD_DIRECTORY="$OPTARG" ;;
    o) ARGV_OUTPUT="$OPTARG" ;;
    *) usage ;;
  esac
done

if [ -z "$ARGV_ELECTRON_PACKAGE" ] \
  || [ -z "$ARGV_APPLICATION_NAME" ] \
  || [ -z "$ARGV_APPLICATION_DESCRIPTION" ] \
  || [ -z "$ARGV_VERSION" ] \
  || [ -z "$ARGV_COPYRIGHT" ] \
  || [ -z "$ARGV_LICENSE" ] \
  || [ -z "$ARGV_COMPANY_NAME" ] \
  || [ -z "$ARGV_ASAR" ] \
  || [ -z "$ARGV_ICON" ] \
  || [ -z "$ARGV_DOWNLOAD_DIRECTORY" ] \
  || [ -z "$ARGV_OUTPUT" ]
then
  usage
fi

unzip "$ARGV_ELECTRON_PACKAGE" -d "$ARGV_OUTPUT"

mv "$ARGV_OUTPUT/electron.exe" "$ARGV_OUTPUT/$ARGV_APPLICATION_NAME.exe"
cp "$ARGV_LICENSE" "$ARGV_OUTPUT/LICENSE"
echo "$ARGV_VERSION" > "$ARGV_OUTPUT/version"
rm -f "$ARGV_OUTPUT/resources/default_app.asar"

./scripts/build/electron-brand-exe.sh \
  -f "$ARGV_OUTPUT/$ARGV_APPLICATION_NAME.exe" \
  -n "$ARGV_APPLICATION_NAME" \
  -d "$ARGV_APPLICATION_DESCRIPTION" \
  -v "$ARGV_VERSION" \
  -c "$ARGV_COPYRIGHT" \
  -m "$ARGV_COMPANY_NAME" \
  -i "$ARGV_ICON" \
  -w "$ARGV_DOWNLOAD_DIRECTORY"

cp "$ARGV_ASAR" "$ARGV_OUTPUT/resources/app.asar"

if [ -d "$ARGV_ASAR.unpacked" ]; then
  cp -rf "$ARGV_ASAR.unpacked" "$ARGV_OUTPUT/resources/app.asar.unpacked"
fi
