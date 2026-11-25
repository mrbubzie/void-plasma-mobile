#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if [[ $(xbps-uhelper arch) != aarch64 ]]; then
    echo 'This bundle requires Void Linux aarch64 with glibc.' >&2
    exit 1
fi

args=()
case "${1:-}" in
    '') ;;
    --check) args=(-n) ;;
    --verify-empty)
        root=$(mktemp -d)
        trap 'rm -rf "$root"' EXIT
        args=(-n -r "$root")
        ;;
    *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac
sha256sum --quiet -c SHA256SUMS
mapfile -t packages < packages.txt
xbps-install -i --repository="$PWD/repository" "${args[@]}" "${packages[@]}"
