#!/bin/sh
cd "$(dirname "$0")"


cd ../packages/jlcrypto
echo "####### Installing jlcrypto dependencies #######"

flutter pub get

echo "############## Finished jlcrypto ###############"
echo ""
echo ""


cd ../jldb

echo "######### Installing jldb dependencies #########"

flutter pub get

echo "######## Generating jldb intermediates #########"

flutter pub run build_runner build --delete-conflicting-outputs

echo "################ Finished jldb #################"
echo ""
echo ""
echo ""


cd ../..

echo "######### Installing app dependencies ##########"

flutter pub get --enforce-lockfile

echo "######### Generating app intermediates #########"

flutter pub run build_runner build --delete-conflicting-outputs

echo "################# Finished app #################"
