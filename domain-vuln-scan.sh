#!/bin/bash

intro_banner="
   _____       __    ___              _   ___ __  
  / ___/__  __/ /_  /   |  ____ ___  / | / (_) /__
  \__ \/ / / / __ \/ /| | / __ `__ \/  |/ / / //_/
 ___/ / /_/ / /_/ / ___ |/ / / / / / /|  / / ,<   
/____/\__,_/_.___/_/  |_/_/ /_/ /_/_/ |_/_/_/|_|_v1.0.2  
                                                                                                    
A bash script that uses subfinder, amass, and nikto to scan a domain for vulnerabilities.

Usage: SubAmNik [-h] 

Options:
  -h, --help   Show this help message and exit
"

echo "################################################################################
# Tools Name: SubAmNik
# Description: A bash script that uses subfinder, amass, and nikto to scan a
#              domain for vulnerabilities.
# Author: 0xsaju
# Version: v_1.0.1
################################################################################
"

echo "Enter the target domain name:"
read domain

# Check for valid domains using subfinder
echo "Running subfinder to find valid domains..."
subfinder -d $domain -silent | sort -u > subdomains.txt
echo "Found \`wc -l < subdomains.txt\` valid domains"


# Use amass to scan for vulnerabilities
echo "Scanning for vulnerabilities using amass..."
amass enum -active -passive -brute -min-for-recursive 1 -d $domain -o amass.txt
echo "Completed vulnerability scan using amass. Results saved to amass.txt"

# Use nikto to scan for vulnerabilities
echo "Scanning for vulnerabilities using nikto..."
while read subdomain; do
    nikto -h $subdomain -output nikto_$subdomain.txt
done < subdomains.txt
echo "Completed vulnerability scan using nikto. Results saved to individual files"

echo "Done"
