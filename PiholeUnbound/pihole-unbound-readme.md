# Pi-hole with Unbound Docker Compose

This Docker Compose configuration sets up Pi-hole with Unbound DNS resolver in a single container.

## Overview

This setup uses the `cbcrowe/pihole-unbound:latest` image to create a Pi-hole instance with an integrated Unbound DNS resolver. It provides ad-blocking and privacy-enhancing DNS services.

## Key Features

- Pi-hole for network-wide ad blocking
- Unbound as a recursive DNS resolver
- Customizable web interface port
- Optional SSH access
- Configurable reverse DNS

## Usage with Portainer

1. In Portainer, go to "Stacks" and click "Add stack".
2. Copy and paste the provided Docker Compose YAML into the web editor.
3. Set your environment variables (see below).
4. Deploy the stack.

## Environment Variables

- `HOSTNAME`: Your desired hostname
- `DOMAIN_NAME`: Your domain name
- `PIHOLE_WEBPORT`: Port for accessing the Pi-hole web interface (default: 80)
- `FTLCONF_LOCAL_IPV4`: Local IPv4 address
- `TZ`: Timezone (default: UTC)
- `WEBPASSWORD`: Password for the Pi-hole web interface
- `WEBTHEME`: Pi-hole web interface theme (default: default-light)
- `REV_SERVER`: Enable/disable reverse DNS (default: false)
- `REV_SERVER_TARGET`: Reverse DNS target
- `REV_SERVER_DOMAIN`: Reverse DNS domain
- `REV_SERVER_CIDR`: Reverse DNS CIDR range

## Environment Variables Suggestions/Defaults

Here are the current settings for the environment variables:

```
FTLCONF_LOCAL_IPV4=192.168.50.206
TZ=America/US
WEBPASSWORD=Password
REV_SERVER=false
REV_SERVER_DOMAIN=local
REV_SERVER_TARGET=192.168.50.1
REV_SERVER_CIDR=192.168.50.0/16
HOSTNAME=pihole
DOMAIN_NAME=pihole.local
PIHOLE_WEBPORT=8081
WEBTHEME=default-light
```

IMPORTANT REMINDERS:
1. Change the WEBPASSWORD to a strong, unique password before deploying.
2. Verify all other settings to ensure they match your network configuration.
3. The PIHOLE_WEBPORT is set to 8081. Make sure this port is available on your host system.


## Ports

- 4433: HTTPS
- 53: DNS (TCP/UDP)
- 80 (or custom): Pi-hole web interface
- 5335: Unbound (optional)
- 22: SSH (optional)

## Volumes

- `etc_pihole-unbound`: Pi-hole configuration
- `etc_pihole_dnsmasq-unbound`: Dnsmasq configuration

Remember to adjust the configuration as needed for your specific setup.
