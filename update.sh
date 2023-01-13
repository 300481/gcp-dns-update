#!/usr/bin/env bash

# This script will invoke the GCP Cloud Function to update Cloud DNS Zone records
# It is an implementation variant for DynDNS with GCP Cloud DNS

usage()
{
  echo "Usage: $0 -z [ ZONENAME ] -f [ FQDN ] -u [ FUNCTION_URL ] -t [ TOKEN ]"
  exit 2
}

set_variable()
{
  local varname=$1
  shift
  if [ -z "${!varname}" ]; then
    eval "$varname=\"$@\""
  else
    echo "Error: $varname already set"
    usage
  fi
}

#########################
# Main script starts here

unset ZONENAME FQDN FUNCTION_URL TOKEN

while getopts 'z:f:u:t:' opt
do
  case $opt in
    z) set_variable ZONENAME $OPTARG ;;
    f) set_variable FQDN $OPTARG ;;
    u) set_variable FUNCTION_URL $OPTARG ;;
    t) set_variable TOKEN $OPTARG ;;
  esac
done

[ -z "$ZONENAME" ] || [ -z "$FQDN" ] || [ -z "$FUNCTION_URL" ] || [ -z "$TOKEN" ] && usage

skip()
{
  echo "No IP address changes, skipping."
  exit 0
}

updateRecords()
{
  echo "Invoke GCP Cloud function URL '${FUNCTION_URL}?zoneName=${ZONENAME}&fqdn=${FQDN}&ipv4=${IPV4}&ipv6=$(urlencode ${IPV6})'"
  curl -s "${FUNCTION_URL}?zoneName=${ZONENAME}&fqdn=${FQDN}&ipv4=${IPV4}&ipv6=$(urlencode ${IPV6})&token=${TOKEN}"
  exit 0
}

# get current DNS records for IPv4 and IPv6

echo -n "Get DNS records: "
A_RECORD=$(dig +short A ${FQDN} | tail -n1)
AAAA_RECORD=$(dig +short AAAA ${FQDN} | tail -n1)
echo "done"

# get current IPv4 and IPv6 addresses

echo -n "Get IP addresses: "
IPV4=$(curl -s https://api.ipify.org)
IPV6=$(curl -s https://api6.ipify.org)
echo "done"

echo "DNS A Record: ${A_RECORD} ## Current IPv4: ${IPV4}"
echo "DNS AAAA Record: ${AAAA_RECORD} ## Current IPv6: ${IPV6}"

# if no change, skip record update
[[ "${A_RECORD}" == "${IPV4}" ]] && [[ "${AAAA_RECORD}" == "${IPV6}" ]] && skip

# else update records
updateRecords