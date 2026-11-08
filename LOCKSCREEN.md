# Catlogin lock screen (Super / Win + L)

Locking a running Plasma session is not handled by SDDM but by Plasma's own
lock screen (kscreenlocker), so by default you get the Breeze lock screen there.
The `lockscreen/` folder makes kscreenlocker show Catlogin too. It is only used by
KWin (which starts the lock screen), so your panels and desktop stay untouched.

Install the [login screen](README.md#how-to-install) first, the lock screen uses files from its folder.

## How to Install

The setting goes into KWin's systemd service, and its name depends on your session:
`plasma-kwin_wayland.service` on Wayland, `plasma-kwin_x11.service` on X11.
`$XDG_SESSION_TYPE` contains exactly that part (`wayland` or `x11`), so this works for both:

```bash
service=plasma-kwin_$XDG_SESSION_TYPE.service
mkdir -p ~/.config/systemd/user/$service.d
printf '[Service]\nEnvironment=PLASMA_DEFAULT_SHELL=/usr/share/sddm/themes/catlogin/lockscreen\n' \
    > ~/.config/systemd/user/$service.d/catlogin-lockscreen.conf
```

If you copied the theme somewhere other than `/usr/share/sddm/themes/catlogin`,
change the path after `PLASMA_DEFAULT_SHELL=` (it must point to the `lockscreen` folder).

Log out and back in once so KWin picks up the setting.

To remove it again, see [UNINSTALL.md](UNINSTALL.md#lock-screen).

## Testing

You can open the lock screen in a normal window without locking your session.
The program behind it, `kscreenlocker_greet`, lives in a different place on every distro
(e.g. `/usr/lib/x86_64-linux-gnu/libexec/` on Debian/Ubuntu, `/usr/lib/` on Arch,
`/usr/libexec/` on Fedora/openSUSE), so let `find` look it up:

```bash
greeter=$(find /usr/lib /usr/libexec -name kscreenlocker_greet 2>/dev/null | head -n 1)
"$greeter" --testing --shell /usr/share/sddm/themes/catlogin/lockscreen
```

Your real password closes the window, `Ctrl + C` in the terminal works too.
Any QML errors are printed right there in the terminal, so this is the place to look first
when something doesn't show up or looks wrong.

### Debugging the real lock screen

Check that KWin actually got the setting. This should print the `PLASMA_DEFAULT_SHELL` path:

```bash
systemctl --user show plasma-kwin_$XDG_SESSION_TYPE.service -p Environment
```

If it doesn't, the `.conf` file is in the wrong folder or you haven't logged out and back in yet.

The real lock screen is started by KWin, so its errors end up in KWin's log:

```bash
journalctl --user -b -u plasma-kwin_$XDG_SESSION_TYPE.service | grep -iE -A3 'kscreenlocker|lockscreen'
```

If the lock screen ever breaks and you can't unlock anymore, switch to a text console with
`Ctrl + Alt + F3`, log in there and run:

```bash
loginctl unlock-sessions
```

Then go back with `Ctrl + Alt + F1` (or `F2`, depending on your distro) and remove the
`.conf` file as described in [UNINSTALL.md](UNINSTALL.md#lock-screen).
