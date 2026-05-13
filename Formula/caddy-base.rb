class CaddyBase < Formula
  desc "BASE framework for Caddy customers (workspace orchestration + base-mcp)"
  homepage "https://meetcaddy.com"
  url "https://registry.npmjs.org/@chrisai/base/-/base-3.1.5.tgz"
  sha256 "82a3c7228969b70f047df73f4db9a5c5865bcefff3494b8a441fbc053e6d83ed"
  version "3.1.5"
  license "MIT"

  depends_on "node"

  def install
    # The npm tarball extracts as `package/<contents>` at the cwd root.
    # We mirror the layout that Charles's `bin/install.js` produces in
    # `~/.claude/`, so `caddy-link` can do simple per-tree symlinks.
    #
    # Final Cellar layout:
    #   pkgshare/commands/         → linked to ~/.claude/commands/base
    #   pkgshare/skill/            → linked to ~/.claude/skills/base
    #     ├── base.md
    #     └── packages/base-mcp/
    #   pkgshare/framework/        → linked to ~/.claude/base-framework
    #     ├── context/
    #     ├── frameworks/
    #     ├── hooks/
    #     ├── packages/base-mcp/    (Stage 5a source; per-workspace copy target)
    #     ├── tasks/
    #     ├── templates/
    #     └── utils/

    # Slash commands (15 + orientation/ subtree).
    (pkgshare/"commands").install Dir["src/commands/*"]

    # Framework support files.
    (pkgshare/"framework").install Dir["src/framework/*"]

    # base-mcp lives at framework/packages/base-mcp/ (Stage 5a source path
    # that /caddy:base-setup copies into the customer's workspace).
    (pkgshare/"framework"/"packages"/"base-mcp").install Dir["src/packages/base-mcp/*"]

    # Suite anchor skill: directory containing base.md + co-located
    # packages/base-mcp/ (matches Charles's installer layout for skills/base/).
    (pkgshare/"skill").install "src/skill/base.md"
    (pkgshare/"skill"/"packages"/"base-mcp").install Dir["src/packages/base-mcp/*"]
  end

  def caveats
    <<~EOS
      BASE framework files installed to:
        #{opt_pkgshare}

      To activate in ~/.claude/, run the caddy-link helper:
        caddy-link

      caddy-link ships with the caddy-frameworks meta-formula:
        brew install caddy-frameworks

      After linking, BASE provides:
        - /base:* slash commands (15: audit, scaffold, groom, weekly, ...)
        - "base" suite anchor skill (auto-activates on workspace mentions)
        - base-mcp source files (per-workspace MCP wiring via /caddy:base-setup)

      base-mcp wiring is per-workspace, not global. After installing the
      Caddy plugin, run /caddy:base-setup inside Claude Code from each
      workspace where you want base-mcp tools available.

      Upstream: @chrisai/base v3.1.5 by Christopher Kahler (MIT)

      To uninstall:
        brew uninstall caddy-base
        rm -rf ~/.claude/commands/base ~/.claude/skills/base ~/.claude/base-framework
    EOS
  end

  test do
    assert_predicate pkgshare/"commands"/"scaffold.md", :file?
    assert_predicate pkgshare/"skill"/"base.md", :file?
    assert_predicate pkgshare/"framework"/"tasks", :directory?
    assert_predicate pkgshare/"framework"/"packages"/"base-mcp"/"index.js", :file?
    assert_predicate pkgshare/"skill"/"packages"/"base-mcp"/"index.js", :file?
  end
end
