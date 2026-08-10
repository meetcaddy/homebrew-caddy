class CaddyAegis < Formula
  desc "Aegis security audit framework for Caddy customers"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/aegis.git",
      revision: "f2f1b4911d5b69e75a2f4f50b3e174dc27f2a856",
      using:    :git
  version "0.2.0"
  license :cannot_represent

  depends_on "gitleaks"
  depends_on "grype"
  depends_on "semgrep"
  depends_on "syft"
  depends_on "trivy"

  def install
    pkgshare.install Dir["*"]
  end

  def caveats
    <<~EOS
      Aegis framework files installed to:
        #{opt_pkgshare}

      External CLI dependencies installed via Homebrew:
        gitleaks, grype, semgrep, syft, trivy

      To activate in ~/.claude/, run the caddy-link helper:
        caddy-link

      caddy-link ships with the caddy-frameworks meta-formula:
        brew install caddy-frameworks

      Or manually symlink:
        ln -sfn "#{opt_pkgshare}/commands/aegis" ~/.claude/commands/aegis && \\
        ln -sfn "#{opt_pkgshare}/framework" ~/.claude/aegis

      Commands installed (type /aegis: in Claude Code for the full menu):
        /aegis:init        initialize AEGIS in a target project
        /aegis:audit       run a full or targeted diagnostic audit
        /aegis:report      view the audit report
        /aegis:status      show current audit state and progress
        /aegis:resume      resume an interrupted audit
        /aegis:validate    test tool install and framework integrity
        /aegis:playbook    generate a remediation playbook
        /aegis:transform   run the full Transform pipeline post-audit
        /aegis:remediate   generate remediation plans for findings
        /aegis:guardrails  generate AI assistant rules from findings

      To uninstall:
        brew uninstall caddy-aegis
        rm ~/.claude/commands/aegis ~/.claude/aegis

      Optionally remove the 5 CLI deps:
        brew uninstall gitleaks grype semgrep syft trivy
    EOS
  end

  test do
    assert_predicate pkgshare/"commands"/"aegis", :directory?
    assert_predicate pkgshare/"framework", :directory?
    assert_predicate Formula["semgrep"].opt_bin/"semgrep", :executable?
  end
end
