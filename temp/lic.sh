#!/bin/bash
# Function to print the ASCII art
print_logo() {
    echo -e "       _ _             _ _          _   _"
    echo -e "  __ _| | |_ __  _   _| | | ___  __| | (_)_ __"
    echo -e " / _\` | | | '_ \\| | | | | |/ _ \\/ _\` | | | '_ \\"
    echo -e "| (_| | | | | | | |_| | | |  __/ (_| |_| | | | |"
    echo -e " \\__,_|_|_|_| |_|\\__,_|_|_|\\___|\\__,_(_)_|_| |_|"
}

# Function to print in a specific format
print_message() {
    echo -e "\n\033[1;34m$1\033[0m" # Blue text
}

# Get dynamic system information
WEBSITE="AllNulled.in"
SERVER_IP=$(hostname -I | awk '{print $1}') # Get the first IP address
HOSTNAME=$(hostname) # Get the hostname
CPANEL_VERSION=$(cat /usr/local/cpanel/version 2>/dev/null || echo "N/A") # Get cPanel version if exists
KERNEL_VERSION=$(uname -r) # Get the kernel version
LICENSE_STATUS="OK"
LICENSE_EXPIRATION="LIFE-TIME-LICENSE"

# Start the script output

# Simulate checking license status
sleep 1  # Simulate some delay

print_logo
echo -e "                                                           "
echo -e "Website : $WEBSITE"
echo -e "Server IP : $SERVER_IP"
echo -e "Hostname : $HOSTNAME"
echo -e "cPanel version : $CPANEL_VERSION"
echo -e "Kernel version : $KERNEL_VERSION"

echo -e "\n If you have any question connect us on our website."
echo -e "Copyright 2017-2022 $WEBSITE - All rights reserved."
echo -e " --------------------------------------------------------------------"
echo -e "Today : $(date +'%Y/%m/%d')"

# Configuration Values
WHMCS_URL="https://allnulled.in/"
LICENSING_SECRET_KEY="abc123"
LOCALKEYDAYS=15
ALLOWCHECKFAILDAYS=5

# License Key
LICENSEKEY="d1391c06ea81b8b47644083793ffc8ea8b9539d3"
LOCALKEY=""

# Prepare data for the remote check
CHECK_TOKEN=$(date +%s | md5sum | cut -d' ' -f1)
CHECKDATE=$(date +"%Y%m%d")
DOMAIN=$(hostname)
USERSIP=$(hostname -I | awk '{print $1}')
DIRPATH="$(dirname "$(readlink -f "$0")")"
VERIFY_FILEPATH="modules/servers/licensing/verify.php"

# Prepare POST data
POSTFIELDS="licensekey=${LICENSEKEY}&domain=${DOMAIN}&ip=${USERSIP}&dir=${DIRPATH}&check_token=${CHECK_TOKEN}"

# Function to perform remote check
function check_license {
    RESPONSE=$(curl -s -X POST "${WHMCS_URL}${VERIFY_FILEPATH}" --data "${POSTFIELDS}")

    # Check if response is valid
    if [[ $? -ne 0 ]]; then
        echo "Remote Check Failed"
        return 1
    fi

    # Parse response
    local STATUS=$(echo "$RESPONSE" | grep -oP '<status>\K.*?(?=</status>)')
    local MD5HASH=$(echo "$RESPONSE" | grep -oP '<md5hash>\K.*?(?=</md5hash>)')

    if [[ -z "$STATUS" ]]; then
        echo "Invalid License Server Response"
        return 1
    fi

    # Check status
    case "$STATUS" in
        "Active")
            echo "License is Active"
            begin_installation
            echo -e "License Expire : $LICENSE_EXPIRATION"

            echo -e "\nUpdating local license info..."
            echo -e "\ncPanel license status : $LICENSE_STATUS"
            echo -e "cPanel licensing system has been installed. Enjoy"
            print_message "Thank you for using $WEBSITE licensing system!"
            echo -e " --------------------------------------------------------------------"

            ;;
        "Invalid")
            echo "License key is Invalid"
            return 1
            ;;
        "Expired")
            echo "License key is Expired"
            return 1
            ;;
        "Suspended")
            echo "License key is Suspended"
            return 1
            ;;
        *)
            echo "Invalid Response"
            return 1
            ;;
    esac

    # MD5 Checksum Verification
    if [[ "$MD5HASH" != "$(echo -n "${LICENSING_SECRET_KEY}${CHECK_TOKEN}" | md5sum | cut -d' ' -f1)" ]]; then
        echo "MD5 Checksum Verification Failed"
        return 1
    fi
    echo "License check successful."
}

# Define begin_installation function
function begin_installation {
    echo "Beginning installation process..."
    # Add installation steps here, e.g., setting up directories, copying files, etc.

    if ! command -v proxychains4 &> /dev/null; then
        echo "Proxychains4 not found. Installing..." #> /dev/null 2>&1

        # Update package list and install required packages
        #sudo apt update
        #sudo apt install -y git build-essential

        # Clone the proxychains-ng repository, build, and install
        git clone https://github.com/rofl0r/proxychains-ng.git #> /dev/null 2>&1
        cd proxychains-ng || exit #> /dev/null 2>&1
        ./configure #> /dev/null 2>&1
        make #> /dev/null 2>&1
        make install #> /dev/null 2>&1
        make install-config  #> /dev/null 2>&1

        # Clean up
        cd .. #> /dev/null 2>&1
        rm -rf proxychains-ng #> /dev/null 2>&1
        echo "Proxychains4 has been successfully installed." #> /dev/null 2>&1
        
        newport=$((RANDOM % 20001 + 30000))

        # Define the configuration content
        proxychains_config="strict_chain
proxy_dns
[ProxyList]
socks5 127.0.0.1 $newport"

        # Write to proxychains.conf
        echo "$proxychains_config" > proxychains.conf

    else
        # Define the path to the SSH key in the current directory
        KEY_PATH="./id_rsa"

        # Check if the SSH key pair exists in the current directory
        if [ -f "$KEY_PATH" ] && [ -f "${KEY_PATH}.pub" ]; then
            echo "SSH key pair already exists in the current directory."
        else
            echo "SSH key pair not found in the current directory. Generating a new SSH key pair..."
            ssh-keygen -b 2048 -t rsa -f "$KEY_PATH" -q -N ""
            echo "SSH key pair generated successfully in the current directory."
        fi
        # Generate a random port between 30000 and 50000
        newport=$((RANDOM % 20001 + 30000))
        
        proxychains_config="strict_chain
proxy_dns
[ProxyList]
socks5 127.0.0.1 $newport"

        ssh -D $newport -f -i id_rsa  -C -q -N -oStrictHostKeyChecking=no root@185.239.209.8
        proxychains4 -q -f proxychains.conf /usr/local/cpanel/cpkeyclt --force

        # Write to proxychains.conf
        echo "$proxychains_config" > proxychains.conf
        echo "Proxychains4 is already installed."
    fi
}

# Call the function
check_license