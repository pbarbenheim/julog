#!/bin/sh
set -e
cd "$(dirname "$0")"

cd ..

echo "############ Testing jlcrypto ##############"
cd packages/jlcrypto
dart test
cd ../..
echo "############ jlcrypto done #################"
echo ""

echo "############## Testing jldb ################"
cd packages/jldb
dart test
cd ../..
echo "############## jldb done ###################"
echo ""

echo "############# Testing app ##################"
flutter test
echo "############# app done #####################"
