class CaddySkillsmith < Formula
  desc "Skillsmith meta-framework for building Claude Code skills (Caddy customers)"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/skillsmith.git",
      revision: "0371e973140c6a1ac900b9f0a63109bbde99b6f1",
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

    target_commands = commands_dir/"skillsmith"
    target_commands.unlink if target_commands.symlink? || target_commands.exist?
    target_commands.make_symlink(pkgshare/"commands"/"skillsmith")

    target_specs = claude_dir/"skillsmith-specs"
    target_specs.unlink if target_specs.symlink? || target_specs.exist?
    target_specs.make_symlink(pkgshare/"specs")
  end

  def caveats
    <<~EOS
      Skillsmith framework installed. Symlinks created at:
        ~/.claude/commands/skillsmith/
        ~/.claude/skillsmith-specs/

      Run /skillsmith to build or audit a Claude Code skill. The
      specs/ directory documents the syntax conventions Skillsmith
      enforces (checklists, context, entry-point, frameworks, rules,
      tasks, templates).

      To uninstall:
        brew uninstall caddy-skillsmith
        rm ~/.claude/commands/skillsmith ~/.claude/skillsmith-specs
    EOS
  end

  test do
    assert_predicate pkgshare/"commands"/"skillsmith", :directory?
    assert_predicate pkgshare/"specs", :directory?
  end
end
