<#Hilfe:
#Ausführen, wenn scripte verboten sind:

Möglichkeit 1:
Eingabeaufforderung öffnen und folgenden Befehl ausführen (Pfad zur heruntergeladenenen Datei anpassen) 
powershell -ExecutionPolicy ByPass -File C:\Users\rafael\Downloads\Install_ExtraRoles.ps1
#>


#Wenn hier der Pfad zu Among us eingetragen wird, entfällt die Suche nach Among Us, was den installer beschleunigt
$amonguspath=""
$modurl="https://github.com/NotHunter101/ExtraRolesAmongUs/releases/download/v1.3.1(3.5s)/Extra.Roles.v.1.3.1-3.5s.zip"
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
    if (!($AmongUsDisk = Read-Host "Bitte das Laufwerk auf dem Steam bzw. die Bibliothek installiert ist angeben! z.B. `"D:`" Einfach Enter drücken wenn es `"$defaultDisk`" ist")) { $AmongUsDisk= $defaultDisk }
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
  Write-host "Verknüpfung `"Among Us - $mod.lnk`" wird erstellt" -ForegroundColor Cyan
  $linkPath        = Join-Path ([Environment]::GetFolderPath("Desktop")) "Among Us - $mod.lnk"
  $targetPath      = Join-Path "$amonguspath - $mod" "Among Us.exe"
  $link            = (New-Object -ComObject WScript.Shell).CreateShortcut($linkPath)
  $link.TargetPath = $targetPath
  $link.Save()
  $startAmongUs = read-host "Among us direkt starten? (j/n)"
  if ( $startAmongUs -eq "j" ) {
    . "$amonguspath - $mod\Among Us.exe"
  }
} else {
  Write-host "Fehler: Among Us nicht gefunden!" -ForegroundColor Yellow
}
read-host "Enter zum schliessen"




