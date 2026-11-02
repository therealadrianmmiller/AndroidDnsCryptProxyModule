# disable private DNS
ui_print "Setting private DNS to off"
settings put global private_dns_mode off


# copy config files - backing up destination files if needed
source_dir="$MODPATH/config" 
target_dir="/storage/emulated/0/dnscrypt-proxy"

# Check if source and target directories exist
if [ ! -d "$source_dir" ]; then
    ui_print "Source directory does not exist: $source_dir"
    ui_print "Module install cannot continue"
fi

if [ ! -d "$target_dir" ]; then
    ui_print "Target directory does not exist: $target_dir"
fi

# Loop through files in the source directory
find "$source_dir" -type f | while read -r source_file; do
    # Compute the relative path from source_dir
    rel_path="${source_file#$source_dir/}"
    target_file="$target_dir/$rel_path"

    # If the file doesn't exist in target_dir, copy it
    if [ ! -e "$target_file" ]; then
        # Ensure target subdirectories exist
        mkdir -p "$(dirname "$target_file")"

        # Copy the file
        cp -p "$source_file" "$target_file"
            ui_print "Copied: $source_file → $target_file"
        else
            ui_print "Skipping (already exists): $target_file"
    fi
done

# Installing Dnscrypt Monitor App
ui_print "======"
ui_print "Installing Dnscrypt Monitor App"
cp "$MODPATH/app/dnscryptmonitor.apk" /data/local/tmp/
chmod 666 /data/local/tmp/dnscryptmonitor.apk
pm install /data/local/tmp/dnscryptmonitor.apk
ui_print "Installing Dnscrypt Monitor App...done"
ui_print "Setting Dnscrypt Monitor App notification permission..."
pm grant au.com.dnscryptmonitor android.permission.POST_NOTIFICATIONS
ui_print "Setting Dnscrypt Monitor App notification permission...done"
ui_print "======"

# Setting up browser prefs changes
ui_print "Setting up browser prefs..."

# Set ECH for firefox - add lines to prefs.js
FPKG=org.mozilla.firefox
moz_prefs_file="$(find /data/data/$FPKG/files/mozilla -type d | grep '.default$' | head -1)/prefs.js"
ech_file="/storage/emulated/0/dnscrypt-proxy/firefox-ech.txt"

if pm path "$FPKG" >/dev/null 2>&1; then
    ui_print "Firefox is installed."
    ui_print "Killing Firefox to add ECH prefs."
    am force-stop org.mozilla.firefox
    ui_print "Found Firefox prefs at: $moz_prefs_file"
    ui_print "Adding ECH lines to prefs file...."
    cat "$ech_file" >> "$moz_prefs_file"
    status=$?
    if [ "$status" -eq 0 ]; then
        ui_print "Adding ECH lines from prefs file....done"
    else 
        ui_print "Adding ECH lines from prefs file....failed" 
    fi	 
    
else
    ui_print "Firefox is NOT installed."
fi


# Chrome - set Secure DNS (dns_over_https) to Off
CPKG=com.android.chrome
F="/data/data/$CPKG/app_chrome/Local State"
T=/data/local/tmp/ls.json
NEW='"dns_over_https":{"mode":"off"}'

if pm path "$CPKG" >/dev/null 2>&1; then
    ui_print "Chrome is installed."
    ui_print "Killing Chrome before proceeding"
    am force-stop $CPKG
    ui_print "Searching for dns_over_https pref..."
    if grep -q '"dns_over_https"' "$F"; then
      ui_print "Searching for dns_over_https pref...found"  
      # key exists: replace its value
      sed "s/\"dns_over_https\":{[^}]*}/$NEW/" "$F" > "$T"
      ui_print "Setting dns_over_https pref to off"
    else
      # key missing: insert it as the first top-level entry
      ui_print "Searching for dns_over_https pref...not found"
      sed "s/^{/{$NEW,/" "$F" > "$T"
      ui_print "Setting dns_over_https pref to off"
    fi
    # only write back if the temp file isn't empty, so a failed sed can't wipe the file
    [ -s "$T" ] && cat "$T" > "$F"
    rm -f "$T"
else 
    ui_print "Chrome is NOT installed."
fi
ui_print "Setting up browser prefs....DONE"
ui_print "======"
ui_print ""
ui_print "Post install setup:"
ui_print "-Set APN to IPv4 only"
ui_print "-Grant root For Dnscrypt Monitor app"
ui_print "-Reboot"
ui_print "-Build a blocklist via the Dnscrypt Monitor app"

















