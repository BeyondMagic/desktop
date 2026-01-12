#!/usr/bin/env dash
#
# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

set -eu

NAME="yay-bin"
DIR="/tmp/packages/yay"
REMOTE="https://aur.archlinux.org/yay-bin.git"

clone() {
    doas rm -rf "$DIR"
    git clone --recurse-submodules "$REMOTE" "$DIR"
}

build() {
    cd "$DIR" || exit 1
    makepkg -s --noconfirm
}

install() {
    cd "$DIR" || exit 1
    makepkg -i --noconfirm
}

uninstall() {
    doas pacman -Rn "$NAME"
}

cmd="${1:-}"
case "$cmd" in
    "")        clone; build; install ;;
    clone)     clone ;;
    build)     build ;;
    install)   install ;;
    uninstall) uninstall ;;
    *) echo "usage: $0 {clone|build|install|uninstall}" >&2; exit 1 ;;
esac