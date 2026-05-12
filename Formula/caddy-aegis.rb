class CaddyAegis < Formula
  desc "Aegis security audit framework for Caddy customers"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/aegis.git",
      revision: "b9fcd0603bd10794c179d21c66d5a568cb441c2c",
      using:    :git
  version "0.1.0"
  license :cannot_represent

  depends_on "gitleaks"
  depends_on "grype"
  depends_on "semgrep"
  depends_on "syft"
  depends_on "trivy"

  def install
    pkgshare.install Dir["*"]
  end

  def post_install
    claude_dir = Pathname.new(Dir.home)/".claude"
    commands_dir = claude_dir/"commands"
    commands_dir.mkpath

    target_commands = commands_dir/"aegis"
    target_commands.unlink if target_commands.symlink? || target_commands.exist?
    target_commands.make_symlink(pkgshare/"commands"/"aegis")

    target_framework = claude_dir/"aegis"
    target_framework.unlink if target_framework.symlink? || target_framework.exist?
    target_framework.make_symlink(pkgshare/"framework")
  end

  def caveats
    <<~EOS
      Aegis framework installed. Symlinks created at:
        ~/.claude/commands/aegis/
        ~/.claude/aegis/

      External CLI dependencies installed via Homebrew:
        semgrep   (static analysis)
        trivy     (vulnerability scanning)
        gitleaks  (secret scanning)
        syft      (SBOM generation)
        grype     (vulnerability matching)

      Run /aegis:init in a codebase to set up Aegis scaffolding.
      Then /aegis:audit for a phased diagnostic audit, and
      /aegis:guardrails to generate project rules from findings.

      To uninstall:
        brew uninstall caddy-aegis
        rm ~/.claude/commands/aegis ~/.claude/aegis

      To also remove the 5 CLI deps:
        brew uninstall semgrep trivy gitleaks syft grype
    EOS
  end

  test do
    assert_predicate pkgshare/"commands"/"aegis", :directory?
    assert_predicate pkgshare/"framework", :directory?
    assert_predicate Formula["semgrep"].opt_bin/"semgrep", :executable?
  end
end
