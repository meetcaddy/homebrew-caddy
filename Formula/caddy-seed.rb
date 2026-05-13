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

  def caveats
    <<~EOS
      SEED framework files installed to:
        #{opt_pkgshare}

      To activate in ~/.claude/, run the caddy-link helper:
        caddy-link

      caddy-link ships with the caddy-frameworks meta-formula:
        brew install caddy-frameworks

      Or manually symlink:
        ln -sfn "#{opt_pkgshare}/commands/seed" ~/.claude/commands/seed

      Commands installed (type /seed: in Claude Code for the full menu):
        /seed:seed             entry-point (capture an idea)
        /seed:tasks:launch     start ideation session
        /seed:tasks:status     check ideation progress
        /seed:tasks:ideate     continue ideation
        /seed:tasks:graduate   promote idea to apps/ or workflows/
        /seed:tasks:add-type   register a new project type

      To uninstall:
        brew uninstall caddy-seed
        rm ~/.claude/commands/seed
    EOS
  end

  test do
    assert_predicate pkgshare/"commands"/"seed", :directory?
  end
end
