class CaddyPaul < Formula
  desc "PAUL framework for Caddy customers (PLAN/AUDIT/APPLY/UNIFY workflow loops)"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/paul.git",
      revision: "e023ad5710a8497b3db5868782ed8b3d5ffdf1af",
      using:    :git
  version "0.2.0"
  license :cannot_represent

  def install
    pkgshare.install Dir["*"]
  end

  def caveats
    <<~EOS
      PAUL framework files installed to:
        #{opt_pkgshare}

      To activate in ~/.claude/, run the caddy-link helper:
        caddy-link

      caddy-link ships with the caddy-frameworks meta-formula:
        brew install caddy-frameworks

      Or manually symlink (one command):
        ln -sfn "#{opt_pkgshare}/commands/paul" ~/.claude/commands/paul && \\
        ln -sfn "#{opt_pkgshare}/framework" ~/.claude/paul-framework

      Commands installed (28 — type /paul: in Claude Code for the full menu):
        /paul:init      scaffold .paul/ in a project
        /paul:plan      run PLAN phase
        /paul:audit     run AUDIT phase
        /paul:apply     run APPLY phase
        /paul:unify     close loop with SUMMARY.md
        /paul:status    smart status with routing
        plus research, discuss, milestone, verify, handoff, resume,
        and the rest of the 28-command loop.

      Note: v0.2.0 also ships the 12 specialist subagents (agents/);
      caddy-link links them into ~/.claude/agents/. See VERSION-NOTES.md
      in the share directory for per-release contents.

      To uninstall:
        brew uninstall caddy-paul
        rm ~/.claude/commands/paul ~/.claude/paul-framework
    EOS
  end

  test do
    assert_predicate pkgshare/"commands"/"paul", :directory?
    assert_predicate pkgshare/"framework", :directory?
  end
end
