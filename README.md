# cxtify

**cxtify** (say "see-ex-tify"; `ctxify` works as an alias) stores, syncs and inherits Claude Code project context: the `.cxtify/` folder that the `/cxtify` skill maintains in every project. This repo publishes the command-line client: releases and installers. Point it at the cxtify server your team runs.

## Quick setup

Windows (PowerShell):

```powershell
irm https://<your-cxtify-server>/install.ps1 | iex
```

macOS / Linux:

```sh
curl -fsSL https://<your-cxtify-server>/install.sh | sh
```

Then:

```sh
cxtify login https://<your-cxtify-server>   # opens the browser, stores a token
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
| `cxtify pull` | Brings the server head into `.cxtify/`. Files you changed locally are kept; true conflicts park the server copy in `.cxtify/.merge/` |
| `cxtify push -m "…"` | Sends your changes as a new revision. Refuses when the server moved (pull first), when merges are pending, or when something looks like a secret |
| `cxtify log` | Recent revisions of the linked topic |
| `cxtify whoami` / `logout` | Token housekeeping |

Inside Claude Code, `/cxtify load` and `/cxtify save` call these for you. Pushing is never automatic.

## How it works

- `.cxtify.json` at the project root (committed) says which server, topic and parents the folder uses.
- `.cxtify/` holds the context files. By default it is git-ignored and synced through the server (`"storage": "server"`). Use `cxtify link <topic> --storage repo` to keep the files in git instead.
- `.cxtify/.base/` is the per-clone snapshot of the last synced revision, used for three-way decisions. `local.md`, `.base/`, `.merge/` and `inherited/` never leave your machine.
- The server stores immutable, content-addressed revisions. A push must name the revision it was based on, so nothing is ever silently overwritten.

Token: stored in `%APPDATA%\cxtify\config.json` (Windows) or `~/.config/cxtify/config.json`. `CXTIFY_TOKEN` and `CXTIFY_SERVER` override it, handy for CI.

## License

The binaries are distributed under the [cxtify Binary License](LICENSE). Source code is not published.
