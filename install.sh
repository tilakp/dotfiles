#!/usr/bin/env bash
#
# Link this repo's configs into the places the tools expect to find them.
#
# Safe to run more than once. An existing symlink that already points at the
# right place is left alone; a real file or directory in the way is moved to
# ~/.dotfiles-backup/<timestamp>/ first, never deleted.
#
#   ./install.sh          link everything
#   ./install.sh --dry    show what would happen, change nothing

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY=0
[ "${1:-}" = "--dry" ] && DRY=1

# Add a line here to track something new: "<path in repo>:<where it belongs>"
LINKS=(
  "doom:$HOME/.config/doom"
)

link() {
  local src="$DOTFILES/$1" dest="$2" rel

  if [ ! -e "$src" ]; then
    printf '  skip   %s (not in this repo)\n' "$1"
    return
  fi

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    printf '  ok     %s\n' "$dest"
    return
  fi

  if [ $DRY -eq 1 ]; then
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      printf '  would  move %s aside, then link -> %s\n' "$dest" "$src"
    else
      printf '  would  link %s -> %s\n' "$dest" "$src"
    fi
    return
  fi

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    rel="${dest#"$HOME"/}"
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$dest" "$BACKUP/$rel"
    printf '  moved  %s -> %s\n' "$dest" "$BACKUP/$rel"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  printf '  link   %s -> %s\n' "$dest" "$src"
}

printf 'dotfiles: %s\n' "$DOTFILES"
[ $DRY -eq 1 ] && printf 'dry run, nothing will change\n'
for entry in "${LINKS[@]}"; do
  link "${entry%%:*}" "${entry#*:}"
done

if [ $DRY -eq 0 ] && [ -d "$BACKUP" ]; then
  printf '\nDisplaced files were kept in %s\n' "$BACKUP"
fi
