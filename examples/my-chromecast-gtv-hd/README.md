# Chromecast with Google TV HD (boreal): debloat only

Google TV 14 (SDK 34), build UTTC.250917.004. Done on 2026-10-21.

## What was changed

- 14 packages disabled for user 0 (never uninstalled), listed with reasons in [`debloat.txt`](debloat.txt):
  telemetry and feedback, Privacy Sandbox / ad services, Play Games, Print Spooler, TalkBack, and the
  streaming apps not in use (HBO Max, Movistar Plus+, Orange TV, Mitele).
- Private DNS set to AdGuard (`dns.adguard-dns.com`), which blocks ad and tracker domains. It does not
  block YouTube ads, and it does not apply while NordVPN is connected (the VPN uses its own DNS).
- Kept on purpose: Google Assistant, Cast receiver, remote firmware updates, Google TV app, ambient
  mode, Play Store / Play Services, Gboard, phone remote, the stock Home and the setup wizard.

## Why there is no custom launcher

On this firmware a new launcher only stays as Home if the setup wizard
(`com.google.android.tungsten.setupwraith`) is disabled. The Cast receiver reads the device credentials
from that wizard, so phone casting fails with "Untrusted device" after every reboot, and a Wi-Fi network
saved during first setup is deleted when it is disabled. Casting is the point of a Chromecast, so the
launcher half (`launcher/build-and-install.sh`) was skipped.

## Reconnect ADB

Network ADB is off when the work is done. To change anything later:

1. Settings > System > Developer options > turn on **Wireless debugging**. Note the IP and port shown.
2. `adb connect 192.168.1.144:<port>`. If it says `offline`, run `adb devices` and use the
   `adb-...._adb-tls-connect._tcp` name it lists with `-s`.
3. `adb -s <device> tcpip 5555`. `tools/tv.py` then works with `TV_HOST=192.168.1.144`.

The Mac is already paired. Port 5555 closes again on every reboot.

## Undo

Everything, back to the state before the first change (packages and DNS):

```bash
TV_HOST=192.168.1.144 examples/my-chromecast-gtv-hd/restore.sh
```

The package record lives in `~/.cleanyourtv/recovery-192.168.1.144-*.json`. It is keyed by this list's
absolute path and the IP, so keep both.

One app only:

```bash
TV_HOST=192.168.1.144 tools/venv/bin/python -I tools/tv.py 'pm enable com.wbd.stream'
```

DNS only: `settings put global private_dns_mode opportunistic`, or on the TV: Settings > Network &
Internet > Private DNS > Automatic.

## Disable more

Add the package to `debloat.txt` and run it again. Entries already recorded keep their original state,
so the restore above still covers everything:

```bash
TV_HOST=192.168.1.144 tools/disable.sh examples/my-chromecast-gtv-hd/debloat.txt
```

Local backup of the state before any change (package lists, getprop, all settings): `backup/2026-10-21/`
(untracked, contains device identifiers).
