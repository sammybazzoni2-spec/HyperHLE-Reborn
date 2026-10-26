#!/bin/sh
# Download the Make It Rain IPA from the Internet Archive into touchHLE_apps/
# so it shows up in the app picker (or can be passed to touchHLE directly).
#
# The IPA is fetched on the machine that will run it; it is never committed to
# this repository or shipped inside HyperHLE builds. Only use it if you are
# entitled to.
#
# Written for POSIX sh so it works on Linux, macOS and Windows (Git Bash).
#
# Usage: get-make-it-rain.sh [destination_dir]
#   destination_dir defaults to ./touchHLE_apps
# Prints the path of the IPA on its last line of stdout.
set -eu

IPA_NAME='Make It Rain-v2.3--iOS6.0-(Clutch-1.4.6).ipa'
IPA_URL='https://archive.org/download/legacy_ios_apps/6.x/Make%20It%20Rain-v2.3--iOS6.0-%28Clutch-1.4.6%29.ipa'

DEST_DIR="${1:-touchHLE_apps}"
DEST="$DEST_DIR/$IPA_NAME"

# An IPA is a zip file, so it must start with "PK".
looks_like_zip() {
    [ -s "$1" ] && [ "$(head -c 2 "$1")" = "PK" ]
}

mkdir -p "$DEST_DIR"

if looks_like_zip "$DEST"; then
    echo "Already downloaded: $DEST" >&2
    printf '%s\n' "$DEST"
    exit 0
fi

echo "Downloading Make It Rain from the Internet Archive..." >&2
TMP="$DEST.part"
rm -f "$TMP"
if command -v curl >/dev/null 2>&1; then
    curl --fail --location --retry 3 --silent --show-error -o "$TMP" "$IPA_URL"
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$TMP" "$IPA_URL"
else
    echo "Neither curl nor wget is installed." >&2
    exit 1
fi

if ! looks_like_zip "$TMP"; then
    rm -f "$TMP"
    echo "The downloaded file is not a valid IPA (not a zip archive)." >&2
    exit 1
fi

mv "$TMP" "$DEST"
echo "Saved: $DEST" >&2
printf '%s\n' "$DEST"
