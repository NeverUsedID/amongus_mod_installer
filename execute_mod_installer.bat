@ECHO OFF
SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%Install_Mods.ps1

rem you can preset modid and releaseid here to autoinstall required Version / "rem" is to skip lines in execution
rem PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'" -args -args -releaseid 0 -modid 0;

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'"
