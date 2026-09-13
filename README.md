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
# 1. Clone this repo
git clone git@github.com:tilakp/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install Doom Emacs itself (not tracked here)
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# 3. Symlink this repo's configs into place
./install.sh --dry     # see what it would do
./install.sh

# 4. Personal values (name, email, org file paths) aren't tracked -- fill them in
cp doom/config.local.el.example doom/config.local.el
$EDITOR doom/config.local.el

# 5. Install the font the theme is tuned around
brew install --cask font-roboto-mono

# 6. Pull in packages and launch
~/.config/emacs/bin/doom sync
emacs
```

`install.sh` is safe to re-run. A symlink already pointing at the right place
is left alone. A real file in the way is moved to
`~/.dotfiles-backup/<timestamp>/` rather than deleted.

Steps 4 and 5 are both skippable and Emacs will still start: without step 4
you get placeholder name/email and no org files configured; without step 5
Emacs silently falls back to a different font, and the spacing
`nano-theme.el` assumes (line height, label padding) will be slightly off.

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
user config is. After changing `init.el` or `packages.el`:

```sh
~/.config/emacs/bin/doom sync
```

Two things in `doom/` look like clutter but are not:

- `themes/doom-nano-{light,dark}-theme.el` are deliberate copies. The
  `doom-nano-themes` package directory is not on `custom-theme-load-path`,
  and it ships a stale `.elc` that fails to load, so the theme files have to
  be copied here. This is what that package's README instructs.
- `nano-agenda.el` and `nano-calendar.el` are vendored, not packages.
  `nano-agenda` is autoloaded from `config.el`.
