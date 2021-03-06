# Simple Httping Alert
Send an mail notification if a GET request on an URL returns no http 200 code (httping) or a DNS resolution fails. Check's the http-resource regulary.
Basically, a simple wrapper script around httping, refer to https://www.vanheusden.com/httping/. Refer to https://hub.docker.com/repository/docker/mm28ajos/simple-httping-alert for pre-build docker images.

## Features
* check multiple http-resources for availability (GET request successful?) on a regular basis
* check IPv4 and/or IPv6 availability
* check if a DNS A/AAAA record is present for the host of the http-resource
* get an e-mail notification on failure (DNS or GET request)
* specify how many httpings should be carried out in a check interval
* specifiy the recheck interval in seconds
* automatic slow down of rechecks if resource is down to avoid mail flood (maximum recheck slow down to two hours if resource is down)

# Example Notification

Mail on DNS failure IPv6
```
Subject: DNS on IPv6 failed for https://domain.tld/resource
Body: Resource https://domain.tld/resource is down on IPv6 (DNS failed) at Sat Mar  6 16:19:25 CET 2021
```

Mail on GET failure IPv4
```
Subject: Httping on IPv4 failed for https://domain.tld/resource
Body: Resource https://domain.tld/resource is down on IPv6 (http ping failed) at Sat Mar  6 16:30:13 CET 2021
```

## Getting started
### Docker Compose
Create a docker compose file, see an example below. Add the configuration file for the actual httping script as volume. Refer to example configuration below. Set time zone by TZ environment variable if desired (default it UTC).

Alternatively, use environment variables for the settings, see next section.

```
# only settings from config files
version: '2.2'
services:
  simple-httping-alert:
    image: mm28ajos/simple-httping-alert:latest
    restart: unless-stopped
    # network_mode host is used to have ipv6 accessibility from host. May differ for your IPv6 handling in docker.
    network_mode: host
    environment:
      - TZ=Europe/Berlin
    volumes:
      - /path/to/setting/settings.conf:/opt/simplehttpingalert/settings.conf
```
In the example configuration below, some settings are made via environment variables. Note, environment settings override settings form the mounted setting file. 
```
version: '2.2'
services:
  simple-httping-alert:
    image: mm28ajos/simple-httping-alert:latest
    restart: unless-stopped
    # network_mode host is used to have ipv6 accessibility from host. May differ for your IPv6 handling in docker.
    network_mode: host
    volumes:
      - /path/to/setting/settings.conf:/opt/simplehttpingalert/settings.conf
    environment:
      - TZ=Europe/Berlin
      - URLS=host.tld host2.tld.de
      - COUNT=2
      - EMAIL_ADDRESS=mail@domain.tld
      - SLEEP_SEC=5
      - CHECK_IPv4=true
      - CHECK_IPv6=true
      - MAIL_HOST=mailhost.tld
      - MAIL_PORT=465
      - MAIL_DOMAIN=maildomain.tld
      - MAIL_MAILDOMAIN=maildomain.tld
      - MAIL_USER=username
      - MAIL_PASSWORD=password
      - MAIL_FROM=user@domain.tld
```
### Configuration

Mount a configuration to **/opt/simplehttpingalert/settings.conf**, refer to example below or set any of the settings as environment variable in docker-compose. Note, environment settings override settings from the mounted setting file.

```
# add URL(s) / hostname(s) to ping separated by white space
URLS=host.tld host2.tld.de

# number of httpings to send
COUNT=2

# email address to report on failure
EMAIL_ADDRESS=mail@domain.tld

# seconds to wait for next check
SLEEP_SEC=5

# check host availability on ipv4 connection?
CHECK_IPv4=true

# check host availability on ipv6 connection?
CHECK_IPv6=true

############################################
# Mail settings, for details refer to https://marlam.de/msmtp/documentation/
###########################################

# mail host
MAIL_HOST=mailhost.tld

# mail port
MAIL_PORT=465

# mail domain
MAIL_DOMAIN=maildomain.tld

# mail mail domain
MAIL_MAILDOMAIN=maildomain.tld

# mail user
MAIL_USER=username

# mail password
MAIL_PASSWORD=password

# mail from
MAIL_FROM=user@domain.tld
```
