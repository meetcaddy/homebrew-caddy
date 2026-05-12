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
