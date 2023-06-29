#!/bin/bash
# -----------------------------------------------------------
# Backup Menu
#
# Jim Gifford   : Author
# Email         : giffordj@gmail.com
# -----------------------------------------------------------
# Revision:     1.00    Initial Release
# -----------------------------------------------------------
#
# Function:	text_seperator
# Purpose:	Add a text seperator
#
function text_seperator {
  seperator=$1
  for i in $(seq 1 ${WIDTH}); do
    echo -n "-"
  done
  echo ""
}
#
# Function:	center_text
# Purpose:	Center Text on Screen
#
function center_text {
  text=$1
  printf "!%*s" $(( (${#text} + ${WIDTH}) / 2)) "$text"
  if [[ `expr ${#text} % 2` == 0 ]]; then
    printf "%*s!\n" $(( (${#text} - (${WIDTH} - 3)) / 2)) ""
  else
    printf "%*s!\n" $(( (${#text} - (${WIDTH} - 2)) / 2)) ""
  fi
}
#
# Function:	install
# Purpose:	Installation of Addons
#
function install {
  #
  # Check to see if file exists
  #
  text_seperator "="
  gamelist_updates=$(find $source_dir/* -name *.xml)
  IFS=$'\n'
  for file in $gamelist_updates; do
    file_emulator=$(echo $file | sed -e "s@$source_dir@@g" | sed -e "s@$(basename $file)@@g")
    echo -e "Checking Files in:\t$file_emulator"
    IFS=$'\n'
    for check_file in $(cat $file | grep -oP "(?<=<path>)[^<]+" | cut -c 3-); do
      if [[ -e $file_emulator/$check_file ]]; then
        echo -e "File Exists:\t\t$check_file"
        continue
      else
        echo -e "Copying:\t\t$check_file"
        xml_path=$(grep -oPm1 "(?<=<path>)[^<]+" $file | cut -c 3-)
        xml_image=$(grep -oPm1 "(?<=<image>)[^<]+" $file | cut -c 3-)
        xml_video=$(grep -oPm1 "(?<=<video>)[^<]+" $file | cut -c 3-)
        if [[ -n "$xml_path" ]]; then
          if [[ -e "$source_dir/$file_emulator/$xml_path" ]] ; then
            cp "$source_dir/$file_emulator/$xml_path" $file_emulator/
          else
            echo -e "ROM File:\t\tMissing"
            echo -e "Skipping:\t\t$xml_path"
            continue
          fi
        else
           echo -e "XML Error:\t\tpath is missing"
           echo -e "Skipping:\t\t$xml_path"
           continue
        fi
        if [[ -n "$xml_image" ]]; then
          if [[ -e "$source_dir/$file_emulator/$xml_image" ]] ; then
            cp "$source_dir/$file_emulator/$xml_image" $file_emulator/
          fi
        else
           echo -e "XML Error:\t\timage is missing"
        fi
        if [[ -n "$xml_video" ]]; then
          if [[ -e "$source_dir/$file_emulator/$xml_video" ]] ; then
            cp "$source_dir/$file_emulator/$xml_video" $file_emulator/
          fi
        else
           echo -e "XML Error:\t\tvideo is missing"
        fi
        echo -e "Updating Gamelist:\t$rom_dir"
        #
        # Make a backup of the backup in case to revert
        #
        echo -e "Backing up Gamelist:\tOriginal"
        if ! [[ -e $file_emulator/gamelist.xml.orig ]]; then
          cp $file_emulator/gamelist.xml $file_emulator/gamelist.xml.orig
        fi
        cp $file_emulator/gamelist.xml $file_emulator/gamelist.xml.temp
        #
        # Remove the XML Closing for gameList
        #
        sed -i '/<\/gameList/d' $file_emulator/gamelist.xml.temp
        #
        # Merge the files together
        #
        cat $file_emulator/gamelist.xml.temp $file > $file_emulator/gamelist.xml
        echo "</gameList>" >> $file_emulator/gamelist.xml
        #
        # Cleanup temp files
        #
        rm $file_emulator/gamelist.xml.temp
      fi
    done
  text_seperator "-"
  done
}
#
# Function:	restore_gamelist
# Purpose:	Restore Original Gamelist.xml
#
function restore_gamelist {
  text_seperator "="
  gamelist_orig=$(find ~/* -name gamelist.xml.orig)
  for file in $gamelist_orig; do
    gamelist=$(echo $file | sed -e 's/\.orig//')
    echo -e "Restoring:\t\t$gamelist"
    cp $file $gamelist
    echo -e "Removing Backup:\t$file"
    rm $file
  done
  text_seperator "-"
}

#
# Function:	main_menu
# Purpose:	Menu for Script
#
function main_menu {
  text_seperator "="
  center_text "Source DIR is $source_dir"
  center_text "Destination DIR is $HOME"
  selection=0
  until [ "$selection" = "4" ]; do
    text_seperator "="
    center_text "Main Menu"
    text_seperator
    printf '!  %-76s!\n' "1.) Install Addons"
    printf '!  %-76s!\n' "2.) Restore Original Gamelist"
    printf '!  %-76s!\n' "3.) Restart Emulation Station"
    text_seperator "-"
    printf '!  %-76s!\n' "4.) Quit"
    text_seperator "-"
    echo -ne "\nEnter Selection: "
    read selection
    echo ""
    case $selection in
      1)     install ;;
      2)     restore_gamelist;;
      3)     sudo systemctl restart autologin@tty1.service ;;
      4)     exit ;;
      *)
        tput setf 4
        echo "Please Select [1 2 3 4]"
        tput setf 4
      ;;
    esac
  done
}
#
# Main Script Start
#
#
# Variables
#
# USB Disk Label - This is the label of USB Drive
#
usb_label=USB_UPDATE
source_dir=$(mount -l | grep $usb_label | cut -f3 -d' ')
#
# Set Display Width
#
WIDTH=80
#
# Start Menu
#
main_menu
