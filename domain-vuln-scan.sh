#!/bin/bash

################################################################################
# Script Name: domain-vuln-scan.sh
# Description: A bash script that uses subfinder, amass, and nikto to scan a
#              domain for vulnerabilities.
# Author: 0xsaju
# Version: v_1.0.1
################################################################################

echo "Enter the target domain name:"
read domain

# Check for valid domains using subfinder
echo "Running subfinder to find valid domains..."
subfinder -d $domain -silent | sort -u > subdomains.txt
echo "Found $(wc -l < subdomains.txt) valid domains"

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
