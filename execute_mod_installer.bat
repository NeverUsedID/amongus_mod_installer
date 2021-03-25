@ECHO OFF
SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%Install_Mods.ps1

#you can preset modid and releaseid here to autoinstall required Version.
#PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'" -args -streamer NeverUsedID -releaseid 0 -modid 0;
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'" -args -streamer NeverUsedID;

#PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'"
