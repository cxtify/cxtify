# cxtify

**cxtify** (say "see-ex-tify"; `ctxify` works as an alias) stores, syncs and inherits Claude Code project context: the `.cxtify/` folder that the `/cxtify` skill maintains in every project. This repo publishes the command-line client: releases and installers. The client always talks to https://cxtify.com.

## Quick setup

Windows (PowerShell):

```powershell
irm https://cxtify.com/install.ps1 | iex
```

macOS / Linux:

```sh
curl -fsSL https://cxtify.com/install.sh | sh
```

Then:

```sh
cxtify login   # opens the browser, stores a token
cd my-project
cxtify link my-project                      # binds the folder to a topic (creates it if missing)
```

That is all. The installer puts the `cxtify` binary on your `PATH` and installs the `/cxtify` skill into `~/.claude/skills/cxtify/`. No PHP, no Node, nothing else to install.

Other ways to install:

- Homebrew (macOS/Linux): `brew install cxtify/tap/cxtify`
- Scoop (Windows): `scoop bucket add cxtify https://github.com/cxtify/scoop-bucket && scoop install cxtify`
- `.deb` / `.rpm` and plain archives: [Releases](https://github.com/cxtify/cxtify/releases)

## Daily use

| Command | What it does |
|---|---|
| `cxtify status` | Compares `.cxtify/` with the server: up to date, ahead, behind, diverged, merge pending |
| `cxtify pull` | Brings the server head into `.cxtify/`. Files you changed locally are kept; true conflicts park the server copy in `.cxtify/.merge/remote/` (and the common ancestor in `.merge/base/`) for `/cxtify` to merge |
| `cxtify push -m "…"` | Sends your changes as a new revision. Refuses when the server moved (pull first), when merges are pending, or when something looks like a secret |
| `cxtify log` | Recent revisions of the linked topic |
| `cxtify inherit add <topic>[@rev]` | Inherit another topic's conventions, gotchas, glossary, runbook and decisions (read-only, under `.cxtify/inherited/<topic>/`); `list` / `remove` too. Parents of parents follow automatically, up to 3 levels |
| `cxtify whoami` / `logout` | Token housekeeping |

Inside Claude Code, `/cxtify load` and `/cxtify save` call these for you. Pushing is never automatic.

## How it works

- `.cxtify.json` at the project root (committed) says which topic and parents the folder uses.
- `.cxtify/` holds the context files. By default it is git-ignored and synced through the server (`"storage": "server"`). Use `cxtify link <topic> --storage repo` to keep the files in git instead.
- `.cxtify/.base/` is the per-clone snapshot of the last synced revision, used for three-way decisions. `local.md`, `.base/`, `.merge/` and `inherited/` never leave your machine.
- The server stores immutable, content-addressed revisions. A push must name the revision it was based on, so nothing is ever silently overwritten.
- Topics can inherit from others, for example every project from a team-wide `base` topic. `cxtify status` tells you when a parent has moved; `cxtify pull` refreshes it. Pin a parent with `@<revision>` when you want it frozen.

Token: stored in `%APPDATA%\cxtify\config.json` (Windows) or `~/.config/cxtify/config.json`. `CXTIFY_TOKEN` overrides it, handy for CI.

## License

The binaries are distributed under the [cxtify Binary License](LICENSE). Source code is not published.
