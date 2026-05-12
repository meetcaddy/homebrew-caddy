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

  def post_install
    claude_dir = Pathname.new(Dir.home)/".claude"
    commands_dir = claude_dir/"commands"
    commands_dir.mkpath

    target_commands = commands_dir/"paul"
    target_commands.unlink if target_commands.symlink? || target_commands.exist?
    target_commands.make_symlink(pkgshare/"commands"/"paul")

    target_framework = claude_dir/"paul-framework"
    target_framework.unlink if target_framework.symlink? || target_framework.exist?
    target_framework.make_symlink(pkgshare/"framework")
  end

  def caveats
    <<~EOS
      PAUL framework installed. Symlinks created at:
        ~/.claude/commands/paul/
        ~/.claude/paul-framework/

      Run /paul:init in any project to set up PAUL planning.
      Then /paul:plan, /paul:audit (optional), /paul:apply, /paul:unify.

      Note: v0.1.0 ships PAUL's 4 core phase commands. The 8 specialist
      subagents + paul-sdk CLI are scheduled for v0.2.x; PAUL operates
      in degraded direct-model mode without them.

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
