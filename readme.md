# SubAmNik Domain Vulnerability Scanner
This is a bash script that uses subfinder, amass, and nikto to scan a domain for vulnerabilities.
   _____       __    ___              _   ___ __  
  / ___/__  __/ /_  /   |  ____ ___  / | / (_) /__
  \__ \/ / / / __ \/ /| | / __ \`__\/  |/ / / //_/
 ___/ / /_/ / /_/ / ___ |/ / / / / / /|  / / ,<   
/____/\__,_/_.___/_/  |_/_/ /_/ /_/_/ |_/_/_/|_|_v2.0.1 

#################################################################################################################
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

## Prerequisites

* [Go](https://golang.org/dl/) (required for subfinder and amass)
* [subfinder](https://github.com/projectdiscovery/subfinder) (can be installed using go get -u github.com/projectdiscovery/subfinder/cmd/subfinder)
* [amass](https://github.com/OWASP/Amass) (can be installed using go get -v github.com/OWASP/Amass/v3/...)
* [nikto](https://github.com/sullo/nikto) (can be installed using sudo apt-get update && sudo apt-get install -y nikto)


## Usage
1. Clone the repository:

```
git clone https://github.com/0xsaju/SubAmNik.git
```
2. Navigate to the repository directory:
```
cd domain-vuln-scan
```
3. Make the script executable:
```
chmod +x domain-vuln-scan.sh
```
4. Run the script:
```
./domain-vuln-scan.sh
```
5. When prompted, enter the target domain name.

6. Wait for the script to complete. The script will use subfinder to find valid subdomains for the domain, and then use amass and nikto to scan for vulnerabilities. The results will be saved to the following files:

* `subdomains.txt`: A list of valid subdomains found by subfinder
* `amass.txt`: The results of the vulnerability scan using amass
* `nikto_subdomain.txt`: Individual files containing the results of the vulnerability scan for each valid subdomain found by subfinder.

# Notes
* The script assumes that subfinder, amass, and nikto are installed and in the system's PATH.
* The script may take some time to complete depending on the size of the target domain and the number of subdomains found by subfinder.
* The script only scans for vulnerabilities and does not attempt to exploit them. It is intended as a tool to help identify potential security issues in a domain.
* The script is provided as-is and the author takes no responsibility for any damage caused by its use.
