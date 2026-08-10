# Caddy Homebrew Tap

> **Caddy customer-disk frameworks for macOS.** This tap installs PAUL + SEED + Skillsmith + Aegis into `~/.claude/` via Homebrew, for active Caddy customers.

Companion to the [Caddy plugin](https://github.com/meetcaddy/caddy-plugin) (Claude Code marketplace). The plugin ships skills and the MCP server connection; this tap ships the customer-disk frameworks that pair with it.

## Ownership

Operated by Orbital Access LLC d/b/a Meet Caddy.

Customer-facing brand: Caddy. Your unfair advantage.
Support: hi@meetcaddy.com

## Prerequisites

- macOS (Apple Silicon or Intel; Homebrew supports both)
- [Homebrew](https://brew.sh) installed
- [GitHub CLI](https://cli.github.com) installed AND authenticated via `gh auth login` (the formulas clone private repos under `meetcaddy/*`; your GitHub credentials gate that clone)
- An active Caddy subscription with collaborator access on the framework repos (granted at onboarding)

If you have not been added as a collaborator on `meetcaddy/paul`, `meetcaddy/seed`, `meetcaddy/skillsmith`, and `meetcaddy/aegis`, the install will fail at the clone step. Email hi@meetcaddy.com to confirm your access.

## Install (all 4 frameworks)

```sh
brew tap meetcaddy/caddy
brew install caddy-frameworks
```

This installs:
- PAUL (`~/.claude/commands/paul/` + `~/.claude/paul-framework/`)
- SEED (`~/.claude/commands/seed/`)
- Skillsmith (`~/.claude/commands/skillsmith/` + `~/.claude/skillsmith-specs/`)
- Aegis (`~/.claude/commands/aegis/` + `~/.claude/aegis/`)

Aegis includes 5 external CLI dependencies (semgrep, trivy, gitleaks, syft, grype) that brew auto-installs. First install takes 5 to 10 minutes total.

## Install (individual frameworks)

If you want just one framework instead of the full set:

```sh
brew tap meetcaddy/caddy
brew install caddy-paul         # PAUL only
brew install caddy-seed         # SEED only
brew install caddy-skillsmith   # Skillsmith only
brew install caddy-aegis        # Aegis only (chain-installs 5 CLI deps)
```

## What gets installed where

The formulas install framework source into Homebrew's Cellar (`/opt/homebrew/Cellar/caddy-<framework>/<version>/`) and create **symlinks** at the conventional Claude Code locations under `~/.claude/`:

| Framework | Symlinks |
|---|---|
| PAUL | `~/.claude/commands/paul/`, `~/.claude/paul-framework/` |
| SEED | `~/.claude/commands/seed/` |
| Skillsmith | `~/.claude/commands/skillsmith/`, `~/.claude/skillsmith-specs/` |
| Aegis | `~/.claude/commands/aegis/`, `~/.claude/aegis/` |

This means upgrades flow through Homebrew (`brew upgrade caddy-paul` swaps the symlink target) and the source-of-truth files are managed by brew, not loose in your home directory.

## Upgrade

```sh
brew update
brew upgrade caddy-frameworks    # or individual: brew upgrade caddy-paul
```

When Meet Caddy ships new framework versions, the tap formulas get bumped to point at new revisions. Run `brew update && brew upgrade` to pick them up.

## Uninstall

Standard Homebrew uninstall leaves the symlinks in `~/.claude/` dangling (Homebrew does not touch your home directory on uninstall). Clean up manually:

```sh
brew uninstall caddy-frameworks caddy-paul caddy-seed caddy-skillsmith caddy-aegis
rm -rf ~/.claude/commands/paul ~/.claude/commands/seed ~/.claude/commands/skillsmith ~/.claude/commands/aegis
rm -rf ~/.claude/paul-framework ~/.claude/skillsmith-specs ~/.claude/aegis
```

The 5 Aegis CLI deps (semgrep, trivy, gitleaks, syft, grype) remain installed if you also want them gone: `brew uninstall semgrep trivy gitleaks syft grype`.

## Version cadence

Each formula pins to a specific commit SHA (or a sha256-pinned artifact) in its source repo. The current pins:

- caddy-paul → `meetcaddy/paul` @ e023ad5... (0.2.0)
- caddy-seed → `meetcaddy/seed` @ ef8f7b3... (0.1.1)
- caddy-skillsmith → `meetcaddy/skillsmith` @ 0371e97... (0.1.0)
- caddy-aegis → `meetcaddy/aegis` @ f2f1b49... (0.2.0)
- caddy-carl → `meetcaddy/carl` @ 2467983... (2.1.0)
- caddy-base → npm `@chrisai/base@3.1.5` (sha256-pinned) + the Caddy rev2 patch (sha256-pinned)

This means you get the EXACT framework version tested for that tap release; `brew upgrade` is the only path to a newer version.

## Troubleshooting

**`fatal: could not read Username for 'https://github.com'`** during install: your GitHub credentials are not configured. Run `gh auth login` and retry.

**`Permission denied (publickey)`** during install: you may be hitting an SSH path instead of HTTPS. Confirm `gh auth status` shows `Git operations protocol: https`.

**Symlinks not appearing** after `brew install`: confirm the install completed without error. Re-run `brew reinstall caddy-paul` to re-trigger post_install.

**Aegis CLI deps fail to install**: `brew install semgrep trivy gitleaks syft grype` manually, then `brew reinstall caddy-aegis`.

## Support

Questions, install help, framework access: **hi@meetcaddy.com**

Operator: Tucker Bern (Manager, Orbital Access LLC d/b/a Meet Caddy)
