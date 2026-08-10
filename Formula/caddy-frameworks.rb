class CaddyFrameworks < Formula
  desc "Meta-formula bundling Caddy's BASE + CARL + PAUL + SEED + Skillsmith + Aegis frameworks"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/homebrew-caddy.git",
      revision: "90afc7370a1a30c63d18ad7a62e0670cbce1d9d4",
      using:    :git
  version "0.4.0"
  license "MIT"

  depends_on "meetcaddy/caddy/caddy-aegis"
  depends_on "meetcaddy/caddy/caddy-base"
  depends_on "meetcaddy/caddy/caddy-carl"
  depends_on "meetcaddy/caddy/caddy-paul"
  depends_on "meetcaddy/caddy/caddy-seed"
  depends_on "meetcaddy/caddy/caddy-skillsmith"

  def install
    (pkgshare/"INSTALLED").write("Caddy frameworks meta-package v0.4.0\n")

    (bin/"caddy-link").write <<~SHELL
      #!/usr/bin/env bash
      # caddy-link: create symlinks from ~/.claude/ to installed Caddy
      # framework files in the Homebrew Cellar. Idempotent.
      #
      # Runs outside the Homebrew sandbox so it can write to ~/.claude/.

      set -e

      claude_dir="$HOME/.claude"
      commands_dir="$claude_dir/commands"
      skills_dir="$claude_dir/skills"
      mkdir -p "$commands_dir" "$skills_dir"

      link_one() {
        local label="$1"
        local target="$2"
        local source="$3"
        if [ ! -e "$source" ]; then
          echo "  - $label: source not installed, skipping"
          return 0
        fi
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "  ! $label: $target exists and is not a symlink"
          echo "    Move it aside first: mv \\"$target\\" \\"$target.bak\\""
          return 1
        fi
        ln -sfn "$source" "$target"
        echo "  + $label: $target -> $source"
      }

      echo "==> Linking Caddy frameworks into $claude_dir"

      base_pkg="$(brew --prefix caddy-base 2>/dev/null)"
      if [ -n "$base_pkg" ]; then
        link_one "BASE commands"  "$commands_dir/base"            "$base_pkg/share/caddy-base/commands"
        link_one "BASE skill"     "$skills_dir/base"              "$base_pkg/share/caddy-base/skill"
        link_one "BASE framework" "$claude_dir/base-framework"    "$base_pkg/share/caddy-base/framework"
      fi

      # CARL has no ~/.claude/ targets to symlink (ships no slash commands or skills).
      # Inform the customer where the source lives and point at /caddy:carl-setup.
      carl_pkg="$(brew --prefix caddy-carl 2>/dev/null)"
      if [ -n "$carl_pkg" ]; then
        echo "  i CARL MCP source: $carl_pkg/share/caddy-carl/mcp/"
        echo "    Run /caddy:carl-setup inside Claude Code from each workspace to wire CARL."
      fi

      paul_pkg="$(brew --prefix caddy-paul 2>/dev/null)"
      if [ -n "$paul_pkg" ]; then
        link_one "PAUL commands"  "$commands_dir/paul"            "$paul_pkg/share/caddy-paul/commands/paul"
        link_one "PAUL framework" "$claude_dir/paul-framework"    "$paul_pkg/share/caddy-paul/framework"
        # PAUL specialist subagents (v0.2.0+): per-FILE symlinks, because
        # ~/.claude/agents/ is a shared directory that may hold the user's own
        # agents — never symlink or replace the directory itself.
        if [ -d "$paul_pkg/share/caddy-paul/agents" ]; then
          agents_dir="$claude_dir/agents"
          mkdir -p "$agents_dir"
          for f in "$paul_pkg/share/caddy-paul/agents/"paul-*.md; do
            [ -e "$f" ] || continue
            link_one "PAUL agent $(basename "$f")" "$agents_dir/$(basename "$f")" "$f"
          done
        fi
      fi

      seed_pkg="$(brew --prefix caddy-seed 2>/dev/null)"
      if [ -n "$seed_pkg" ]; then
        link_one "SEED commands"  "$commands_dir/seed"            "$seed_pkg/share/caddy-seed/commands/seed"
      fi

      skillsmith_pkg="$(brew --prefix caddy-skillsmith 2>/dev/null)"
      if [ -n "$skillsmith_pkg" ]; then
        link_one "Skillsmith commands" "$commands_dir/skillsmith" "$skillsmith_pkg/share/caddy-skillsmith/commands/skillsmith"
        link_one "Skillsmith specs"    "$claude_dir/skillsmith-specs" "$skillsmith_pkg/share/caddy-skillsmith/specs"
      fi

      aegis_pkg="$(brew --prefix caddy-aegis 2>/dev/null)"
      if [ -n "$aegis_pkg" ]; then
        link_one "Aegis commands"  "$commands_dir/aegis"          "$aegis_pkg/share/caddy-aegis/commands/aegis"
        link_one "Aegis framework" "$claude_dir/aegis"            "$aegis_pkg/share/caddy-aegis/framework"
      fi

      echo "==> Done."
    SHELL
    (bin/"caddy-link").chmod 0755
  end

  def caveats
    <<~EOS
      All 6 Caddy customer-disk frameworks installed via Homebrew.

      To activate them in ~/.claude/, run:
        caddy-link

      That helper creates symlinks for whichever caddy-* formulas
      you have installed. Safe to re-run after upgrades or new
      framework installs.

      Slash commands available in Claude Code after linking
      (type each prefix in Claude Code for the full menu):

        BASE (15 commands + suite anchor skill):
          /base:audit  /base:audit-claude  /base:audit-claude-md
          /base:carl-hygiene  /base:groom  /base:history
          /base:orientation  /base:pulse  /base:scaffold
          /base:status  /base:surface-convert  /base:surface-create
          /base:surface-list  /base:weekly  /base:weekly-domain

        CARL (MCP-only, no slash commands; 31 tools, ~8 starter):
          mcp__carl-mcp__carl_v2_log_decision
          mcp__carl-mcp__carl_v2_search_decisions
          mcp__carl-mcp__carl_v2_get_domain
          mcp__carl-mcp__carl_v2_list_domains
          mcp__carl-mcp__carl_v2_get_config
          mcp__carl-mcp__carl_v2_stage_proposal
          mcp__carl-mcp__carl_v2_approve_proposal
          mcp__carl-mcp__carl_v2_get_staged
          + 23 more (v1 legacy + v2 advanced: rule CRUD incl.
            carl_v2_update_rule, archival, domain mgmt)
          Wire CARL per-workspace via /caddy:carl-setup inside Claude Code.

        PAUL (28 commands + 12 specialist subagents):
          /paul:init  /paul:plan  /paul:audit  /paul:apply  /paul:unify
          /paul:status  /paul:research  /paul:milestone  /paul:verify
          ... type /paul: for the full 28-command menu. The 12 subagents
          link into ~/.claude/agents/ (research, planning, review, and
          build-stream agents).

        SEED (6 commands):
          /seed:seed
          /seed:tasks:launch  /seed:tasks:status  /seed:tasks:ideate
          /seed:tasks:graduate  /seed:tasks:add-type

        Skillsmith (12 commands):
          /skillsmith:skillsmith
          /skillsmith:tasks:audit  /skillsmith:tasks:distill
          /skillsmith:tasks:scaffold  /skillsmith:tasks:discover
          /skillsmith:rules:* (6 rule sets)
          /skillsmith:templates:skill-spec

        Aegis (10 commands):
          /aegis:init  /aegis:audit  /aegis:report  /aegis:status
          /aegis:resume  /aegis:validate  /aegis:playbook
          /aegis:transform  /aegis:remediate  /aegis:guardrails

      BASE ships a base-mcp server that wires per-workspace. After
      installing the Caddy plugin, run /caddy:base-setup inside Claude
      Code from each workspace where you want base-mcp tools available.

      CARL ships a carl-mcp server that also wires per-workspace. After
      installing the Caddy plugin, run /caddy:carl-setup inside Claude
      Code from each workspace where you want carl-mcp tools available.

      Aegis ships with 5 external CLI deps: gitleaks, grype, semgrep,
      syft, trivy. Installed via the caddy-aegis formula.

      To uninstall everything:
        brew uninstall caddy-frameworks caddy-base caddy-carl caddy-paul caddy-seed caddy-skillsmith caddy-aegis
        rm -rf ~/.claude/commands/{base,paul,seed,skillsmith,aegis}
        rm -rf ~/.claude/skills/base
        rm -rf ~/.claude/{base-framework,paul-framework,skillsmith-specs,aegis}
        # Per-workspace .carl/ and .base/ dirs NOT removed by uninstall
        # (customer-data-local); remove them manually per workspace if desired.

      Optionally remove Aegis CLI deps too:
        brew uninstall gitleaks grype semgrep syft trivy
    EOS
  end

  test do
    assert_path_exists pkgshare/"INSTALLED"
    assert_predicate bin/"caddy-link", :executable?
  end
end
