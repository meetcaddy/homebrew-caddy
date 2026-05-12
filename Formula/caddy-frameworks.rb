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
  end

  def caveats
    <<~EOS
      All 4 Caddy customer-disk frameworks installed:
        PAUL        (~/.claude/commands/paul/ + ~/.claude/paul-framework/)
        SEED        (~/.claude/commands/seed/)
        Skillsmith  (~/.claude/commands/skillsmith/ + ~/.claude/skillsmith-specs/)
        Aegis       (~/.claude/commands/aegis/ + ~/.claude/aegis/)

      Slash commands available in Claude Code:
        /paul:init  /paul:plan  /paul:audit  /paul:apply  /paul:unify
        /seed:capture  /seed:graduate
        /skillsmith
        /aegis:init  /aegis:audit  /aegis:guardrails

      Aegis's 5 external CLI deps (semgrep, trivy, gitleaks, syft,
      grype) are installed via the caddy-aegis formula.

      To uninstall everything:
        brew uninstall caddy-frameworks caddy-paul caddy-seed caddy-skillsmith caddy-aegis
        rm -rf ~/.claude/commands/paul ~/.claude/commands/seed
        rm -rf ~/.claude/commands/skillsmith ~/.claude/commands/aegis
        rm -rf ~/.claude/paul-framework ~/.claude/skillsmith-specs ~/.claude/aegis

      Optionally remove Aegis's CLI deps too:
        brew uninstall semgrep trivy gitleaks syft grype
    EOS
  end

  test do
    assert_path_exists pkgshare/"INSTALLED"
  end
end
