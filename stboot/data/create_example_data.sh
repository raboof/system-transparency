#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

https_root_certificates_file="https-root-certificates.pem"
network_file="network.json"
ntp_servers_file="ntp-servers.json"
provisioning_servers_file="provisioning-servers.json"

##############################
# https-root-certificates.json
##############################
write=true
if [ -f "${dir}/${https_root_certificates_file}" ]; then
    while true; do
       echo "[INFO]: Current ${https_root_certificates_file}:"
       cat "${dir}/${https_root_certificates_file}"
       read -rp "Override? (y/n)" yn
       case $yn in
          [Yy]* ) rm -f "${dir}/${https_root_certificates_file}"; break;;
          [Nn]* ) write=false: break;;
          * ) echo "Please answer yes or no.";;
       esac
    done 
fi

if "${write}" ; then
   echo "[INFO]: Create ${https_root_certificates_file}"
   touch "${dir}/${https_root_certificates_file}"
   echo '
LetsEncrypt Authority X3 (signed by X1)
-----BEGIN CERTIFICATE-----
MIIFjTCCA3WgAwIBAgIRANOxciY0IzLc9AUoUSrsnGowDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTYxMDA2MTU0MzU1
WhcNMjExMDA2MTU0MzU1WjBKMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNTGV0J3Mg
RW5jcnlwdDEjMCEGA1UEAxMaTGV0J3MgRW5jcnlwdCBBdXRob3JpdHkgWDMwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCc0wzwWuUuR7dyXTeDs2hjMOrX
NSYZJeG9vjXxcJIvt7hLQQWrqZ41CFjssSrEaIcLo+N15Obzp2JxunmBYB/XkZqf
89B4Z3HIaQ6Vkc/+5pnpYDxIzH7KTXcSJJ1HG1rrueweNwAcnKx7pwXqzkrrvUHl
Npi5y/1tPJZo3yMqQpAMhnRnyH+lmrhSYRQTP2XpgofL2/oOVvaGifOFP5eGr7Dc
Gu9rDZUWfcQroGWymQQ2dYBrrErzG5BJeC+ilk8qICUpBMZ0wNAxzY8xOJUWuqgz
uEPxsR/DMH+ieTETPS02+OP88jNquTkxxa/EjQ0dZBYzqvqEKbbUC8DYfcOTAgMB
AAGjggFnMIIBYzAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADBU
BgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEEAYLfEwEBATAwMC4GCCsGAQUFBwIB
FiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2VuY3J5cHQub3JnMB0GA1UdDgQWBBSo
SmpjBH3duubRObemRWXv86jsoTAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
LnJvb3QteDEubGV0c2VuY3J5cHQub3JnMHIGCCsGAQUFBwEBBGYwZDAwBggrBgEF
BQcwAYYkaHR0cDovL29jc3Aucm9vdC14MS5sZXRzZW5jcnlwdC5vcmcvMDAGCCsG
AQUFBzAChiRodHRwOi8vY2VydC5yb290LXgxLmxldHNlbmNyeXB0Lm9yZy8wHwYD
VR0jBBgwFoAUebRZ5nu25eQBc4AIiMgaWPbpm24wDQYJKoZIhvcNAQELBQADggIB
ABnPdSA0LTqmRf/Q1eaM2jLonG4bQdEnqOJQ8nCqxOeTRrToEKtwT++36gTSlBGx
A/5dut82jJQ2jxN8RI8L9QFXrWi4xXnA2EqA10yjHiR6H9cj6MFiOnb5In1eWsRM
UM2v3e9tNsCAgBukPHAg1lQh07rvFKm/Bz9BCjaxorALINUfZ9DD64j2igLIxle2
DPxW8dI/F2loHMjXZjqG8RkqZUdoxtID5+90FgsGIfkMpqgRS05f4zPbCEHqCXl1
eO5HyELTgcVlLXXQDgAWnRzut1hFJeczY1tjQQno6f6s+nMydLN26WuU4s3UYvOu
OsUxRlJu7TSRHqDC3lSE5XggVkzdaPkuKGQbGpny+01/47hfXXNB7HntWNZ6N2Vw
p7G6OfY+YQrZwIaQmhrIqJZuigsrbe3W+gdn5ykE9+Ky0VgVUsfxo52mwFYs1JKY
2PGDuWx8M6DlS6qQkvHaRUo0FMd8TsSlbF0/v965qGFKhSDeQoMpYnwcmQilRh/0
ayLThlHLN81gSkJjVrPI0Y8xCVPB4twb1PFUd2fPM3sA1tJ83sZ5v8vgFv2yofKR
PB0t6JzUA81mSqM3kxl5e+IZwhYAyO0OTg3/fs8HqGTNKd9BqoUwSRBzp06JMg5b
rUCGwbCUDI0mxadJ3Bz4WxR6fyNpBK2yAinWEsikxqEt
-----END CERTIFICATE-----
   ' > "${dir}/${https_root_certificates_file}"

   cat "${dir}/${https_root_certificates_file}"
fi

##################
# network.json
##################
write=true
if [ -f "${dir}/${network_file}" ]; then
    while true; do
       echo "[INFO]: Current ${network_file}:"
       cat "${dir}/${network_file}"
       read -rp "Override? (y/n)" yn
       case $yn in
          [Yy]* ) rm -f "${dir}/${network_file}"; break;;
          [Nn]* ) write=false; break;;
          * ) echo "Please answer yes or no.";;
       esac
    done 
fi

if "${write}"; then
   while true; do
      echo "[INFO]: Create ${network_file}. Choose ip configuration:"
      echo "(1) Qemu"
      echo "(2) empty-> DHCP"
      read -rp ">> " x
      touch "${dir}/${network_file}"
      if [ "${x}" = 1 ]; then
         echo '
{
   "host_ip":"10.0.2.15/24",
   "netmask":"",
   "gateway":"10.0.2.2/24",
   "dns":""
}
         ' > "${dir}/${network_file}"
         break
      elif [ "${x}" = 2 ]; then
         echo '
{
   "host_ip":"",
   "netmask":"",
   "gateway":"",
   "dns":""
}
         ' > "${dir}/${network_file}"
         break
      else
         echo "Invalid input!"
      fi
   done
   cat "${dir}/${network_file}"
fi

##################
# ntp-servers.json
##################
write=true
if [ -f "${dir}/${ntp_servers_file}" ]; then
    while true; do
       echo "[INFO]: Current ${ntp_servers_file}:"
       cat "${dir}/${ntp_servers_file}"
       read -rp "Override? (y/n)" yn
       case $yn in
          [Yy]* ) rm -f "${dir}/${ntp_servers_file}"; break;;
          [Nn]* ) write=false; break;;
          * ) echo "Please answer yes or no.";;
       esac
    done 
fi

if "${write}"; then
   echo "[INFO]: Create ${ntp_servers_file}"
   touch "${dir}/${ntp_servers_file}"
   echo '
[
   "0.beevik-ntp.pool.ntp.org"
]
   ' > "${dir}/${ntp_servers_file}"

   cat "${dir}/${ntp_servers_file}"
fi

##############################
# provisioning-servers.json
##############################
write=true
if [ -f "${dir}/${provisioning_servers_file}" ]; then
    while true; do
       echo "[INFO]: Current ${provisioning_servers_file}:"
       cat "${dir}/${provisioning_servers_file}"
       read -rp "Override? (y/n)" yn
       case $yn in
          [Yy]* ) rm -f "${dir}/${provisioning_servers_file}"; break;;
          [Nn]* ) write=false; break;;
          * ) echo "Please answer yes or no.";;
       esac
    done 
fi

if "${write}"; then
   echo "[INFO]: Create ${provisioning_servers_file}"
   touch "${dir}/${provisioning_servers_file}"
   echo '
[
   "https://stboot.9esec.dev"
]
   ' > "${dir}/${provisioning_servers_file}"

   cat "${dir}/${provisioning_servers_file}"
fi
