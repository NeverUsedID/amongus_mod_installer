# amongus_mod_installer
Among Us Mod Installer Script

Supported Mods:
All Mods Available ad github should be supported, but you need to add the name and relative path to the release files
Already Added mods:
- ExtraRoles
- TheOtherRoles
- TownOfUs


What are the scripts do:
- Search for Among Us Folder
- download the mod (let you select the release Version)
- asks to download and install better crewlink (download path hardcoded in script)
- check if bettercrewlink server is https://bettercrewl.ink
- create a mod folder in the subfolder from the found among us path.
- creates a desktop shortcut
- This script can Update you installed Version

The .bat is only used, because powershell scripts are disabled on most systems per default.


# HowTo
- For Players
 
Download the release and execute the "execute_mod_installer.bat" file. As you downloaded the file from Internet, Windows 10 will ask you if you really want to execute the file. Click on "more informations" and then execute anyway, if that happens.

- For Streamers
 
The Script creates a folder with a "Streamer" name at the end to ensure no existing Version are overwritten. You can Change the tag in the Batchscript.
Its also possible to define which Mod and Version is installed, without asking the User. Just place the bat and ps1 file on yous Discord f.e, for download
