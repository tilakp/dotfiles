# dotfiles

Personal configuration, kept in one place and symlinked into position.

## Layout

```
dotfiles/
  doom/          Doom Emacs config  ->  ~/.config/doom
  install.sh     creates the symlinks
```

## Install on a new machine

```sh
git clone git@github.com:tilakp/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry     # see what it would do
./install.sh
```

`install.sh` is safe to re-run. A symlink already pointing at the right place
is left alone. A real file in the way is moved to
`~/.dotfiles-backup/<timestamp>/` rather than deleted.

## Adding something new

Move the real file into the repo, then add one line to `LINKS` in
`install.sh` and re-run it:

```sh
mkdir -p ~/dotfiles/zsh
mv ~/.zshrc ~/dotfiles/zsh/.zshrc
# in install.sh:  "zsh/.zshrc:$HOME/.zshrc"
./install.sh
```

Nothing is tracked unless it is moved in deliberately. That matters, because
several config directories hold credentials that must stay out of this repo:

- `~/.config/gh` (GitHub auth token)
- `~/.config/git` (may hold credential helper output)
- `~/.ssh` (private keys)
- `~/.aws`, `~/.docker` (session credentials)

Check what you are about to add before adding it.

## Doom Emacs

Doom itself lives in `~/.config/emacs` and is not tracked here; only the
user config is. On a new machine, install Doom before running
`install.sh` (or run `doom sync` right after):

```sh
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

After changing `init.el` or `packages.el`:

```sh
~/.config/emacs/bin/doom sync
```

The theme is tuned around `doom-font` in `config.el` -- **Roboto Mono**
(`brew install --cask font-roboto-mono`) -- which is not installed by
`doom sync` and not tracked in this repo. Without it Emacs silently falls
back to a different font, and the spacing `nano-theme.el` assumes (line
height, label padding) will be slightly off.

Name, email, and org file locations are personal, so `config.el` doesn't
have them -- it loads `doom/config.local.el` instead, which is gitignored:

```sh
cp doom/config.local.el.example doom/config.local.el
# then edit doom/config.local.el with your own name, email, and org paths
```

Without it, Emacs still starts, just with placeholder values and no org
files configured.

Two things in `doom/` look like clutter but are not:

- `themes/doom-nano-{light,dark}-theme.el` are deliberate copies. The
  `doom-nano-themes` package directory is not on `custom-theme-load-path`,
  and it ships a stale `.elc` that fails to load, so the theme files have to
  be copied here. This is what that package's README instructs.
- `nano-agenda.el` and `nano-calendar.el` are vendored, not packages.
  `nano-agenda` is autoloaded from `config.el`.
