[Setup]
AppName=Skating System Software
AppVerName=Skating System Software 5.3
AppPublisher=Laurent Riesterer
AppPublisherURL=http://laurent.riesterer.free.fr/skating
AppSupportURL=http://laurent.riesterer.free.fr/skating
AppUpdatesURL=http://laurent.riesterer.free.fr/skating
DefaultDirName={pf}\Skating System Software
DefaultGroupName=Skating System Software
AllowNoIcons=yes
AlwaysCreateUninstallIcon=yes
DisableStartupPrompt=yes
ChangesAssociations=yes
OutputBaseFilename="setup_u_en"


[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4
Name: "quicklaunchicon"; Description: "Create a &Quick Launch icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4; Flags: unchecked


[Files]
Source: "3s_u_en.exe"; DestDir: "{app}"; DestName: "3s.exe"; CopyMode: alwaysoverwrite
Source: "TkTable.dll"; DestDir: "{app}"; CopyMode: alwaysoverwrite

Source: "F:\manual\fr\manual.doc"; DestDir: "{app}"; CopyMode: alwaysoverwrite

Source: "F:\dawson_en.ska"; DestDir: "{app}"; DestName: "dawson.ska"; CopyMode: alwaysoverwrite
Source: "F:\example_en.ska"; DestDir: "{app}"; DestName: "example.ska";  CopyMode: alwaysoverwrite
Source: "F:\example_complex_en.ska"; DestDir: "{app}"; DestName: "example_complex.ska";  CopyMode: alwaysoverwrite
Source: "F:\example_adv_en.ska"; DestDir: "{app}"; DestName: "exemple_advanced.ska";  CopyMode: alwaysoverwrite
Source: "F:\example_ten_en.ska"; DestDir: "{app}"; DestName: "example_10.ska";  CopyMode: alwaysoverwrite

Source: "F:\html\*.*"; DestDir: "{app}\html"; CopyMode: alwaysoverwrite
Source: "F:\tcl_encoding\*.*"; DestDir: "{app}\encoding"; CopyMode: alwaysoverwrite
Source: "F:\data\*.skt"; DestDir: "{app}\data"; CopyMode: alwaysoverwrite
Source: "F:\data\*.lang"; DestDir: "{app}\data"; CopyMode: alwaysoverwrite


[Icons]
Name: "{group}\Skating System Software"; Filename: "{app}\3s.exe"
Name: "{userdesktop}\Skating System Software"; Filename: "{app}\3s.exe"; MinVersion: 4,4; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Skating System Software"; Filename: "{app}\3s.exe"; MinVersion: 4,4; Tasks: quicklaunchicon


[Registry]
Root: HKCR; Subkey: ".ska"; ValueType: string; ValueName: ""; ValueData: "3SFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "3SFile"; ValueType: string; ValueName: ""; ValueData: "Skating files"; Flags: uninsdeletekey
Root: HKCR; Subkey: "3SFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\3s.exe,1"
Root: HKCR; Subkey: "3SFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\3s.exe"" ""%1"""


[Run]
Filename: "{app}\3s.exe"; Description: "Launch Skating System Software"; Flags: nowait postinstall skipifsilent

