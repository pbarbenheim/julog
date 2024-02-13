[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs
Source: "..\..\LICENSE"; DestDir: "{app}"; Flags: isreadme
Source: "..\..\README.md"; DestDir: "{app}"; Flags: isreadme

[Setup]
AppName=Dienstbuch
AppVerName=Dienstbuch 0.7
DefaultDirName={pf}\Dienstbuch
DefaultGroupName=Dienstbuch
ChangesAssociations=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Icons]
Name: "{group}\Dienstbuch"; Filename: "{app}\dienstbuch.exe"; WorkingDir: "{app}"
Name: "{userdesktop}\Dienstbuch"; Filename: "{app}\dienstbuch.exe"; WorkingDir: "{app}"

[Languages]
Name: "de"; MessagesFile: "compiler:languages\German.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[Registry]
Root: HKCR; Subkey: ".jfdb"; ValueType: string; ValueName: ""; \
  ValueData: "JFDB.File"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "JFDB.File"; ValueType: string; ValueName: ""; \
  ValueData: "Ein Jugendfeuerwehr Dienstbuch"; Flags: uninsdeletekey
Root: HKCR; Subkey: "JFDB.File\DefaultIcon"; ValueType: string; \
  ValueName: ""; ValueData: "{app}\dienstbuch.exe,0"
Root: HKCR; Subkey: "JFDB.File\shell\open\command"; \
  ValueType: string; ValueName: ""; \
  ValueData: """{app}\dienstbuch.exe"" ""%1"""
Root: HKCR; Subkey: "JFDB.File\shell\open"; ValueType: string; \
  ValueName: ""; ValueData: "Mit Dienstbuch öffnen"
Root: HKCR; Subkey: "JFDB.File\shell"; ValueType: string; \
  ValueName: ""; ValueData: "open"
