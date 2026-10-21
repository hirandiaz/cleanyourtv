#!/usr/bin/env bash
# Undo everything done to this Chromecast: re-enable the packages from debloat.txt (to the state recorded
# before the first change) and switch Private DNS back to the Android default.
#
# Usage: TV_HOST=192.168.1.144 examples/my-chromecast-gtv-hd/restore.sh
# Needs network ADB on port 5555 (README: "Reconnect ADB").
set -euo pipefail
: "${TV_HOST:?set TV_HOST to the Chromecast IP, e.g. TV_HOST=192.168.1.144 $0}"
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
"$ROOT/tools/restore.sh" "$HERE/debloat.txt" com.google.android.apps.tv.launcherx
PY="$ROOT/tools/venv/bin/python"
"$PY" -I "$ROOT/tools/tv.py" 'settings put global private_dns_mode opportunistic'
"$PY" -I "$ROOT/tools/tv.py" 'settings delete global private_dns_specifier'
echo "Done. Disabled packages now:"
"$PY" -I "$ROOT/tools/tv.py" 'pm list packages -d'
