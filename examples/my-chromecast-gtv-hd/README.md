# Chromecast with Google TV HD (boreal): debloat and custom launcher

Google TV 14 (SDK 34), build UTTC.250917.004. Done on 2026-10-21.

## What was changed

- 14 packages disabled for user 0 (never uninstalled), listed with reasons in [`debloat.txt`](debloat.txt):
  telemetry and feedback, Privacy Sandbox / ad services, Play Games, Print Spooler, TalkBack, and the
  streaming apps not in use (HBO Max, Movistar Plus+, Orange TV, Mitele). HBO Max, Movistar
  Plus+ and Orange TV were then uninstalled to free space; Mitele (Mediaset Infinity) was uninstalled
  too and later reinstalled from the Play Store because it is in use.
- Private DNS set to AdGuard (`dns.adguard-dns.com`), which blocks ad and tracker domains. It does not
  block YouTube ads, and it does not apply while NordVPN is connected (the VPN uses its own DNS).
- Custom launcher installed as Home (see below); the stock Home (`launcherx`) and the setup wizard
  (`setupwraith`) are disabled.
- Kept on purpose: Google Assistant, Cast receiver, remote firmware updates, Google TV app, ambient
  mode, Play Store / Play Services, Gboard, phone remote.

## Custom launcher

Built in Docker (no JDK or Android SDK on the Mac) and installed without building:

```bash
launcher/docker-build.sh
TV_HOST=192.168.1.144 SKIP_BUILD=1 INPUT_KEY_SERVICE=1 launcher/build-and-install.sh
```

`launcher/app/src/main/res/values/config.xml`: dock Netflix, YouTube, Prime Video, Disney+; no Live TV;
`app_keys` maps the remote's YouTube button (keycode 190) to YouTube, which needs `INPUT_KEY_SERVICE=1`.
Checked on 2026-10-21 with the real remote: Home, YouTube and the Settings shortcut work. The screensaver
is still Google's ambient mode (`dreamx/.service.Backdrop`).

Before disabling `setupwraith`, the Wi-Fi network saved during first setup (owned by `setupwraith`) was
forgotten and re-joined in Settings, so it now belongs to the system and survives. `tools/disable.sh`
refuses to disable `setupwraith` while any saved network belongs to it.

**Casting after a reboot.** The Cast receiver reads the device credentials from `setupwraith`, so after
every reboot casting from a phone fails with "Untrusted device". To fix it until the next reboot:

```bash
TV_HOST=192.168.1.144 tools/venv/bin/python -I tools/tv.py 'pm enable com.google.android.tungsten.setupwraith'
# wait about a minute, then:
TV_HOST=192.168.1.144 tools/venv/bin/python -I tools/tv.py 'pm disable-user --user 0 com.google.android.tungsten.setupwraith'
```

## Reconnect ADB

Network ADB is off when the work is done. To change anything later:

1. Settings > System > Developer options > turn on **Wireless debugging**. Note the IP and port shown.
2. `adb connect 192.168.1.144:<port>`. If it says `offline`, run `adb devices` and use the
   `adb-...._adb-tls-connect._tcp` name it lists with `-s`.
3. `adb -s <device> tcpip 5555`. `tools/tv.py` then works with `TV_HOST=192.168.1.144`.

The Mac is already paired. Port 5555 closes again on every reboot.

## Undo

Everything, back to the state before the first change (packages, stock Home and DNS):

```bash
TV_HOST=192.168.1.144 examples/my-chromecast-gtv-hd/restore.sh
```

The package record lives in `~/.cleanyourtv/recovery-192.168.1.144-*.json`. It is keyed by this list's
absolute path and the IP, so keep both.

The custom launcher stays installed but is no longer Home; remove it with
`tools/tv.py 'pm uninstall com.gathin.tvhome'`.

The three uninstalled streaming apps cannot be re-enabled (restore prints an "unknown package" error for
them, which is harmless); reinstall them from the Play Store.

One app only:

```bash
TV_HOST=192.168.1.144 tools/venv/bin/python -I tools/tv.py 'pm enable com.google.android.play.games'
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
