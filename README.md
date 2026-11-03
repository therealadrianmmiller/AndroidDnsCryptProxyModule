# Android DnsCrypt- Proxy Module

## What it is:

An all in one module, with companion app, providing a basic dnscrypt-proxy service for Android

## What It ISNT:

A tinfoil hat level dnscrypt-proxy setup with anonymised DNS and 12 relays. I use it for system level ad and domain blocking. May not suit the Graphene and Calyx level tinfoii hatists :)

## What It Does:

Features:

- Block ads or unwanted domains (via domain name) at a system level
- Encrypt DNS traffic via upstream DNS resolver (Cloudflare by default) 
 - Pass all 4 checks (Secure DNS, DNSsec, TLS1.3 and Secure SNI (ECH))  at Cloudflare's [Browsing Experience Security Check ](https://www.cloudflare.com/ssl/encrypted-sni/) with correctly configured device and browsers (module will set prefs for Firefox and Chrome during install)
- An Android app to manage Dnscrypt-proxy, with features:
  - Stop/Stop live monitoring of blocked names (via blocked-names.log) with notifications
  - Notification of blocked domains via notification shade, or if missed ther,e they can be allowed via Recents tab in app as a backup. the rule can also be removed from blocklist (allow list is always preferable, as the same doman may be re-added via blocklist update, but im giving all options i can think of)
  - Each blocked domain is added to a local database, with each blocked domain checked against its has, to make sure you dont see repeat blocked notifications. The also helps when clearing blocked-names.log, you wont see the blocked domains after clearing
  - Restart dnscrypt-proxy
  - Pause DNS protection - if you need to absolutely access a blocked site without locating and allowing blocked domains - this just stops routing DNS through dnscrypt-proxy, without killing the proxy
  - Maintain allowed-names (allowed-names.txt, blocked-names.txt)
  - Download, build and maintain your blocklist (blocked-names.txt) from a common repo of multiple blocklist options - you can also add your own blocklist sources. You can also maintain local blocklist via  local-additions (local-additions.txt) to be added on every blocklist rebuild. The Blocklist builder can also update via scheduler
  - Settings 
    - Path to dnscrypt-proxy data files (set to /storage/emulated/0/dnscrypt-proxy by default)
    - Dark/Light/System following themes
    - 3 button styles
  
Screenshots of app, app tabs and features, are [here](https://github.com/therealadrianmmiller/AndroidDnsCryptProxyManager)

## How it works:

### Module Install phase

- Module is flashed
- Files are copied to relevant folders 
  - Usual service/post-fs-data and boot-completed files are copied to module folder
  - Basic dnscrypt-proxy config (toml and referenced txt files) are copied to /storage/emulated/0/dnscrypt-proxy ONLY if the path or files in path do not already exist
  - Dnscrypt Monitor app is installed and its notification permissions set
  - Private DNS is set to Off
  - Browsers are configured to use encrypted DNS (Firefox and Chrome are searched for, killed, and their prefs added). Note Chrome should pass 4 ticks out of the box. Firefox can be random/fail on Secure SNI (ECH), but this is a known issue due to handshake and being tracked on a bugid

     Settings added/changed in Firefox (data/data/org.mozilla.firefox/files/mozilla/<random alphanumeric>.default/prefs.js):
     ``` 
    #ECH Settings added by dnscrypt-proxy module
    user_pref("network.dns.echconfig.require_authenticated_dns", false)
    user_pref("network.dns.echconfig.enabled", true)
    user_pref("network.dns.http3_echconfig.enabled", true)
    user_pref("network.dns.force_use_https_rr", true)
    user_pref("network.trr.mode", 0)
    ```


     Settings added/changed in Chrome (json)(/data/data/com.android.chrome/app_chrome/Local State):
     ``` 
    dns_over_https":{"mode":"off"}
    ```

       Note: Troubleshooting tip if dnscrypt-proxy is running, but ads still apear that should eb blocked, make sure these lines appear in your browser

- Root MUST be granted to Dnscrypt Monitor app before restart for seamless operation on restart
- Reboot completes initial setup

### Post reboot

- dnscrypt-proxy is started (service.sh) and uses the TOML config file at /storage/emulated/0/dnscrypt-proxy/dnscrypt-proxy.toml
  Note: Your first troubleshooting point should be to open /storage/emulated/0/dnscrypt-proxy/ and check the dnscrypt-proxy.toml is there, followed by checking dnscrypt-proxy.log to see the status

 service.sh:
 ```
# run dnscrypt-proxy
while ! [ `pgrep -x dnscrypt-proxy` ] ; do 
	$MODDIR/system/bin/dnscrypt-proxy -config /storage/emulated/0/dnscrypt-proxy/dnscrypt-proxy.toml && sleep 15;
done
 ``` 
dnscrypt-prozy.toml:

```

server_names = ['cloudflare']

listen_addresses = ['127.0.0.1:5354']

max_clients = 250

ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = true
odoh_servers = false

require_dnssec = true
require_nolog = true
require_nofilter = true
disabled_server_names = []

force_tcp = false
http3 = false
http3_probe = false

timeout = 5000
keepalive = 30

log_file = '/storage/emulated/0/dnscrypt-proxy/dnscrypt-proxy.log'
log_file_latest = true
log_files_max_size = 10

cert_refresh_delay = 240

pqdnscrypt = true

bootstrap_resolvers = ['1.1.1.1:53', '8.8.8.8:53']

ignore_system_dns = true

netprobe_timeout = 60
netprobe_address = '1.1.1.1:53'

block_ipv6 = true
block_unqualified = true
block_undelegated = true

reject_ttl = 10

cache = true
cache_size = 4096
cache_min_ttl = 2400
cache_max_ttl = 86400
cache_neg_min_ttl = 60
cache_neg_max_ttl = 600

[captive_portals]
map_file = '/storage/emulated/0/dnscrypt-proxy/captive-portals.txt'

[blocked_names]
blocked_names_file = '/storage/emulated/0/dnscrypt-proxy/blocked-names.txt'
log_file = '/storage/emulated/0/dnscrypt-proxy/blocked-names.log'

[allowed_names]
allowed_names_file = '/storage/emulated/0/dnscrypt-proxy/allowed-names.txt'

[sources.public-resolvers]
urls = [
  'https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md',
  'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md',
  'https://cdn.jsdelivr.net/gh/DNSCrypt/dnscrypt-resolvers@master/v3/public-resolvers.md'
]
cache_file = 'public-resolvers.md'
minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
refresh_delay = 73
prefix = ''

[broken_implementations]
fragments_blocked = [
  'cisco',
  'cisco-ipv6',
  'cisco-familyshield',
  'cisco-familyshield-ipv6',
  'cisco-sandbox',
  'cleanbrowsing-adult',
  'cleanbrowsing-adult-ipv6',
  'cleanbrowsing-family',
  'cleanbrowsing-family-ipv6',
  'cleanbrowsing-security',
  'cleanbrowsing-security-ipv6',
]
 ``` 

- iptables rules redirect port 53 (DNS) queries to port 5354 which dnscrypt-proxy is listening on, plus IPv6 is disabled via props, all via post-fs-data.sh:

  ```
  # set iptables rules for dnscrypt-proxy
  iptables -t nat -A OUTPUT -p tcp ! -d 1.1.1.1 --dport 53 -j DNAT --to-destination 127.0.0.1:5354
  iptables -t nat -A OUTPUT -p udp ! -d 1.1.1.1 --dport 53 -j DNAT --to-destination 127.0.0.1:5354

  # Force disable IPv6 OS connections
  resetprop net.ipv6.conf.all.accept_redirects 0
  resetprop net.ipv6.conf.all.disable_ipv6 1
  resetprop net.ipv6.conf.default.accept_redirects 0
  resetprop net.ipv6.conf.default.disable_ipv6 1
  ``` 

- the dnscrypt monitor app is started via boot-completed.sh 

  ```
  LOG=/storage/emulated/0/dnscrypt-proxy/dnscrypt-monitor-boot.log
  (
  until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
  sleep 10
  i=0
  while [ $i -lt 6 ]; do
    out=$(/system/bin/am start-foreground-service -n au.com.dnscryptmonitor/.MonitorService 2>&1)
    echo "$(date '+%F %T') try $i: $out" > "$LOG"
    case "$out" in
      *Error*|*Exception*|*"not found"*) i=$((i+1)); sleep 10 ;;
      *) break ;;
    esac
  done
  ) &
  ```
- Dnscrypt monitor then takes over notifying you of blocked domains, and day to day management


### Normal operation

- Notification when domain is blocked - can be allowed via notification OR via apps Recents tab
- Maintain blocklist via apps Blocklist tab 
- Occasionally delete blocked-names.log file for efficient operation via apps Dashboard tab


## Installation:

### Pre module install:

- Make sure you have run the supported browsers (Firefox and/or Chrome) at least once for their preferences files to generate (these will be edited during module install)

### Module install:

- Install module like any other via your root manager app - this was developed and tested on a KernelSU-Next rooted device - please let me know if you have any issues on other root methods (Magisk or APatch)

### Post module install:

- Grant root to Dnscrypt Monitor app before restart 
- Set your mobile carrier APN to IPv4 only (Note: you can use IPv6 and still have good adblocking and security, ive just never used it and IPv4 mode is still the most effective. 
  
  NOTE: DO NOT leave dual stack IPv4/IPv6 mode enabled as your DNS will leak, ads will bypass dnscrypt-proxy and will render the module effectively useless. 

  If enough people want IPv6 added ill consider adding support for it.

Please remember this started out as a simple personal dnscrypt-proxy build ive used for years, that i decided was time to share, leading to me making easier to maintain with a (largely vibe coded) companion app for people.

The app is exactly the 2nd Android app ive (co)written and compiled. Ive tried to cover most things i could think of that ive normally done via scripts and hand editing text files for years. Any feature or other suggestions welcome.

Any issues/bugs/feature requests, please submit via [Issues](https://github.com/therealadrianmmiller/AndroidDnsCryptProxyModule/issues)








