#!/bin/sh
set -e
cd "$(dirname "$0")"

cd ..
echo "Analyzing all packages..."
flutter analyze
echo "Finished analyzing."
