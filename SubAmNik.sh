#!/bin/bash

intro_banner="
   _____       __    ___              _   ___ __  
  / ___/__  __/ /_  /   |  ____ ___  / | / (_) /__
  \__ \/ / / / __ \/ /| | / __ \`__\/  |/ / / //_/
 ___/ / /_/ / /_/ / ___ |/ / / / / / /|  / / ,<   
/____/\__,_/_.___/_/  |_/_/ /_/ /_/_/ |_/_/_/|_|_v2.0.1 
"
echo "$intro_banner"
echo "#################################################################################################################
# Tools Name: SubAmNik                                                                                          #
# Description: # This script is designed to automate various security tests for a target domain.It takes the    #
#                target domain as  input,  creates an output directory, and runs a series of tests including    #
#                Nmap scan,  subdomain enumeration, subdomain takeover, Nuclei scan, directory  enumeration,    #
#                XSS enumeration, and recon-ng. The script also checks if each test was successful and exits    #
#                if any test fails.                                                                             #
# Author: 0xsaju                                                                                                #
# https://linkedin.com/in/0xsaju                                                                                #
# Version: v_2.0.1                                                                                              #
#################################################################################################################
"

# Function to show banner
show_type_banner () {
    echo "======================================="
    echo "            SCAN TYPE MENU            "
    echo "======================================="
}

show_tools_banner () {
    echo "======================================="
    echo "            SCAN TOOLS MENU            "
    echo "======================================="
}

running_tools_banner () {
echo "======================================="
echo "            RUNNING ALL TOOLS          "
echo "======================================="
}

validate_target() {
  # Check if target is provided
  if [[ -z "$target" ]]; then
    echo "Error: No target domain name or IP address provided."
    return 1
  fi

  # Check if target is a valid domain name
  if ! echo "$target" | grep -Eq "^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"; then
    # Check if target is a valid IP address
    if ! echo "$target" | grep -Eq "^([0-9]{1,3}\.){3}[0-9]{1,3}$"; then
      echo "Error: Invalid domain name or IP address provided."
      return 1
    fi
  fi

  return 0
}


# Take target domain name as input
read -p "Enter target domain/IP address: " target

# Validate target domain name
if ! validate_target; then
  exit 1
fi

# Replace dots with underscores in the target name
directory=${target//./_}

# Create output directory
if [ ! -d "$directory" ]; then
  mkdir "$directory"
fi

# Define tool options
nmap_option=1
subdomain_option=2
subdomain_takeover_option=3
nuclei_option=4
dirsearch_option=5
xss_option=6
reconng_option=7

# # Prompt user for which tools to run
# echo "Select which tools to run:"
# echo "$nmap_option. Network Port Scan with - Nmap"
# echo "$subdomain_option. Subdomain enumeration using Subfinder and Amass"
# echo "$subdomain_takeover_option. Subdomain takeover check using SubOver/Subzy"
# echo "$nuclei_option. Nuclei scan for vulnerabilities"
# echo "$dirsearch_option. Directory enumeration using Dirsearch"
# echo "$xss_option. XSS enumeration using XSStrike"
# echo "$reconng_option. Recon-ng for OSINT"

# Function to run selected scan tools
run_selected_tools () {
    show_tools_banner
    echo "Please select the tools you want to run (comma separated):"
    echo "1. Nmap"
    echo "2. Subfinder/Amass"
    echo "3. Subzy Subdomain Takeover"
    echo "4. Nuclei Scan"
    echo "5. Directory enumeration"
    echo "6. XSS enumeration"
    echo "7. Recon-ng"
    echo "8. Abort scan"
    read -p "Enter your choice: " choice

    # Split comma separated choices into an array
    IFS=',' read -ra choices <<< "$choice"

    # Loop through the array of choices
    for c in "${choices[@]}"; do
        case $c in
            1) echo "Running Nmap..."; nmap_option;;
            2) echo "Running Subfinder and Amass..."; run_subdomain_scan;;
            3) echo "Running Subzy/SubOver..."; run_subdomain_takeover;;
            4) echo "Running Nuclei scan..."; run_nuclei_scan;;
            5) echo "Running Dirsearch..."; run_dirsearch;;
            6) echo "Running XSStrike..."; run_xss_enum;;
            7) echo "Running Recon-ng..."; run_reconng;;
            8) echo "Aborting scan..."; exit;;
            *) echo "Invalid choice: $c";;
        esac
    done
}


nmap_option() {
    echo "Running Nmap scan..."
    nmap -A -sV $target -oA "$directory/nmap"

    if [ $? -eq 0 ]
    then
        echo "Nmap scan completed successfully."
    else
        echo "Nmap scan failed. Exiting."
        exit 1
    fi
}

# Subdomain enumeration with subfinder, amass and httpx
run_subdomain_scan() { 
    echo "Enumerating subdomains with Subfinder and Httpx..."
    subfinder -d $target -o "$directory/subdomains.txt"

    if [ $? -eq 0 ]
    then
        echo "Subdomain enumeration completed successfully."
    else
        echo "Subdomain enumeration failed. Exiting."
        exit 1
    fi

    # Amass
    echo "Running Amass..."
    amass enum -d $target -o "$directory/subdomains_amass.txt" -max-dns-queries 200

    if [ $? -eq 0 ]
    then
        echo "Amass completed successfully."
    else
        echo "Amass failed. Exiting."
        exit 1
    fi

    cat "$directory/subdomains.txt" "$directory/subdomains_amass.txt" | sort -u | httpx -silent -threads 200 -o "$directory/subdomains_live.txt"

    if [ $? -eq 0 ]
    then
        echo "Live subdomain enumeration completed successfully."
    else
        echo "Live subdomain enumeration failed. Exiting."
        exit 1
    fi
}


# Check for subdomain takeover with Subzy
run_subdomain_takeover() {
    echo "Checking for subdomain takeover with Subzy..."
    /Users/sazzad/go/bin/subzy run -targets "$directory/subdomains_live.txt" -o "$directory/subzy_takeover.txt"

    if [ $? -eq 0 ]
    then
        echo "Subdomain takeover check completed successfully."
        grep -E '^\[[\!|\?]' "$directory/subzy_takeover.txt" | awk '{print $2}' > "$directory/subzy_possible_takeover.txt"
        echo "Possible takeover domains:"
        cat "$directory/subzy_possible_takeover.txt"
    else
        echo "Subdomain takeover check failed. Exiting."
        exit 1
    fi
}

# Run Nuclei scan on live subdomains
run_nuclei_scan() {
    echo "Running Nuclei scan on live subdomains..."
    "$nuclei_path" -l "$directory/subdomains_live.txt" \
    -t "$nuclei_path/cnvd/*" \
    -t "$nuclei_path/cves/*" \
    -t "$nuclei_path/default-logins/*" \
    -t "$nuclei_path/dns/*" \
    -t "$nuclei_path/exposed-panels/*" \
    -t "$nuclei_path/exposures/*" \
    -t "$nuclei_path/file/*" \
    -t "$nuclei_path/fuzzing/*" \
    -t "$nuclei_path/headless/*" \
    -t "$nuclei_path/helpers/*" \
    -t "$nuclei_path/iot/*" \
    -t "$nuclei_path/miscellaneous/*" \
    -t "$nuclei_path/misconfiguration/*" \
    -t "$nuclei_path/network/*" \
    -t "$nuclei_path/osint/*" \
    -t "$nuclei_path/ssl/*" \
    -t "$nuclei_path/takeovers/*" \
    -t "$nuclei_path/technologies/*" \
    -t "$nuclei_path/token-spray/*" \
    -t "$nuclei_path/vulnerabilities/*" \
    -t "$nuclei_path/workflows/*" \
    -rate 500 -severity high,medium,low -timeout 10s -o "$directory/target_nuclei.txt"

    if [ $? -eq 0 ]
    then
        echo "Nuclei enumeration completed successfully."
    else
        echo "Nuclei enumeration failed. Exiting."
        exit 1
    fi
}

# Directory enumeration with Dirsearch
run_dirsearch() {
    echo "Running directory enumeration with Dirsearch..."
    python3 /usr/local/bin/dirsearch.py -L "$directory/subdomains_live.txt" -e php,asp,aspx,jsp,html,txt -w /usr/local/bin/DirBuster-Lists/directory-list-2.3-medium.txt -t 50 -o "$directory/dirsearch.txt"

    if [ $? -eq 0 ]
    then
        echo "Directory enumeration completed successfully."
    else
        echo "Directory enumeration failed. Exiting."
        exit 1
    fi
}

# XSS enumeration with XSStrike
run_xss_enum() {
    echo "Running XSS enumeration with XSStrike..."
    python /Users/sazzad/VAPT/XSStrike/xsstrike.py -u https://$target -l "$directory/xss.txt"

    if [ $? -eq 0 ]
    then
        echo "XSS enumeration completed successfully."
    else
        echo "XSS enumeration failed. Exiting."
        exit 1
    fi
}

# Recon-ng
run_reconng() {
    echo "Running Recon-ng..."
    recon-ng -r "$directory/recon-ng.txt" -x "workspace $target; set SOURCE $target; set DOMAIN $target; set COMPANY_NAME $target; set NAMESERVER 8.8.8.8; set BING_API_KEY <insert api key>; set GOOGLE_API_KEY <insert api key>; set FULLCONTACT_API_KEY <insert api key>; set HUNTER_API_KEY <insert api key>; set PASSWORDS <insert passwords file>; run all; exit;"

    if [ $? -eq 0 ]
    then
        echo "Recon-ng completed successfully."
    else
        echo "Recon-ng failed. Exiting."
        exit 1
    fi
}

# Directory enumeration with Dirsearch
run_dirsearch(){
    echo "Running directory enumeration with Dirsearch..."
    python3 /Users/sazzad/VAPT/dirsearch/dirsearch.py -L "$directory/subdomains_live.txt" -e php,asp,aspx,jsp,html,txt -w /usr/local/bin/DirBuster-Lists/directory-list-2.3-medium.txt -t 50 -o "$directory/dirsearch.txt"

    if [ $? -eq 0 ]
    then
        echo "Directory enumeration completed successfully."
    else
        echo "Directory enumeration failed. Exiting."
        exit 1
    fi
}


#  Aquatone
# echo "Running Aquatone..."
# cat "$directory/subdomains_live.txt" | aquatone -out "$directory/aquatone"

# if [ $? -eq 0 ]
# then
#     echo "Aquatone completed successfully."
# else
#     echo "Aquatone failed. Exiting."
#     exit 1
# fi

# Function to run all scan tools
run_all_tools() {
    running_tools_banner
    nmap_option
    run_subdomain_scan
    run_subdomain_takeover
    run_nuclei_scan
    run_dirsearch
    run_xss_enum
    run_reconng
}

# Main program
show_type_banner
echo "Please select an option:"
echo "1. Run all scan tools"
echo "2. Select specific scan tools"
echo "3. Quit"
read -p "Enter your choice: " choice
case $choice in
    1) run_all_tools;;
    2) run_selected_tools;;
    3) echo "Quitting..."; exit;;
    *) echo "Invalid choice! Quitting..."; exit;;
esac

