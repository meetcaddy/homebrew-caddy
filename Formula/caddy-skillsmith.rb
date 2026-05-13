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

  def caveats
    <<~EOS
      Skillsmith framework files installed to:
        #{opt_pkgshare}

      To activate in ~/.claude/, run the caddy-link helper:
        caddy-link

      caddy-link ships with the caddy-frameworks meta-formula:
        brew install caddy-frameworks

      Or manually symlink:
        ln -sfn "#{opt_pkgshare}/commands/skillsmith" ~/.claude/commands/skillsmith && \\
        ln -sfn "#{opt_pkgshare}/specs" ~/.claude/skillsmith-specs

      Commands installed (type /skillsmith: in Claude Code for the full menu):
        /skillsmith:skillsmith            entry-point (build a skill)
        /skillsmith:tasks:audit           audit an existing skill
        /skillsmith:tasks:distill         distill a skill from examples
        /skillsmith:tasks:scaffold        scaffold a new skill
        /skillsmith:tasks:discover        discover skill candidates
        /skillsmith:rules:*               6 rule sets (tasks, context,
                                          templates, frameworks,
                                          checklists, entry-point)
        /skillsmith:templates:skill-spec  skill spec template

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
