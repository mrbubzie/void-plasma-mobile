# Install Plasma Mobile offline

Use an existing Void Linux ARM64 glibc system. Confirm the XBPS architecture
with `xbps-uhelper arch`. It should print `aarch64`.

From the directory containing the TAR and its checksum, run:

```sh
sha256sum -c void-plasma-mobile-aarch64.tar.sha256
tar -xf void-plasma-mobile-aarch64.tar
cd void-plasma-mobile-aarch64
sudo ./install.sh --check
sudo ./install.sh
```

If your installation uses a root shell in place of sudo, drop `sudo`.
The dry run shows packages that XBPS will install or update. Review it
before continuing, especially on a machine with an existing KDE desktop.
The installer checks every bundled package and runs XBPS with only the local
repository enabled. It uses the installed package database and leaves your
normal mirror configuration in place.

## Start a session

Enable the system D-Bus service if it is not enabled:

```sh
sudo ln -s /etc/sv/dbus /var/service/
```

If you already use a display manager, select **Plasma Mobile** in
its session menu. To use the bundled SDDM on a system with no active display
manager, enable it after D-Bus is running:

```sh
sudo ln -s /etc/sv/sddm /var/service/
```

For a direct test, sign in again at a local TTY as your regular user after
enabling D-Bus, then run `dbus-run-session startplasmamobile`. A fresh login
lets elogind set up your session and runtime directory.

NetworkManager and the PipeWire packages are available after installation.
Enable NetworkManager only if you intend to use it as your network manager.
For audio on an existing Asahi system, keep the machine's existing Asahi
audio configuration and speaker safety services.

- [Void KDE setup](https://docs.voidlinux.org/config/graphical-session/kde.html)
- [Void session management](https://docs.voidlinux.org/config/session-management.html)
- [Void PipeWire setup](https://docs.voidlinux.org/config/media/pipewire.html)
