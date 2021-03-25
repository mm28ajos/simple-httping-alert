#!/bin/bash

CHECK_IPv6=false

POSITIONAL=()
# parse arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -6|--checkipv6)
    CHECK_IPv6=true;
    shift # past argument
    ;;
    -h|--host)
    myHost="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--emailaddress)
    EMAIL_ADDRESS="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--seconds)
    SLEEP_SEC="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--count)
    COUNT="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

###########################################################
# actual script starts here
##########################################################
# limit SLEEP_SEC to 2h
if ((SLEEP_SEC>=7200)); then
	SLEEP_SEC=7200
fi

# store inital sleepsec
SLEEP_SEC_INITAL=$SLEEP_SEC

# loop until forever
while true
do
  # check if own connection is up (ping google DNS)
  if [[ "$CHECK_IPv6" = true ]]; then
    result=$(ping -6 -c 1 2001:4860:4860::8888 )
  else
    result=$(ping -c 1 8.8.8.8 )
  fi
  countping=$(echo $result | grep '0% packet loss' | wc -l)

  # check if http ping of resource is successful
  if [[ "$countping" = 1 ]]; then

    # httping host on ipv6 or ipv4
    if [[ "$CHECK_IPv6" = true ]]; then
      result2=$(httping -6 -c $COUNT -s -o 200 -G -l -g $myHost )
    else
      result2=$(httping -c $COUNT -s -o 200 -G -l -g $myHost )
    fi
    countping2=$(echo $result2 | grep '100.00% failed' | wc -l)
    countdns=$(echo $result2 | grep 'No valid IPv4 or IPv6 address found for' | wc -l)

    if [[ "$countping2" = 1 ]] || [[ "$countdns" = 1 ]]; then
      # send mail on failure
      if [[ "$CHECK_IPv6" = true ]]; then
        if [[ "$countping2" = 1 ]]; then
          printf "Subject: Httping on IPv6 failed for $myHost\nResource $myHost is down on IPv6 (http ping failed) at $(date)" | msmtp -a default $EMAIL_ADDRESS
        fi
        if [[ "$countdns" = 1 ]]; then
          printf "Subject: DNS on IPv6 failed for $myHost\nResource $myHost is down on IPv6 (DNS failed) at $(date)" | msmtp -a default $EMAIL_ADDRESS
        fi
      else
        if [[ "$countping2" = 1 ]]; then
          printf "Subject: Httping on IPv4 failed for $myHost\nResource $myHost is down on IPv6 (http ping failed) at $(date)" | msmtp -a default $EMAIL_ADDRESS
        fi
        if [[ "$countdns" = 1 ]]; then
          printf "Subject: DNS on IPv4 failed for $myHost\nResource $myHost is down on IPv6 (DNS failed) at $(date)" | msmtp -a default $EMAIL_ADDRESS
        fi
      fi
      # increase sleep time by factor 2
      SLEEP_SEC=$(( 2*SLEEP_SEC ))
      # wait maximum 2h until the next try
      if ((SLEEP_SEC>=7200)); then
        SLEEP_SEC=7200
      fi
    else
      # reset sleep sec to inital value if ping was succesful
      SLEEP_SEC=$SLEEP_SEC_INITAL
    fi
  fi
  # sleep before recheck
  sleep $SLEEP_SEC
done