#!/bin/bash

# Author: https://github.com/hafiz-muhammad

# Variables.
PSD_BROWSERS_DIR="/usr/share/psd/browsers/"
PSD_CONF_FILE="$HOME/.config/psd/psd.conf"
PSD_SERVICE="psd.service"
PSD_REPO_URL="https://github.com/graysky2/profile-sync-daemon"
PSD_BRAVE_RAW_URL="https://raw.githubusercontent.com/graysky2/profile-sync-daemon/master/contrib/brave"
BRAVE_FILE="/usr/share/psd/browsers/brave"
SEPARATOR=$'\n------------------------------------\n'

# Function to check if the user is root.
root_check() {
    if [ "$(whoami)" = "root" ]; then
        echo -e "\e[1;31mDo not run this script as root\e[0m."
        exit 1
    fi
}

root_check

# Function to display info about the script.
script_info() {
    echo -e "\e[1m - \e[0m \e[1m\e[38;5;208mBe sure to install and set up profile-sync-daemon (\e[36m$PSD_REPO_URL\e[38;5;208m) before running this script\e[0m."
    echo -e "\e[1m - \e[0m \e[1m\e[38;5;208mThis script does not install profile-sync-daemon or Brave browser\e[0m."
    echo -e "\e[1m - \e[0m \e[1m\e[38;5;208mAny active browsers that you have added to the BROWSERS array in '$PSD_CONF_FILE' will be closed\e[0m.\n"
}

script_info

# Function to download the brave contrib file from profile-sync-daemon repository and modify psd.conf.
download_and_modify() {
    echo -e "\e[1;4mDownloading and adding brave config to '$PSD_BROWSERS_DIR'\e[0m.\n"
    sudo wget -nc -P $PSD_BROWSERS_DIR "$PSD_BRAVE_RAW_URL"
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32mDownload successful\e[0m."
        echo "Location of downloaded: '$BRAVE_FILE'."

        # Check if psd.conf exists.
        if [ -f "$PSD_CONF_FILE" ]; then

            echo -e "\n$SEPARATOR"

            # Modify psd.conf.
            echo -e "\e[1mModifying '$PSD_CONF_FILE'\e[0m."
            #
            # Add '#  brave' to possible values list in psd.conf.
            if ! grep -q "#  brave" "$PSD_CONF_FILE"; then
                sed -i '/# Possible values:/a #  brave' "$PSD_CONF_FILE"
            fi
            echo " - Added '#  brave' to possible values list in '$PSD_CONF_FILE'."
            #
            # Add 'brave' to BROWSERS array in psd.conf.
            if grep -q "#BROWSERS=" "$PSD_CONF_FILE"; then
                sed -i 's/#BROWSERS=/BROWSERS=/g' "$PSD_CONF_FILE"
            elif grep -q "#BROWSER=(" "$PSD_CONF_FILE"; then
                sed -i 's/#BROWSER=(/BROWSER=(/g' "$PSD_CONF_FILE"
            fi
            #
            if grep -q "BROWSERS=()" "$PSD_CONF_FILE"; then
                sed -i 's/BROWSERS=()/BROWSERS=(brave)/g' "$PSD_CONF_FILE"
            elif grep -q "BROWSERS=(" "$PSD_CONF_FILE"; then
                sed -i 's/BROWSERS=(/BROWSERS=(brave /g' "$PSD_CONF_FILE"
            fi
            echo " - Added 'brave' to BROWSERS array in '$PSD_CONF_FILE'."

            echo -e "$SEPARATOR"

            # Restart psd.service.
            echo -e "\e[1mAttempting to restart $PSD_SERVICE\e[0m..."
            if systemctl --user restart $PSD_SERVICE; then
                echo -e "\e[1;32m$PSD_SERVICE restart \e[1;37m[\e[1;32m\xE2\x9C\x94\e[1;37m]\e[0m"
            else
                echo -e "\e[1;31m$PSD_SERVICE restart \e[1;37m[\e[1;31m\xE2\x9C\x97\e[1;37m]\e[0m"
            fi
            
            echo -e "$SEPARATOR"

            # Check the status of psd.service.
            echo -e "\e[1;4mChecking $PSD_SERVICE status\e[0m\n."
            systemctl --user status $PSD_SERVICE

            echo -e "$SEPARATOR"

            # Preview profile management based on profile-sync-daemon config file.
            echo -e "\e[1;4mParsing '$PSD_CONF_FILE'\e[0m.\n"
            psd parse

            echo -e "$SEPARATOR"

            echo -e "\e[1;32mCompleted\e[0m.\n"
        else
            echo -e "$SEPARATOR"

            echo -e "\e[1;31m'$PSD_CONF_FILE' not found\e[0m.\n"
            return 1
        fi
    else
        echo -e "\e[1;31mDownload failed\e[0m.\n"
        return 1
    fi
}

download_and_modify
