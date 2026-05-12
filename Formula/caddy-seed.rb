class CaddySeed < Formula
  desc "SEED ideation framework for Caddy customers (pre-PAUL idea capture)"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/seed.git",
      revision: "47d76efaebb8922c7f7b938eac4806961cec35dc",
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

    target_commands = commands_dir/"seed"
    target_commands.unlink if target_commands.symlink? || target_commands.exist?
    target_commands.make_symlink(pkgshare/"commands"/"seed")
  end

  def caveats
    <<~EOS
      SEED framework installed. Symlink created at:
        ~/.claude/commands/seed/

      Run /seed:capture to start an ideation flow; /seed:graduate to
      promote an idea into a PAUL-managed project. This Caddy
      distribution includes a type-aware routing customization to
      /seed:graduate.

      To uninstall:
        brew uninstall caddy-seed
        rm ~/.claude/commands/seed
    EOS
  end

  test do
    assert_predicate pkgshare/"commands"/"seed", :directory?
  end
end
