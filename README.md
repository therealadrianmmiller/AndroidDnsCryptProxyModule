# Android DnsCrypt- Proxy Module

## What it is:

An all in one module, with companion app, providing a basic dnscrypt-proxy service for Android

## What It ISNT:

A tinfoil level dnscrypt-proxy setup with anonymised DNS and 12 relays. I use it for system level ad and domain blocking. May not suit the Graphene and Calyx level tinfoilists :)

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
- Root MUST be granted to Dnscrypt Monitor app before restart for seamless operation on restart
- Reboot completes initial setup

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








