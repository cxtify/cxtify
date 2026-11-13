# cxtify

**cxtify** (say "see-ex-tify"; `ctxify` works as an alias) stores and syncs Claude Code project context: the `.cxtify/` folder that the `/cxtify` skill maintains in every project. This repo publishes the command-line client: releases and installers. The client always talks to https://cxtify.com.

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
cxtify link my-project                      # binds the folder to its primary topic (creates it if missing)
cxtify add team-rules                       # optional: also work with a shared topic, in .cxtify/topics/team-rules/
```

That is all. The installer puts the `cxtify` binary on your `PATH` and installs the `/cxtify` skill into `~/.claude/skills/cxtify/`. No PHP, no Node, nothing else to install.

Other ways to install:

- Homebrew (macOS/Linux): `brew install cxtify/tap/cxtify`
- Scoop (Windows): `scoop bucket add cxtify https://github.com/cxtify/scoop-bucket && scoop install cxtify`
- `.deb` / `.rpm` and plain archives: [Releases](https://github.com/cxtify/cxtify/releases)

## Daily use

| Command | What it does |
|---|---|
| `cxtify status` | Compares every linked topic with the server: up to date, ahead, behind, diverged, merge pending. `--topic <t>` (also on `pull`, `push`, `log`) limits a command to one topic |
| `cxtify pull` | Brings each topic's server head into its folder. Files you changed locally are kept; `journal.md` and `decisions.md` merge on their own (both sides' dated entries, newest first); other true conflicts park the server copy in that topic's `.merge/remote/` (and the common ancestor in `.merge/base/`) for `/cxtify` to merge |
| `cxtify push -m "…"` | Sends each topic's changes as a new revision of that topic. Refuses a topic when the server moved (pull first), when merges are pending, or when something looks like a secret; the other topics still go |
| `cxtify log` | Recent revisions of the primary topic (or `--topic <t>`) |
| `cxtify add <topic>` | Links a secondary topic: a full, editable copy in `.cxtify/topics/<topic>/` that syncs on its own (created on the server if missing) |
| `cxtify remove <topic>` | Unlinks a secondary topic and deletes its folder; the topic stays on the server (`--force` with unpushed changes) |
| `cxtify topics` | Every topic on the server, the primary (`*`) and secondaries (`+`) of this folder marked; `--json` for scripts |
| `cxtify unlink` | Drop the link to the server; the primary's context files stay, the secondaries' folders go (`--force` while a merge is pending or a secondary has unpushed changes) |
| `cxtify mcp` | Claude Code line and JSON block for Claude Desktop from your login token; `cxtify mcp add` runs `claude mcp add` for you. claude.ai itself connects through OAuth: add `https://cxtify.com/mcp` as a custom connector |
| `cxtify hook install` | Optional Claude Code SessionStart hook: each session in a linked folder opens with one line saying whether any linked topic needs a pull. `cxtify hook remove` takes it out |
| `cxtify whoami` / `logout` | Token housekeeping |

Inside Claude Code, `/cxtify load` and `/cxtify save` call these for you, and Claude moves or copies knowledge between your linked topics when you ask ("move this gotcha to team-rules"). Pushing is never automatic.

## How it works

- `.cxtify.json` at the project root (committed) names the folder's primary topic (`topic`) and its secondary topics (`topics`). A fresh clone needs only this file: `cxtify pull` fetches every topic.
- `.cxtify/` holds the primary topic's context files; each secondary lives in `.cxtify/topics/<topic>/`. By default it is git-ignored and synced through the server (`"storage": "server"`). Use `cxtify link <topic> --storage repo` to keep the primary's files in git instead (secondaries are never committed).
- Each topic folder's `.base/` is the per-clone snapshot of its last synced revision, used for three-way decisions. `local.md`, `.base/` and `.merge/` never leave your machine.
- The server stores immutable, content-addressed revisions. A push must name the revision it was based on, so nothing is ever silently overwritten.
- Topics are independent: the server keeps no links between them. Share knowledge by linking the same topic as a secondary in several projects; every edit goes back to that topic on push.

Token: stored in `%APPDATA%\cxtify\config.json` (Windows) or `~/.config/cxtify/config.json`. `CXTIFY_TOKEN` overrides it, handy for CI.

## License

The binaries are distributed under the [cxtify Binary License](LICENSE). Source code is not published.
