#!/bin/sh
set -e
cd "$(dirname "$0")"

cd ../packages/jlcrypto
echo "Analyzing jlcrypto package..."
dart analyze
echo "Finished analyzing jlcrypto."
echo ""
echo ""

cd ../jldb
echo "Analyzing jldb package..."
dart analyze
echo "Finished analyzing jldb."
echo ""
echo ""
cd ../..
echo "Analyzing main app..."
flutter analyze
echo "Finished analyzing main app."