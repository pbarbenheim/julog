$ErrorActionPreference = "Stop"
Push-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
Push-Location ..

Write-Host "######### Installing all dependencies ##########"
flutter pub get --enforce-lockfile
Write-Host "################### Done #######################"
Write-Host ""
Write-Host ""

Push-Location packages/jldb
Write-Host "######## Generating jldb intermediates #########"
dart pub run build_runner build --delete-conflicting-outputs
Write-Host "################ Finished jldb #################"
Write-Host ""
Write-Host ""
Write-Host ""
Pop-Location

Write-Host "######### Generating app intermediates #########"
flutter pub run build_runner build --delete-conflicting-outputs
Write-Host "################# Finished app #################"

Pop-Location
