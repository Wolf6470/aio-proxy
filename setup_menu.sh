#!/bin/bash

# install requirements
if ! command -v qrencode &> /dev/null; then
    echo "qrencode is not installed. Installing..."
    sudo apt-get install qrencode -y

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "qrencode is now installed."
    else
        echo "Error: Failed to install qrencode."
    fi
else
    echo "qrencode is already installed."
fi

if ! command -v jq &>/dev/null; then
    echo "Installing jq..."
    if ! sudo apt-get install jq -y; then
        echo "Error: Failed to install jq."
        exit 1
    fi
    echo "jq installed successfully."
fi

# Function to display the main menu
display_main_menu() {
    clear
    echo "**********************************************"
    echo -e "\033[1;32m     Main Menu\033[0m"
    echo "**********************************************"
    echo "1. Hysteria"
    echo "2. Hysteria v2"
    echo "3. Tuic"
    echo "0. Exit"
    echo "**********************************************"
}

# Function to display the Hysteria sub-menu
display_hysteria_menu() {
    clear
    echo "**********************************************"
    echo -e "\033[1;32m     Hysteria Menu\033[0m"
    echo "**********************************************"
    echo "1. Install/Update"
    echo "2. Change Parameters"
    echo "3. Show Configs"
    echo "4. Delete"
    echo "0. Back to Main Menu"
    echo "**********************************************"
}

# Function to display the Hysteria v2 sub-menu
display_hysteria_v2_menu() {
    clear
    echo "**********************************************"
    echo -e "\033[1;32m     Hysteria v2 Menu\033[0m"
    echo "**********************************************"
    echo "1. Install/Update"
    echo "2. Change Parameters"
    echo "3. Show Configs"
    echo "4. Delete"
    echo "0. Back to Main Menu"
    echo "**********************************************"
}

# Function to display the Tuic sub-menu
display_tuic_menu() {
    clear
    echo "**********************************************"
    echo -e "\033[1;32m     Tuic Menu\033[0m"
    echo "**********************************************"
    echo "1. Install/Update"
    echo "2. Change Parameters"
    echo "3. Show Configs"
    echo "4. Delete"
    echo "0. Back to Main Menu"
    echo "**********************************************"
}


# ----------------------------------------Hysteria stuff------------------------------------------------
run_hysteria_setup() {
    clear
    echo "Running Hysteria Setup..."
    sleep 2
    bash hysteria_setup_script.sh
    read -p "Press Enter to continue..."
}

show_hy_configs() {
    # Determine the user directory based on the user
    if [ "$EUID" -eq 0 ]; then
        user_directory="/root/hy"
    else
        user_directory="/home/$USER/hy"
    fi

    # Check if the directory exists
    if [ -d "$user_directory" ]; then
        # Directory exists, you can add code here to show configs
        echo "Here are the current configurations:"
        
        # Fetch the current configuration values from config.json
        password=$(jq -r '.obfs' "$user_directory/config.json")
        port=$(jq -r '.listen' "$user_directory/config.json" | cut -c 2-)
        
        # show configs

        IPV4=$(curl -s https://v4.ident.me)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to get IPv4 address"
            return
        fi

        IPV6=$(curl -s https://v6.ident.me)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to get IPv6 address" 
            return
        fi

        IPV4_URL="hysteria://$IPV4:$port?protocol=udp&insecure=1&upmbps=100&downmbps=100&obfs=xplus&obfsParam=$password#hysteria"
        IPV6_URL="hysteria://[$IPV6]:$port?protocol=udp&insecure=1&upmbps=100&downmbps=100&obfs=xplus&obfsParam=$password#hysteria"

        echo "----------------config info-----------------"
        echo -e "\e[1;33mPassword: $password\e[0m"
        echo "--------------------------------------------"
        echo
        echo "----------------IP and Port-----------------"
        echo -e "\e[1;33mPort: $port\e[0m"
        echo -e "\e[1;33mIPv4: $IPV4\e[0m"
        echo -e "\e[1;33mIPv6: $IPV6\e[0m"
        echo "--------------------------------------------"
        echo
        echo "----------------Hysteria Config IPv4-----------------"
        echo -e "\e[1;33m$IPV4_URL\e[0m"
        qrencode -t ANSIUTF8 "$IPV4_URL"
        echo "--------------------------------------------"
        echo
        echo "-----------------Hysteria Config IPv6----------------"
        echo -e "\e[1;33m$IPV6_URL\e[0m"
        qrencode -t ANSIUTF8 "$IPV6_URL"
        echo "--------------------------------------------"
    else
        echo "Hysteria directory does not exist. Please install Hysteria first."
    fi

    # Prompt for any input to continue
    read -p "Press Enter to continue..."
}

change_hy_parameters() {
    # Determine the user directory based on the user
    if [ "$EUID" -eq 0 ]; then
        user_directory="/root/hy"
    else
        user_directory="/home/$USER/hy"
    fi

    # Check if the directory exists
    if [ -d "$user_directory" ]; then
        # Directory exists, you can add code here to change parameters
        echo "Hysteria directory exists. You can change parameters here."
        
        # Fetch the current configuration values from config.json
        port=$(jq -r '.listen' "$user_directory/config.json" | cut -c 2-)
        password=$(jq -r '.obfs' "$user_directory/config.json")
        
        # Prompt for new values
        read -p "Enter a new listening port [$port]: " new_port
        read -p "Enter a new obfuscation password [$password]: " new_password
        
        # Update the config.json file with the new or existing values
        jq ".listen = \":${new_port:-$port}\" | .obfs = \"$new_password\"" "$user_directory/config.json" > tmp_config.json
        mv tmp_config.json "$user_directory/config.json"

        systemctl restart hy

        echo "Parameters updated successfully."
        show_hy_configs
    else
        echo "Hysteria directory does not exist. Please install Hysteria first."
    fi

    # Prompt for any input to continue
    read -p "Press Enter to continue..."
}

delete_hysteria() {
    clear
    echo "Deleting Hysteria Proxy..."
    sleep 2
    rm -r ../hy
    systemctl stop hy
    systemctl disable hy
    read -p "Press Enter to continue..."
}
# ----------------------------------------Hysteria V2 stuff------------------------------------------------
run_hysteria_v2_setup() {
    clear
    echo "Running Hysteria v2 Setup..."
    sleep 2
    bash hy2_setup_script.sh  # Use the actual script name and path
    read -p "Press Enter to continue..."
}
delete_hysteria_v2() {
    clear
    echo "Deleting Hysteria v2 Proxy..."
    sleep 2
    rm -r ../hy2
    systemctl stop hy2
    systemctl disable hy2
    read -p "Press Enter to continue..."
}
# ----------------------------------------TUIC stuff------------------------------------------------
run_tuic_setup() {
    clear
    echo "Running Tuic Setup..."
    sleep 2
    bash tuic_setup_script.sh
    read -p "Press Enter to continue..."
}
show_tuic_configs() {
    # Define TUIC_FOLDER and CONFIG_FILE locally within the function
    local TUIC_FOLDER
    local CONFIG_FILE
    
    # Determine the appropriate TUIC_FOLDER based on the user
    if [ "$EUID" -eq 0 ]; then
        TUIC_FOLDER="/root/tuic"
    else
        TUIC_FOLDER="$HOME/tuic"
    fi
    
    CONFIG_FILE="$TUIC_FOLDER/config.json"

    # Check if TUIC directory exists
    if [ -d "$TUIC_FOLDER" ]; then
        # Directory exists, you can add code here to show configs
        echo "Here are the current configurations:"
        
        # Fetch relevant configuration values using jq
        PORT=$(jq -r '.server' "$CONFIG_FILE" | awk -F ':' '{print $NF}')
        CONGESTION_CONTROL=$(jq -r '.congestion_control' "$CONFIG_FILE")
        UUID=$(jq -r '.users | keys[0]' "$CONFIG_FILE")
        PASSWORD=$(jq -r ".users[\"$UUID\"]" "$CONFIG_FILE")

        # Display the configuration values
        # Get public IPs
        IPV4=$(curl -s https://v4.ident.me)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to get IPv4 address"
            return
        fi

        IPV6=$(curl -s https://v6.ident.me)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to get IPv6 address" 
            return
        fi
        # Generate and print URLs
        IPV4_URL="tuic://$UUID:$PASSWORD@$IPV4:$PORT/?congestion_control=$CONGESTION_CONTROL&udp_relay_mode=native&alpn=h3,spdy/3.1&allow_insecure=1#Tuic"

        IPV6_URL="tuic://$UUID:$PASSWORD@[$IPV6]:$PORT/?congestion_control=$CONGESTION_CONTROL&udp_relay_mode=native&alpn=h3,spdy/3.1&allow_insecure=1#Tuic"

        echo "----------------config info-----------------"
        echo -e "\e[1;33mUUID: $UUID\e[0m"
        echo -e "\e[1;33mPassword: $PASSWORD\e[0m"
        echo "--------------------------------------------"
        echo
        echo "----------------IP and Port-----------------"
        echo -e "\e[1;33mPort: $PORT\e[0m"
        echo -e "\e[1;33mIPv4: $IPV4\e[0m"
        echo -e "\e[1;33mIPv6: $IPV6\e[0m"
        echo "--------------------------------------------"
        echo
        echo "----------------Tuic Config IPv4-----------------"
        echo -e "\e[1;33m$IPV4_URL\e[0m"
        qrencode -t ANSIUTF8 "$IPV4_URL"
        echo "--------------------------------------------"
        echo
        echo "-----------------Tuic Config IPv6----------------"
        echo -e "\e[1;33m$IPV6_URL\e[0m"
        qrencode -t ANSIUTF8 "$IPV6_URL"
        echo "--------------------------------------------"
        read -p "Press Enter to continue..."

    else
        echo "TUIC directory does not exist. Please install TUIC first."
        read -p "Press Enter to continue..."
    fi
}
change_tuic_parameters() {
    # Define TUIC_FOLDER and CONFIG_FILE locally within the function
    local TUIC_FOLDER
    local CONFIG_FILE
    
    # Determine the appropriate TUIC_FOLDER based on the user
    if [ "$EUID" -eq 0 ]; then
        TUIC_FOLDER="/root/tuic"
    else
        TUIC_FOLDER="$HOME/tuic"
    fi
    
    CONFIG_FILE="$TUIC_FOLDER/config.json"

    # Check if TUIC directory exists
    if [ -d "$TUIC_FOLDER" ]; then
        # Directory exists, you can add code here to change parameters
        echo "TUIC directory exists. You can change parameters here."
        
        # Fetch the current configuration values
        PORT=$(jq -r '.server' "$CONFIG_FILE" | awk -F ':' '{print $NF}')
        CONGESTION_CONTROL=$(jq -r '.congestion_control' "$CONFIG_FILE")
        UUID=$(jq -r '.users | keys[0]' "$CONFIG_FILE")
        PASSWORD=$(jq -r ".users[\"$UUID\"]" "$CONFIG_FILE")
        
        # Prompt for new values
        read -p "Enter a new port number [$PORT]: " NEW_PORT
        read -p "Enter a new congestion control [$CONGESTION_CONTROL]: " NEW_CONGESTION
        read -p "Enter a new password [$PASSWORD]: " NEW_PASSWORD
        
        # Update the config file with the new values
        jq ".server = \"[::]:${NEW_PORT:-$PORT}\" | .congestion_control = \"${NEW_CONGESTION:-$CONGESTION_CONTROL}\" | .users[\"$UUID\"] = \"${NEW_PASSWORD:-$PASSWORD}\"" "$CONFIG_FILE" > tmp_config.json
        mv tmp_config.json "$CONFIG_FILE"
        
        echo "Parameters updated successfully."
        systemctl restart tuic
        show_tuic_configs
        read -p "Press Enter to continue..."
    else
        echo "TUIC directory does not exist. Please install TUIC first."
        read -p "Press Enter to continue..."
    fi
}
delete_tuic() {
    clear
    echo "Deleting Tuic Proxy..."
    sleep 2
    rm -r ../tuic
    systemctl stop tuic
    systemctl disable tuic
    read -p "Press Enter to continue..."
}

# ----------------------------------------Menu options------------------------------------------------
while true; do
    display_main_menu
    read -p "Enter your choice: " main_choice

    case $main_choice in
        1) # Hysteria
            while true; do
                display_hysteria_menu
                read -p "Enter your choice: " hysteria_choice

                case $hysteria_choice in
                    1) # Install/Update
                        run_hysteria_setup
                        ;;
                    2) # Change Parameters
                        change_hy_parameters
                        ;;
                    3) # Show Configs
                        show_hy_configs
                        ;;
                    4) # Delete
                        delete_hysteria
                        ;;
                    0) # Back to Main Menu
                        break
                        ;;
                    *) echo "Invalid choice. Please select a valid option." ;;
                esac
            done
            ;;
        2) # Hysteria v2
            while true; do
                display_hysteria_v2_menu
                read -p "Enter your choice: " hysteria_v2_choice

                case $hysteria_v2_choice in
                    1) # Install/Update
                        run_hysteria_v2_setup
                        ;;
                    2) # Change Parameters
                        # Add code for changing parameters here
                        ;;
                    3) # Show Configs
                        # Add code for showing configs here
                        ;;
                    4) # Delete
                        delete_hysteria_v2
                        ;;
                    0) # Back to Main Menu
                        break
                        ;;
                    *) echo "Invalid choice. Please select a valid option." ;;
                esac
            done
            ;;
        3) # Tuic
            while true; do
                display_tuic_menu
                read -p "Enter your choice: " tuic_choice

                case $tuic_choice in
                    1) # Install/Update
                        run_tuic_setup
                        ;;
                    2) # Change Parameters
                        change_tuic_parameters
                        ;;
                    3) # Show Configs
                        show_tuic_configs
                        ;;
                    4) # Delete
                        delete_tuic
                        ;;
                    0) # Back to Main Menu
                        break
                        ;;
                    *) echo "Invalid choice. Please select a valid option." ;;
                esac
            done
            ;;
        0) # Exit
            clear
            echo "Exiting..."
            exit
            ;;
        *) echo "Invalid choice. Please select a valid option." ;;
    esac
done