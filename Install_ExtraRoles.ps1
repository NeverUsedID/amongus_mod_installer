<#
V0.2 - NeverUsedID
HELP:

#Ausfuehren, wenn scripte verboten sind:

Moeglichkeit 1:
Eingabeaufforderung oeffnen und folgenden Befehl ausfuehren (Pfad zur heruntergeladenenen Datei anpassen) 
powershell -ExecutionPolicy ByPass -File C:\Users\username\Downloads\Install_ExtraRoles.ps1
#>

#
# Configuration (change this urls to update Version)

$modurl="https://github.com/NotHunter101/ExtraRolesAmongUs/releases/download/v1.3.1(3.5s)/Extra.Roles.v.1.3.1-3.5s.zip"
$crewlinkurl="https://github.com/OhMyGuus/BetterCrewLink/releases/download/v2.3.6/Better-CrewLink-Setup-2.3.6.exe"

$crewlinkserver = "https://bettercrewl.ink"

#
# Wenn hier der Pfad zu Among us eingetragen wird, entfaellt die Suche nach Among Us, was den installer beschleunigt
$amonguspath=""

#
# Main

$mod = "Extra_Roles_NeverUsedID"
$defaultDisk="C:"
$AmongUsDisk=""

$steamappsfolders =""
$installationFound = $false

if ( $amonguspath -eq "" ) {
  if ( test-path "C:\Program Files (x86)\Steam\steamapps\common\Among Us" ) {
    $amonguspath = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
    $installationFound = $true
    Write-host "Among us gefunden:"
    Write-Host "$amonguspath" -ForegroundColor Magenta
  } else {
    write-host "INFO: Among Us Pfad kann im Script angegeben werden, dann wird die installation stark beschleunigt." -ForegroundColor Cyan
    if (!($AmongUsDisk = Read-Host "Bitte das Laufwerk auf dem Steam bzw. die Bibliothek installiert ist angeben (z.B. `"D:`") - Enter fuer`"$defaultDisk`"")) { $AmongUsDisk= $defaultDisk }
    $steamappsfolders = Get-ChildItem $AmongUsDisk\ -recurse -ErrorAction SilentlyContinue | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match "steamapps"} 
    ForEach ( $steamappsfolder in $steamappsfolders ) {
      if ( test-path "$($steamappsfolder.FullName)\common\Among Us"  ) {
        $amonguspath = "$($steamappsfolder.FullName)\common\Among Us"
        $installationFound = $true
        write-host "Among Us gefunden:"
        Write-Host "$amonguspath" -ForegroundColor Magenta
      }
    }
  }
}

#
# ConfigureBetter Crewlink


function Update-CrewlinkServer {
  if ( $crewlinkconfig.serverURL -ne "$crewlinkserver" ) {
    $updateCrewlinkServer = read-host "Der Bettercrewlink server ist nicht `"$crewlinkserver`" Soll er angepasst werden? (j/n)" 
    if ( $updateCrewlinkServer -eq "j" ) {
      $crewlinkconfig.serverURL = $crewlinkserver
      copy-item "$env:APPDATA\bettercrewlink\config.json" "$env:APPDATA\bettercrewlink\config.json.bak" -force
      # $crewlinkconfig | ConvertTo-Json - | out-file $env:APPDATA\bettercrewlink\config.json
      $file = "$env:APPDATA\bettercrewlink\config.json"
      $regex = '^(.*"serverURL": ).*$'
      $replace ="`t`"serverURL`": `"$crewlinkserver`","
      (Get-Content $env:APPDATA\bettercrewlink\config.json) -replace "$regex", "$replace" | Set-Content $file

    }
  }
}

if ( test-path "$env:APPDATA\bettercrewlink" ) { 
  $crewlinkconfig = get-content "$env:APPDATA\bettercrewlink\config.json" | convertfrom-json
  Update-CrewlinkServer
} else {
  $installbettercrewlink = read-host "Better Crewlink nicht gefunden, soll es heruntergeladen und installiert werden? (j/n)"
  if ( $installbettercrewlink -eq "j" ) {
    #
    # Download Better Crewlink
    Write-host "Better Crewlink wird heruntergeladen" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $crewlinkurl -OutFile BetterCrewLinkSetup.exe
    Write-host "Setup wird ausgeführt, einfach durchklicken" -ForegroundColor Cyan
    Start-Process BetterCrewLinkSetup.exe -wait
  }
}



if ( $installationFound ) {
  #
  # Download mod
   
  Write-host "Mod wird heruntergeladen" -ForegroundColor Cyan
  Invoke-WebRequest -Uri $modurl -OutFile Extra_Roles.zip
  Write-host "Mod wird entpackt" -ForegroundColor Cyan
  Expand-Archive -LiteralPath Extra_Roles.zip -DestinationPath Extra_Roles -force
  Write-host "Mod wird in $amonguspath - $mod integriert" -ForegroundColor Cyan
  Copy-Item -path "$amonguspath" -Destination "$amonguspath - $mod" -Recurse -Force -Container 
  Copy-Item -path "Extra_Roles\*" -Destination "$amonguspath - $mod\" -Recurse -Force 
  Write-host "Verknuepfung `"Among Us - $mod.lnk`" wird auf Desktop erstellt" -ForegroundColor Cyan
  $linkPath        = Join-Path ([Environment]::GetFolderPath("Desktop")) "Among Us - $mod.lnk"
  $targetPath      = Join-Path "$amonguspath - $mod" "Among Us.exe"
  $link            = (New-Object -ComObject WScript.Shell).CreateShortcut($linkPath)
  $link.TargetPath = $targetPath
  $link.Save()
  $startAmongUs = read-host "Among Us direkt starten? (j/n)"
  if ( $startAmongUs -eq "j" ) {
    . "$amonguspath - $mod\Among Us.exe"
  }
} else {
  Write-host "Fehler: Among Us nicht gefunden!" -ForegroundColor Yellow
}
read-host "Enter zum schliessen"




