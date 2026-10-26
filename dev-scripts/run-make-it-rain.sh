#!/bin/sh
# Download Make It Rain (if needed) and run it in HyperHLE/touchHLE.
#
# Usage: run-make-it-rain.sh [path_to_touchHLE_binary] [extra touchHLE args...]
#
# Without a binary argument this looks for ./touchHLE (a release bundle), then
# ./target/release/touchHLE (a local `cargo build --release`), and finally
# falls back to `cargo run --release --`.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"

BINARY=""
if [ "$#" -gt 0 ] && [ -f "$1" ] && [ -x "$1" ]; then
    BINARY="$1"
    shift
fi

# Run from the directory that holds touchHLE's resources (touchHLE_dylibs,
# touchHLE_fonts, ...): the bundle directory, or the repository root.
if [ -n "$BINARY" ]; then
    cd "$(dirname "$BINARY")"
    BINARY="./$(basename "$BINARY")"
elif [ -x "$HERE/touchHLE" ]; then
    cd "$HERE"
    BINARY="./touchHLE"
else
    cd "$HERE/.."
    if [ -x "./target/release/touchHLE" ]; then
        BINARY="./target/release/touchHLE"
    fi
fi

IPA="$("$HERE/get-make-it-rain.sh" "touchHLE_apps")"

if [ -n "$BINARY" ]; then
    exec "$BINARY" "$IPA" "$@"
else
    exec cargo run --release -- "$IPA" "$@"
fi
