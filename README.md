# **S**eb's **H**elpful **E**veryday **D**evtools

## Usage

```bash
# 1. Clone the repo somewhere convenient
git clone https://github.com/sebseager/shed.git <wherever>
cd <wherever>

# 2. Symlink the dotfiles into $HOME
# Any existing dotfiles are backed up to .whatever.bak.<timestamp> first
bash bin/shed install
```

Once installed, `shed` is on your `PATH`:

```bash
shed install     # symlink dotfiles into $HOME (idempotent)
shed update      # repoint symlinks after moving the shed directory, and
                 # prune links for dotfiles no longer tracked
shed uninstall   # remove every symlink shed created (backups left in place)
```

Pass `-n` / `--dry-run` to any command to preview changes without touching
anything. Every link is recorded in a manifest under
`${XDG_STATE_HOME:-~/.local/state}/shed/` so `update` and `uninstall` can find
them again even after the shed directory has moved.
