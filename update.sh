#!/usr/bin/env bash

# This script will update a DNS A and AAAA record in a GCP Cloud DNS zone
# with the hosts public IP addresses.

# It should run in the Alpine based gcloud container.
# URL: gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine

# set default URLs to get IPv4 and IPv6 addresses
: ${V4_URL:=https://api.ipify.org}
: ${V6_URL:=https://api6.ipify.org}

usage()
{
  echo "Usage: $0 -z [ ZONENAME ] -d [ DOMAIN ] -p [ PROJECT_ID ] -t [ TTL ] -4 [ UPDATE_V4 true/false ] -6 [ UPDATE_V6 true/false ]"
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

unset ZONENAME DOMAIN PROJECT_ID TTL UPDATE_V4 UPDATE_V6

while getopts 'z:d:p:t:4:6:' opt
do
  case $opt in
    z) set_variable ZONENAME $OPTARG ;;
    d) set_variable DOMAIN $OPTARG ;;
    p) set_variable PROJECT_ID $OPTARG ;;
    t) set_variable TTL $OPTARG ;;
    4) set_variable UPDATE_V4 $OPTARG ;;
    6) set_variable UPDATE_V6 $OPTARG ;;
  esac
done

[ -z "$ZONENAME" ] || [ -z "$DOMAIN" ] || [ -z "$PROJECT_ID" ] || [ -z "$TTL" ] || [ -z "$UPDATE_V4" ] || [ -z "$UPDATE_V6" ] && usage

installDig() {
  apk --update add bind-tools
}

login() {
  gcloud auth activate-service-account \
    --key-file=service_account.json \
    --project=${PROJECT_ID}
}

updateV4Records()
{
  gcloud dns record-sets update ${DOMAIN} \
    --rrdatas=${IPV4} \
    --ttl=${TTL} \
    --type=A \
    --zone=${ZONENAME}
}

updateV6Records()
{
  gcloud dns record-sets update ${DOMAIN} \
    --rrdatas=${IPV6} \
    --ttl=${TTL} \
    --type=AAAA \
    --zone=${ZONENAME}
}

installDig

login

[[ "${UPDATE_V4}" == "true" ]] && (
  echo -n "Get DNS A record: "
  A_RECORD=$(dig +short A ${DOMAIN} | tail -n1)
  echo "done"
  echo -n "Get IPv4 address: "
  IPV4=$(curl -s ${V4_URL})
  echo "done"
  echo "DNS A Record: ${A_RECORD} ## Current IPv4: ${IPV4}"
  [[ "${A_RECORD}" != "${IPV4}" ]] && updateV4Records || echo "skip IPv4 record update"
)


[[ "${UPDATE_V6}" == "true" ]] && (
  echo -n "Get DNS AAAA record: "
  AAAA_RECORD=$(dig +short AAAA ${DOMAIN} | tail -n1)
  echo "done"
  echo -n "Get IPv6 address: "
  IPV6=$(curl -s ${V6_URL})
  echo "done"
  echo "DNS AAAA Record: ${AAAA_RECORD} ## Current IPv4: ${IPV6}"
  [[ "${AAAA_RECORD}" != "${IPV6}" ]] && updateV6Records || echo "skip IPv6 record update"
)
