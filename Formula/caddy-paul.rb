class CaddyPaul < Formula
  desc "PAUL framework for Caddy customers (PLAN/AUDIT/APPLY/UNIFY workflow loops)"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/paul.git",
      revision: "ab34d00912d7165a417dff83a518c797a02a8461",
      using:    :git
  version "0.1.0"
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

      Note: v0.1.0 ships PAUL's 4 core phase commands (init, plan,
      audit, apply, unify). The 8 specialist subagents + paul-sdk CLI
      are scheduled for v0.2.x; PAUL operates in degraded direct-model
      mode without them.

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
