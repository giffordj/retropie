# retropie
Retropie Script

This script in combination with a USB Drive will install new games into Retropie.

The USB Drive must have a label of 'USB_UPDATE', the script will automatically find the drive.

The script was written on Raspberry 4 using Retropie.

File Structure of USB Drive
The file structure of USB drive is a duplicate of /home/pi/Retropie/roms, the games are installed in the emulator directories. Assuming your are adding to apple2 emulator you would have a directory named /home/pi/Retropie/roms/apple2. In this directory you would have the game file and xml to import with the game information. You can also add the sanp and boxart into the approriate directories.

The script will make a backup of the gamelist.xml file prior to the installation of the game.

| Filename | Description |
| :---: | :---
|{gamename}.xml | is the xml that is imported to the existing gamelist.xml, a version of gamelist.xml that is specific to the game being installed
