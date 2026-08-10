class CaddyBase < Formula
  desc "BASE framework for Caddy customers (workspace orchestration + base-mcp)"
  homepage "https://meetcaddy.com"
  url "https://registry.npmjs.org/@chrisai/base/-/base-3.1.5.tgz"
  sha256 "82a3c7228969b70f047df73f4db9a5c5865bcefff3494b8a441fbc053e6d83ed"
  version "3.1.5"
  license "MIT"
  # Caddy revision 2 patches the pristine 3.1.5 payload via
  # patches/caddy-base-rev2.diff (URL-fetched, sha256-pinned; an embedded
  # DATA diff is not used because the hunks contain UTF-8 and Homebrew
  # reads DATA as binary, which raises Encoding::CompatibilityError):
  #   - new tools/dates.js: LOCAL calendar-day helpers. UTC day-extraction
  #     stamped tomorrow's date for evening writes and put groom dates out of
  #     agreement with each other.
  #   - state.js / satellite.js / projects.js: use dates.js; reserve archived
  #     project ids (archiving used to free an id for reuse, colliding with
  #     the archived record); loud non-negative drift-score floor.
  #   - framework/tasks/carl-hygiene.md: rule upkeep guidance now uses
  #     carl_v2_update_rule, never carl_v2_replace_rules (which destroys
  #     every rule's added date + source attribution).
  # Upstream npm is unchanged; these fixes are offered upstream as a patch
  # series and this revision retires when a fixed upstream version ships.
  revision 2

  depends_on "node"

  patch do
    url "https://raw.githubusercontent.com/meetcaddy/homebrew-caddy/43f3eedf13ce64748919123b77c5b9332525dde4/patches/caddy-base-rev2.diff"
    sha256 "182325d79d623cee0f8f36c546bf107ae19d47f09715cf7be478ffb64ba0e7b4"
  end

  def install
    # The npm tarball extracts as `package/<contents>` at the cwd root.
    # We mirror the layout that the upstream installer produces in
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
    # packages/base-mcp/ (matches the upstream installer layout for skills/base/).
    # Note: the first install above (framework/packages/base-mcp/) consumed
    # src/packages/base-mcp/*, so we copy from the now-resident Cellar path
    # rather than from src/. Reading src/ a second time returns an empty
    # array (the v0.2.0 bug that motivated v0.2.1).
    (pkgshare/"skill").install "src/skill/base.md"
    (pkgshare/"skill"/"packages").mkpath
    cp_r pkgshare/"framework"/"packages"/"base-mcp", pkgshare/"skill"/"packages"/"base-mcp"
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
      Caddy revision 2 adds local-calendar-date fixes and archived-id
      reservation to base-mcp, and corrects the CARL-hygiene task guidance
      (see the formula header for the full list).

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
    # Revision-2 patch artifacts present in both base-mcp copies.
    assert_predicate pkgshare/"framework"/"packages"/"base-mcp"/"tools"/"dates.js", :file?
    assert_predicate pkgshare/"skill"/"packages"/"base-mcp"/"tools"/"dates.js", :file?
    # Revision-2 hygiene fix landed.
    refute_match(/Use `carl_v2_replace_rules/, (pkgshare/"framework"/"tasks"/"carl-hygiene.md").read)
  end
end
