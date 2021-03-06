#!/bin/bash

# get settings from config file and add them if not already existinting as environment variable settings
FILE=$APP_HOME/settings.conf
if [[ -f "$FILE" ]]; then
  lines=$(grep -v '^\s*$\|^\s*\#' $FILE)
  while IFS= read -r line; do
    envname=$(echo $line | sed 's/=.*//')
    if [ -z ${!envname} ]; then
      export "$line"
    fi
  done <<< "$lines"
fi

# write mail settings from existing environment variables to mail settings file
if [[ ! -z "${MAIL_HOST}" ]]; then
  sed -i "s|^host .*$|host ${MAIL_HOST}|" /root/.msmtprc
else
  echo "MAIL_HOST missing!"
  exit 1
fi

if [[ ! -z "${MAIL_PORT}" ]]; then
  sed -i "s|^port .*$|port ${MAIL_PORT}|" /root/.msmtprc
else
  echo "MAIL_PORT missing!"
  exit 1
fi

if [[ ! -z "${MAIL_DOMAIN}" ]]; then
  sed -i "s|^domain .*$|domain ${MAIL_DOMAIN}|" /root/.msmtprc
else
  echo "MAIL_DOMAIN missing!"
  exit 1
fi

if [[ ! -z "${MAIL_MAILDOMAIN}" ]]; then
  sed -i "s|^maildomain .*$|maildomain ${MAIL_MAILDOMANI}|" /root/.msmtprc
else
  echo "MAIL_MAILDOMAIN missing!"
  exit 1
fi

if [[ ! -z "${MAIL_USER}" ]]; then
  sed -i "s|^user .*$|user ${MAIL_USER}|" /root/.msmtprc
else
  echo "MAIL_USER missing!"
  exit 1
fi

if [[ ! -z "${MAIL_PASSWORD}" ]]; then
  sed -i "s|^password .*$|password \"${MAIL_PASSWORD}\"|" /root/.msmtprc
else
  echo "MAIL_PASSWORD missing!"
  exit 1
fi

if [[ ! -z "${MAIL_FROM}" ]]; then
  sed -i "s|^from .*$|from ${MAIL_FROM}|" /root/.msmtprc
else
  echo "MAIL_FROM missing!"
  exit 1
fi

# check if setting is missing (non-mail)
if [[ -z "${URLS}" ]]; then
  echo "URLS missing!"
  exit 1
fi

if [[ -z "${COUNT}" ]]; then
  echo "COUNT missing!"
  exit 1
fi

if [[ -z "${SLEEP_SEC}" ]]; then
  echo "SLEEP_SEC missing!"
  exit 1
fi

if [[ -z "${EMAIL_ADDRESS}" ]]; then
  echo "EMAIL_ADDRESS missing!"
  exit 1
fi

if [[ -z "${CHECK_IPv6}" ]]; then
  echo "CHECK_IPv6 missing!"
  exit 1
fi

if [[ -z "${CHECK_IPv4}" ]]; then
  echo "CHECK_IPv4 missing!"
  exit 1
fi


###########################################################
# actual script starts here
##########################################################

# start thread for each host to monitor
for myHost in $URLS
do
  if [[ "$CHECK_IPv4" = true ]]; then
    bash ./thread.sh -h $myHost -e $EMAIL_ADDRESS -s $SLEEP_SEC -c $COUNT &
  fi
  if [[ "$CHECK_IPv6" = true ]]; then
    bash ./thread.sh -6 -h $myHost -e $EMAIL_ADDRESS -s $SLEEP_SEC -c $COUNT &
  fi
done

# keep running to not stop container
while true
do
  sleep 60
done
