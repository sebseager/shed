# **S**eb's **H**elpful **E**veryday **D**evtools

## Usage

```bash
# 1. Clone the repo somewhere convenient
git clone https://github.com/sebseager/shed.git <wherever>
cd <wherever>

# 2. Symlink the dotfiles into $HOME
bash bin/shed install
```

Once installed, `shed` is on your `PATH`:

```bash
shed install     # symlink dotfiles into $HOME (idempotent). re-run any time
                 # to sync: links new files, repoints links after the shed
                 # directory moves, prunes links for dotfiles removed from
                 # the tree
shed ignore      # list ignored paths; `shed ignore <path>...` adds paths
shed unignore    # pick ignored paths to remove (or pass paths, or --all)
shed uninstall   # remove every symlink shed created (backups left in place)
```

Declare paths as yours with `shed ignore`:

```bash
shed ignore ~/.ssh ~/.bashrc
```

Ignored paths are user territory: shed never links into them or their descendants,
and if a path you ignore already holds shed links, the next `shed install`
evicts them (any backup of your original file stays put). `ignore` and `unignore`
only edit the persisted set. Only running `shed install` actually applies things.

Run from a terminal, `shed install` lists its changes and asks before applying
them. It also asks what to do with each file of yours that is in the way
(replace it, skip it, or ignore it from now on) and whether to update a git
submodule that is out of date. Use `-y` / `--yes` to skip the questions and
take the defaults, which is also what happens when there is no terminal. Use
`-S` / `--skip-modules` to leave submodules alone.

Use `-n` / `--dry-run` to preview changes without touching anything. Every
link is recorded in a manifest under `${XDG_STATE_HOME:-~/.local/state}/shed/`
so a later `install` or `uninstall` can find it again even after the shed
directory has moved. The ignore set lives in
`${XDG_CONFIG_HOME:-~/.config}/shed/ignore` and survives an uninstall.

Instructions for coding agents live in `agents/`. We only want to maintain 
one copy of each instruction file, so `shed install` symlinks them into their 
respective tool dirs using the mapping in `agents/links`.

If you move the shed directory itself, every symlink dangles — including the
shell bootstrapper, so `shed` silently falls off your `PATH`. Re-run install
by path to repoint everything:

```bash
bash <new-location>/bin/shed install
```
