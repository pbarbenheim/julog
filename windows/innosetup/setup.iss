[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; Excludes: "*.zip"; DestDir: "{app}"; Flags: recursesubdirs
Source: "..\..\LICENSE"; DestDir: "{app}"; Flags: isreadme
Source: "..\..\README.md"; DestDir: "{app}"; Flags: isreadme

[Setup]
AppName=Julog
AppVerName=Julog 1.0
DefaultDirName={autopf}\Julog
DefaultGroupName=Julog
ChangesAssociations=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Icons]
Name: "{group}\Julog"; Filename: "{app}\julog.exe"; WorkingDir: "{app}"
Name: "{userdesktop}\Julog"; Filename: "{app}\julog.exe"; WorkingDir: "{app}"

[Languages]
Name: "de"; MessagesFile: "compiler:languages\German.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[Registry]
Root: HKCR; Subkey: ".jfdb"; ValueType: string; ValueName: ""; \
  ValueData: "JFDB.File"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "JFDB.File"; ValueType: string; ValueName: ""; \
  ValueData: "Ein Jugendfeuerwehr Julog"; Flags: uninsdeletekey
Root: HKCR; Subkey: "JFDB.File\DefaultIcon"; ValueType: string; \
  ValueName: ""; ValueData: "{app}\julog.exe,0"
Root: HKCR; Subkey: "JFDB.File\shell\open\command"; \
  ValueType: string; ValueName: ""; \
  ValueData: """{app}\julog.exe"" ""%1"""
Root: HKCR; Subkey: "JFDB.File\shell\open"; ValueType: string; \
  ValueName: ""; ValueData: "Mit Julog öffnen"
Root: HKCR; Subkey: "JFDB.File\shell"; ValueType: string; \
  ValueName: ""; ValueData: "open"
