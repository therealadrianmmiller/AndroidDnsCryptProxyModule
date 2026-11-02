
# Cleaning up browser prefs changes
ui_print "Cleaning up browser prefs changes made by module"

# Firefix cleanup
FPKG=org.mozilla.firefox
moz_prefs_file="$(find /data/data/$FPKG/files/mozilla -type d | grep '.default$' | head -1)/prefs.js"
ech_file="/storage/emulated/0/dnscrypt-proxy/firefox-ech.txt"

if pm path "$FPKG" >/dev/null 2>&1; then
    ui_print "Firefox is installed."
    ui_print "Killing Firefox to remove ECH prefs."
    am force-stop org.mozilla.firefox
    ui_print "Found Firefox prefs at: $moz_prefs_file"
    ui_print "Removing ECH lines from prefs file...."
    grep -vxFf "$ech_file" "$moz_prefs_file" > "$moz_prefs_file.tmp" && mv "$moz_prefs_file.tmp" "$moz_prefs_file"
    if [ $? -eq 0 ]; then
        ui_print "Removing ECH lines from prefs file....done"
    else 
        ui_print "Removing ECH lines from prefs file....failed" 
    fi	 
    
else
    ui_print "Firefox is NOT installed."
fi


# Chrome cleanup
CPKG=com.android.chrome
F="/data/data/$CPKG/app_chrome/Local State"
T=/data/local/tmp/ls.json
NEW='"dns_over_https":{"mode":"automatic"}'

if pm path "$CPKG" >/dev/null 2>&1; then
    ui_print "Chrome is installed."
    ui_print "Killing Chrome before proceeding"
    am force-stop $CPKG
    ui_print "Searching for dns_over_https pref...found"
    if grep -q '"dns_over_https"' "$F"; then
      # key exists: replace its value
      sed "s/\"dns_over_https\":{[^}]*}/$NEW/" "$F" > "$T"
      ui_print "Setting dns_over_https pref back to auto (default)"
    else
      # key missing: insert it as the first top-level entry
      ui_print "Searching for dns_over_https pref...not found"
      sed "s/^{/{$NEW,/" "$F" > "$T"
      ui_print "Setting dns_over_https pref back to auto (default)"
    fi
    # only write back if the temp file isn't empty, so a failed sed can't wipe the file
    [ -s "$T" ] && cat "$T" > "$F"
    rm -f "$T"
else 
    ui_print "Chrome is NOT installed."
fi
ui_print "Cleaning up browser prefs changed by module....DONE"




# remove dnscrypt-proxy redirection iptables rules
#ui_print "Removing iptables rules...."
#iptables -t nat -D OUTPUT -p tcp ! -d 1.1.1.1 --dport 53 -j DNAT --to-destination 127.0.0.1:5354
#if [ $? -eq 0 ]; then
#    ui_print "Removing iptables rules....1/2....done"
#else	
#	ui_print "Removing iptables rules....1/2....failed"
#fi	
#iptables -t nat -D OUTPUT -p udp ! -d 1.1.1.1 --dport 53 -j DNAT --to-destination 127.0.0.1:5354
#if [ $? -eq 0 ]; then
#    ui_print "Removing iptables rules....2/2....done"
#else	
#	ui_print "Removing iptables rules....2/2....failed"
#ui_print ""
#ui_print "You should now be resolving through your original DNS resolver"
#fi



# Don't modify anything after this
if [ -f $INFO ]; then
  while read LINE; do
    if [ "$(ui_print -n $LINE | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f $LINE~ $LINE
    else
      rm -f $LINE
      while true; do
        LINE=$(dirname $LINE)
        [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
      done
    fi
  done < $INFO
  rm -f $INFO
fi















#!/bin/sh

# Define the absolute path to the targeted preference file
LOCAL_STATE_FILE="/data/data/com.android.chrome/app_chrome/Local State"

# 1. Verify the file exists and is readable before running operations
if [ ! -f "$LOCAL_STATE_FILE" ]; then
    echo "[-] Error: Local State file not found at: $LOCAL_STATE_FILE"
    exit 1
fi

echo "[+] Local State file located. Attempting sed substitution..."

# 2. Execute the substitution command
# Note: Escaping is adjusted here for a direct system/adb shell context
sed -i 's/"dns_over_https":[[:space:]]*{[[:space:]]*"mode":[[:space:]]*"[^"]*"[[:space:]]*}/"dns_over_https":{"mode":"off"}/g' "$LOCAL_STATE_FILE"

# 3. Conditional verification check using grep
# This explicitly verifies the file content matches our expected layout post-execution
if grep -q '"dns_over_https":{"mode":"off"}' "$LOCAL_STATE_FILE"; then
    echo "[+] Success: Secure DNS entry successfully set to 'off'."
else
    echo "[-] Failure: The sed command completed, but the expected JSON layout was not found."
    exit 1
fi
sed -i \"s/\\\"dns_over_https\\\":{\\\"mode\\\":\\\"off\\\"}/\\\"dns_over_https\\\":{\\\"mode\\\":\\\"automatic\\\"}/g\" \"/data/data/com.android.chrome/app_chrome/Local State\"
sed -i 's/"dns_over_https":{"mode":"off"}/"dns_over_https":{"mode":"automatic"}/g' "data/data/com.android.chrome/app_chrome/Local State"
sed -i "s/\\\"dns_over_https\\\":{\\\"mode\\\":\\\"off\\\"}/\\\"dns_over_https\\\":{\\\"mode\\\":\\\"automatic\\\"}/g\" \"/data/data/com.android.chrome/app_chrome/Local State\"


