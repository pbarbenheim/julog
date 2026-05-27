#!/bin/sh
set -e
cd "$(dirname "$0")"

cd ..

echo "######### Installing all dependencies ##########"
flutter pub get --enforce-lockfile
echo "################### Done #######################"
echo ""
echo ""

cd packages/jldb
echo "######## Generating jldb intermediates #########"
dart pub run build_runner build --delete-conflicting-outputs
echo "################ Finished jldb #################"
echo ""
echo ""
echo ""

cd ../..

echo "######### Generating app intermediates #########"
flutter pub run build_runner build --delete-conflicting-outputs
echo "################# Finished app #################"
