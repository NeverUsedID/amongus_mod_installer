
<#
Installiert ausgewaehlte Mods und bietet die Moeglichkeit an, Crewlink zu installieren, wenn keinen Crewlinkconfig gefunden wird. Setzt den Crewlinkserver auf Standard zurueck.

HELP:

#Ausfuehren, wenn scripte verboten sind:

Moeglichkeit 1:
Eingabeaufforderung oeffnen und folgenden Befehl ausfuehren (Pfad zur heruntergeladenenen Datei anpassen) 
powershell -ExecutionPolicy ByPass -File C:\Users\username\Downloads\Install_ExtraRoles.ps1

Moeglichkeit 2:
Powershell starten und set-executionpolicy remotesigned ausfÃ¼hren. In Zukunft kann das Script dann direket ausgefÃ¼hrt werden.
#>

Param (
[String]$releaseid = "",
[String]$modid = "",
[String]$streamer = "NeverUsedID" #Streamer wird fuer den Orndernamen verwendet, damit nicht versehentlich andere Verionen Ueberschrieben werden
)

$version = "V0.4 - NeverUsedID"

#
# Wenn hier der Pfad zu Among us eingetragen wird, entfaellt die Suche nach Among Us, was den installer beschleunigt, vro allem auf nicht SSD Systemen
$amonguspath=""

#Crewlink URL
$crewlinkurl="https://github.com/OhMyGuus/BetterCrewLink/releases/download/v2.4.0/Better-CrewLink-Setup-2.4.0.exe"
$crewlinkserver = "https://bettercrewl.ink"

#List your mods here with relative Github Download paths:
#Hier koennen die Mods mit relativen Githubpfaden angegeben werden, die installiert werden koennen.
$modurls = @{}
$modurls.add("ExtraRoles", "/NotHunter101/ExtraRolesAmongUs/releases")
$modurls.add("TheOtherRoles", "/Eisbison/TheOtherRoles/releases")
$modurls.add("TownOfUs", "/slushiegoose/Town-Of-Us/releases")


########
# Main #
########

#set default values 
$defaultDisk="C:"
$AmongUsDisk=""
$steamappsfolders =""

#Show Version
write-host "Among Us Mod Downloader - $version" -ForegroundColor green

#Ask for mod number to install it later
$modnumber = 0
ForEach ( $mod in $modurls.Keys ) {
  write-host "$modnumber - $mod"
  $modnumber++
}
if ( $modId -eq "" ) {
  $modId = read-host "Welchen Mod willst du installieren (Nummer angeben)?"
}
$mod = $modurls.keys | select -index $modId

#URLs bauen
$githubUrl = "https://github.com"
$modSubUrl = $modurls.Values | select -index $modId
$modurl = "$githubUrl$modSubUrl"

$folderExtension = "$($mod) - $($streamer)"

#Get Releases from Github latest
$latestReleaseContent = Invoke-WebRequest "$modUrl/latest" | Select-String "releases/download"
$latestReleaseContent = $latestReleaseContent.ToString()
$releases = @()
#regex to get Zip Download URL
$modurlregex = ".*" + "$($modSubUrl.Replace("/", "\/"))" + "(.*.zip).*"

#Search for Zipfiles on release page
foreach ( $line in $latestReleaseContent.split("`n")) {
  if ( $($line |  Select-String "releases/download" | Select-String ".zip") -match ".zip" ) {
    $releases += ($line |  Select-String "releases/download" | Select-String ".zip") -replace "$modurlregex", '$1'
  }
}

#Ask which releas should be downloaded
$releasenumber = 0
ForEach ( $release in $releases ) {
  write-host "$releasenumber - $release"
  $releasenumber++
}
if ( $releaseId -eq "" -and $releases.Length -ne "1"  ) {
  $releaseId = read-host "Welches Release soll genutzt werden, meisst is es `"0`"."
} else {
  $releaseId = 0
}
$modDownloadUrl = "$modurl$($releases[$releaseId])"

# Search Among Us folder on local system
$installationFound = $false
if ( $amonguspath -eq "" ) {
#check default Steam folder
  if ( test-path "C:\Program Files (x86)\Steam\steamapps\common\Among Us" ) {
    $amonguspath = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
    $installationFound = $true
    Write-host "Among us gefunden:"
    Write-Host "$amonguspath" -ForegroundColor Magenta
  } else {
    #search Amonug us on selected disk
    write-host "INFO: Among Us nicht gefunden - Es muss automatisch gesucht werden!" -ForegroundColor Yellow
    write-host "INFO: Among Us Pfad kann im Script angegeben werden, dann wird die installation stark beschleunigt." -ForegroundColor Cyan
    if (!($AmongUsDisk = Read-Host "Bitte das Laufwerk auf dem Steam bzw. die Bibliothek installiert ist angeben (z.B. `"D:`") - Enter druecken fuer`"$defaultDisk`"")) { $AmongUsDisk= $defaultDisk }
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

#Check if a BetterCrewlink Config exists and ask for installation of Crewlink, if not.
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
    Write-host "Setup wird ausgefuehrt, einfach durchklicken" -ForegroundColor Cyan
    Start-Process BetterCrewLinkSetup.exe -wait
  }
}


#Install Among Us Mod, if Among us is found
if ( $installationFound ) {
  #
  # Download mod
   
  Write-host "Mod wird heruntergeladen" -ForegroundColor Cyan
  Invoke-WebRequest -Uri $modDownloadurl -OutFile "$mod.zip"
  Write-host "Mod wird entpackt" -ForegroundColor Cyan
  Expand-Archive -LiteralPath "$mod.zip" -DestinationPath "$mod" -force
  Write-host "Mod wird in $amonguspath - $folderExtension integriert" -ForegroundColor Cyan
  if (  Test-Path "$amonguspath - $folderExtension.old" -ErrorAction SilentlyContinue ) {
    write-host "Altes Backup des Mods `"$amonguspath - $folderExtension.old`" wird geloescht" 
    Remove-Item -Recurse -Force "$amonguspath - $folderExtension.old"
  }
  if ( Test-Path "$amonguspath - $folderExtension" -ErrorAction SilentlyContinue  ) {
    write-host "Alte Installation gefunden, wird in `"$amonguspath - $folderExtension.old`" umbenannt"
    rename-item "$amonguspath - $folderExtension" "$amonguspath - $folderExtension.old"
  }
  Copy-Item -path "$amonguspath" -Destination "$amonguspath - $folderExtension" -Recurse -Force
  Copy-Item -path "$mod\*" -Destination "$amonguspath - $folderExtension\" -Recurse -Force 
  Write-host "Verknuepfung `"Among Us - $mod - $streamer.lnk`" wird auf Desktop erstellt" -ForegroundColor Cyan
  $linkPath        = Join-Path ([Environment]::GetFolderPath("Desktop")) "Among Us - $mod.lnk"
  $targetPath      = Join-Path "$amonguspath - $folderExtension" "Among Us.exe"
  $link            = (New-Object -ComObject WScript.Shell).CreateShortcut($linkPath)
  $link.TargetPath = $targetPath
  $link.Save()
  $startAmongUs = read-host "Among Us direkt starten? (j/n)"
  if ( $startAmongUs -eq "j" ) {
    . "$amonguspath - $folderExtension\Among Us.exe"
  } else { 
    read-host "Enter zum schliessen"
  }
} else {
  Write-host "Fehler: Among Us nicht gefunden!" -ForegroundColor Yellow
  read-host "Enter zum schliessen"
}
