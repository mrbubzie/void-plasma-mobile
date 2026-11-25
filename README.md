# Plasma Mobile for Void Linux ARM64

This kit builds KDE Plasma Mobile 6.8.3 as a native Void XBPS package
for **aarch64 (glibc)**. It uses the Qt, KDE Frameworks and Plasma packages
already published by Void. The workflow compiles the Mobile shell from KDE
source with a pinned checksum. The XBPS template includes Qt Sensors and Qt
Wayland private headers, and uses Void's Plasma ABI dependency.

## Run the workflow

1. Extract the kit and commit its contents to the default branch of a GitHub
   repository. Include the hidden `.github` directory. If using GitHub's web
   interface to upload files, verify that
   `.github/workflows/build-plasma-mobile.yml` is present afterward.
2. In that repository, open **Actions → Build Void ARM64 Plasma Mobile →
   Run workflow**. The default runner is `ubuntu-24.04-arm`.
   You can enter the label of a different native ARM64 runner with Docker.
   Enter `2` for **jobs** if you need to reduce peak build memory.
3. After both the build and offline verification pass, download
   **void-plasma-mobile-aarch64-offline** in the run's **Artifacts** section.
   Extract GitHub's ZIP and copy the TAR and its SHA-256 file to the target.

The archive contains the compiled shell, the indexed XBPS dependency
repository, package checksums, build information, and an offline installer.
It includes SDDM, an Xorg greeter backend, Foot, and PipeWire/WirePlumber.
The workflow resolves dependencies against an empty package database and
checks the finished repository again with Docker networking disabled.

The target needs an existing Void Linux ARM64 glibc installation and working
Wayland/KMS graphics. This kit contains no board image or hardware firmware.
The Void package mirror is rolling. If KDE or Qt moves to a new incompatible
release, update the overlay version, source checksum and Void packaging
commit together. The build and verification steps will report incompatible
dependencies before publishing an artifact.

See [offline installation](OFFLINE.md) for commands and session setup.
