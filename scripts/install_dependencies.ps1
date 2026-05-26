$ErrorActionPreference = "Stop"
Push-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

Push-Location ../packages/jlcrypto

Write-Host "####### Installing jlcrypto dependencies #######"
dart pub get
Write-Host "############## Finished jlcrypto ###############"
Write-Host ""
Write-Host ""

Pop-Location
Push-Location ../packages/jldb

Write-Host "######### Installing jldb dependencies #########"
dart pub get

Write-Host "######## Generating jldb intermediates #########"
dart pub run build_runner build --delete-conflicting-outputs

Write-Host "################ Finished jldb #################"
Write-Host ""
Write-Host ""
Write-Host ""

Pop-Location
Pop-Location

Write-Host "######### Installing app dependencies ##########"
flutter pub get --enforce-lockfile

Write-Host "######### Generating app intermediates #########"
flutter pub run build_runner build --delete-conflicting-outputs

Write-Host "################# Finished app #################"