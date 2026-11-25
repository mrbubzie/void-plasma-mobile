#!/usr/bin/env bash
set -euo pipefail

arch=aarch64
mirror=https://repo-fastly.voidlinux.org/current
void_commit=a54ea0e77fb46c99e2d58f0d7f14ffb4926a8604
jobs=${BUILD_JOBS:-0}
if [[ ! $jobs =~ ^(0|[1-9][0-9]*)$ ]]; then
    echo 'Parallel jobs must be 0 or a positive integer.' >&2
    exit 2
fi
[[ $jobs != 0 ]] || jobs=$(nproc)

# This script runs as root inside the disposable Void container.
test "$(xbps-uhelper arch)" = "$arch"
xbps-install -iyS --repository="$mirror/$arch" xbps
xbps-install -iyS --repository="$mirror/$arch" bash git sudo
useradd -m -G xbuilder builder
work=/home/builder/void-packages
sudo -Hu builder git init "$work"
sudo -Hu builder git -C "$work" fetch --depth=1 https://github.com/void-linux/void-packages.git "$void_commit"
sudo -Hu builder git -C "$work" checkout --detach FETCH_HEAD
cp -R /kit/overlay/srcpkgs/. "$work/srcpkgs/"
chown -R builder:builder "$work/srcpkgs/plasma-mobile"

cd "$work"
cat > etc/conf <<CONFIG
XBPS_CHROOT_CMD=uchroot
XBPS_MIRROR=$mirror
XBPS_MAKEJOBS=$jobs
XBPS_BUILD_ENVIRONMENT=void-packages-ci
CONFIG
sudo -Hu builder ./xbps-src binary-bootstrap
sudo -Hu builder ./xbps-src pkg plasma-mobile

bundle=/output/void-plasma-mobile-aarch64
repo="$bundle/repository"
mkdir -p "$repo"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/root/var/db/xbps/keys" "$scratch/cache"
cp common/repo-keys/*.plist "$scratch/root/var/db/xbps/keys/"
# XBPS reads local packages in place, while remote packages go to its cache.
shopt -s nullglob
built=("$work"/hostdir/binpkgs/plasma-mobile-*.aarch64.xbps)
if (( ${#built[@]} != 1 )); then
    echo 'Expected exactly one locally compiled Plasma Mobile package.' >&2
    exit 1
fi
cp "${built[@]}" "$repo/"
xbps-rindex -a "$repo"/*.xbps
packages=(plasma-mobile sddm xorg-minimal foot pipewire wireplumber)
xbps-install -iySD -r "$scratch/root" -c "$scratch/cache" \
    --repository="$repo" --repository="$mirror/$arch" "${packages[@]}"
downloaded=("$scratch"/cache/*.xbps)
if (( ${#downloaded[@]} == 0 )); then
    echo 'XBPS did not download any dependencies.' >&2
    exit 1
fi
cp "${downloaded[@]}" "$repo/"
(
    cd "$bundle"
    xbps-rindex -a repository/*.xbps
    sha256sum repository/*.xbps repository/*-repodata > SHA256SUMS
    printf '%s\n' "${packages[@]}" > packages.txt
    printf 'Architecture: %s\nVoid packaging commit: %s\nRepository: %s\nBuild UTC: %s\n' \
        "$arch" "$void_commit" "$mirror/$arch" "$(date -u +%FT%TZ)" > BUILD-INFO.txt
)
install -m 755 /kit/scripts/install.sh "$bundle/install.sh"
install -m 644 /kit/OFFLINE.md "$bundle/README.md"
