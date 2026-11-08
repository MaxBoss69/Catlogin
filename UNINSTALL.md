# Uninstall Catlogin

## Lock screen

If you set up the [lock screen](LOCKSCREEN.md), remove it first, because it uses files from the theme folder.

Delete the `.conf` file you created and log out and back in. Plasma's Breeze lock screen is back then:

```bash
rm ~/.config/systemd/user/plasma-kwin_$XDG_SESSION_TYPE.service.d/catlogin-lockscreen.conf
```

## Login screen

SDDM uses whatever theme `Current=` names, so removing that line is enough.
If `/etc/sddm.conf.d/theme.conf` only contains the lines from the [install steps](README.md#how-to-install), just delete it:

```bash
sudo rm /etc/sddm.conf.d/theme.conf
```

SDDM falls back to its default theme the next time the login screen shows up.
Afterwards you can also delete the theme folder:

```bash
sudo rm -r /usr/share/sddm/themes/catlogin
```
