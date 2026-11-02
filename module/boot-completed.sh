#!/system/bin/sh
# Starts the DNSCrypt Monitor service at boot, independent of Android's BOOT_COMPLETED rules.

LOG=/storage/emulated/0/dnscrypt-proxy/dnscrypt-monitor-boot.log
(
  until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
  sleep 10
  i=0
  while [ $i -lt 6 ]; do
    out=$(/system/bin/am start-foreground-service -n au.com.dnscryptmonitor/.MonitorService 2>&1)
    echo "$(date '+%F %T') try $i: $out" >> "$LOG"
    case "$out" in
      *Error*|*Exception*|*"not found"*) i=$((i+1)); sleep 10 ;;
      *) break ;;
    esac
  done
) &
