class CaddyFrameworks < Formula
  desc "Meta-formula bundling Caddy's PAUL + SEED + Skillsmith + Aegis frameworks"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/homebrew-caddy.git",
      revision: "90afc7370a1a30c63d18ad7a62e0670cbce1d9d4",
      using:    :git
  version "0.1.0"
  license "MIT"

  depends_on "meetcaddy/caddy/caddy-aegis"
  depends_on "meetcaddy/caddy/caddy-paul"
  depends_on "meetcaddy/caddy/caddy-seed"
  depends_on "meetcaddy/caddy/caddy-skillsmith"

  def install
    (pkgshare/"INSTALLED").write("Caddy frameworks meta-package v0.1.0\n")

    (bin/"caddy-link").write <<~SHELL
      #!/usr/bin/env bash
      # caddy-link: create symlinks from ~/.claude/ to installed Caddy
      # framework files in the Homebrew Cellar. Idempotent.
      #
      # Runs outside the Homebrew sandbox so it can write to ~/.claude/.

      set -e

      claude_dir="$HOME/.claude"
      commands_dir="$claude_dir/commands"
      mkdir -p "$commands_dir"

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

      paul_pkg="$(brew --prefix caddy-paul 2>/dev/null)"
      if [ -n "$paul_pkg" ]; then
        link_one "PAUL commands"  "$commands_dir/paul"            "$paul_pkg/share/caddy-paul/commands/paul"
        link_one "PAUL framework" "$claude_dir/paul-framework"    "$paul_pkg/share/caddy-paul/framework"
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
      All 4 Caddy customer-disk frameworks installed via Homebrew.

      To activate them in ~/.claude/, run:
        caddy-link

      That helper creates symlinks for whichever caddy-* formulas
      you have installed. Safe to re-run after upgrades or new
      framework installs.

      Slash commands available in Claude Code after linking
      (type each prefix in Claude Code for the full menu):

        PAUL (6 commands):
          /paul:init  /paul:plan  /paul:audit  /paul:apply  /paul:unify
          /paul:register

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

      Aegis ships with 5 external CLI deps: gitleaks, grype, semgrep,
      syft, trivy. Installed via the caddy-aegis formula.

      To uninstall everything:
        brew uninstall caddy-frameworks caddy-paul caddy-seed caddy-skillsmith caddy-aegis
        rm -rf ~/.claude/commands/{paul,seed,skillsmith,aegis}
        rm -rf ~/.claude/{paul-framework,skillsmith-specs,aegis}

      Optionally remove Aegis CLI deps too:
        brew uninstall gitleaks grype semgrep syft trivy
    EOS
  end

  test do
    assert_path_exists pkgshare/"INSTALLED"
    assert_predicate bin/"caddy-link", :executable?
  end
end
