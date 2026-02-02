@echo off
cd /d "%~dp0"

cd ..\packages\jlcrypto
echo ####### Installing jlcrypto dependencies #######

dart pub get

echo ############## Finished jlcrypto ###############
echo.
echo.

cd ..\jldb

echo ######### Installing jldb dependencies #########

dart pub get

echo ######## Generating jldb intermediates #########

dart pub run build_runner build --delete-conflicting-outputs

echo ################ Finished jldb #################
echo.
echo.
echo.

cd ..\..

echo ######### Installing app dependencies ##########

flutter pub get --enforce-lockfile

echo ######### Generating app intermediates #########

flutter pub run build_runner build --delete-conflicting-outputs

echo ################# Finished app #################