class CaddyCarl < Formula
  desc "CARL framework for Caddy customers (rule routing + decision logging + 30 MCP tools)"
  homepage "https://meetcaddy.com"
  url "https://registry.npmjs.org/carl-core/-/carl-core-2.0.2.tgz"
  sha256 "43742512d64fa2970f78b86bafe9e2bdbb3e1be3154dee635eedef42696046b8"
  version "2.0.2"
  license "MIT"
  # Bumped to force reinstall without changing upstream version: patches the
  # bundled carl-hook.py to advertise the working v2 decision tools (see below).
  revision 1

  depends_on "node"

  def install
    # The npm tarball extracts as `package/<contents>` at the cwd root.
    # CARL ships NO slash commands and NO suite skills (unlike BASE).
    # Pure MCP server + workspace template + Python hook + schemas.
    #
    # Cellar layout this formula produces:
    #   pkgshare/mcp/                   # carl-mcp source (Node.js MCP server)
    #     ├── index.js
    #     ├── package.json
    #     └── tools/
    #         ├── carl-json.js          # 15 v2 tools
    #         ├── decisions.js          # 5 v1 tools
    #         ├── domains.js            # 5 v1 tools
    #         └── staging.js            # 5 v1 tools
    #   pkgshare/carl-template/         # workspace template (carl.json + sessions/)
    #     ├── carl.json
    #     └── sessions/.gitkeep
    #   pkgshare/schemas/carl.schema.json
    #   pkgshare/hooks/carl-hook.py     # CARL UserPromptSubmit hook (Python)
    #   pkgshare/bin/                   # upstream installer + migration script (kept for reference)
    #     ├── install.js
    #     └── migrate-v1-to-v2.sh
    #
    # The customer's /caddy:carl-setup helper reads from pkgshare/mcp/ + pkgshare/carl-template/
    # to wire CARL into a workspace's `.carl/` directory. No global `~/.claude/` symlinks
    # are needed because CARL ships no `commands/carl/` or `skills/carl/` content.

    # MCP server source (the heart of CARL).
    (pkgshare/"mcp").install Dir["mcp/*"]

    # Workspace template (seed for <workspace>/.carl/ on first /caddy:carl-setup).
    # The leading-dot dir name is preserved in install; Cellar path is .carl-template/.
    (pkgshare/"carl-template").install Dir[".carl-template/*"]

    # JSON schemas (validation for carl.json).
    (pkgshare/"schemas").install Dir["schemas/*"]

    # UserPromptSubmit hook (Python; advanced customer config).
    (pkgshare/"hooks").install Dir["hooks/*"]

    # Patch upstream carl-core@2.0.2 hook: its injected <decisions> block advertises
    # the RETIRED v1 decision tools (carl_log_decision / carl_search_decisions /
    # carl_get_decisions). Those read/write a per-domain store (.carl/decisions/*.json)
    # that was consolidated into .carl/carl.json (tools/carl-json.js), so they fail at
    # runtime (ENOENT). Rewrite to the working v2 tools (carl_v2_*). The string-pair
    # inreplace form raises if a target is absent, surfacing upstream drift on a future
    # version bump. Note: carl_v2_get_domain is the v2 read tool (carl_v2_get_decisions
    # does NOT exist). Durable fix lives here, in Caddy's owned layer, since the Cellar
    # copy is overwritten on every brew upgrade.
    # Block-form gsub! raises Utils::Inreplace::Error if a target is absent, so an
    # upstream rename of these strings fails the build instead of silently no-op'ing.
    inreplace pkgshare/"hooks"/"carl-hook.py" do |s|
      s.gsub! "<decisions>No decisions logged yet. Use carl_log_decision tool to start.</decisions>",
              "<decisions>No decisions logged yet. Use carl_v2_log_decision tool to start.</decisions>"
      s.gsub! "Tools: carl_search_decisions(keyword), carl_get_decisions(domain), " \
              "carl_log_decision(domain, decision, rationale, recall)",
              "Tools: carl_v2_search_decisions(keyword), carl_v2_get_domain(domain), " \
              "carl_v2_log_decision(domain, decision, rationale, recall)"
    end

    # Upstream installer + migration script (kept under share/ for advanced operators
    # who want to bootstrap CARL the upstream way; not part of /caddy:carl-setup flow).
    (pkgshare/"bin").install Dir["bin/*"]

    # README + LICENSE for provenance.
    pkgshare.install "README.md", "LICENSE"
  end

  def caveats
    <<~EOS
      CARL framework MCP source installed to:
        #{opt_pkgshare}

      CARL is MCP-only (no slash commands, no suite skills). Per-workspace
      wiring is the customer plugin's job via /caddy:carl-setup.

      After installing the Caddy plugin, run /caddy:carl-setup inside Claude
      Code from each workspace where you want CARL's rule routing +
      decision logging available.

      Customer-facing tool surface (30 MCP tools total, v1 + v2):

        v2 starter set (8 tools — read README's CARL section):
          carl_v2_log_decision      carl_v2_search_decisions
          carl_v2_get_domain        carl_v2_list_domains
          carl_v2_get_config        carl_v2_stage_proposal
          carl_v2_approve_proposal  carl_v2_get_staged

        v2 advanced (7 more tools): add_rule, remove_rule, replace_rules,
          archive_decision, update_config, create_domain, toggle_domain

        v1 legacy (15 tools): pre-v2 surface kept for back-compat;
          customers with existing CARL workspace state from caddy-live
          installs can still read it via v1 tools.

      ADVANCED: CARL ships a UserPromptSubmit hook at:
        #{opt_pkgshare}/hooks/carl-hook.py
      Customers who want CARL rule injection into every Claude Code prompt
      can register this in their ~/.claude/settings.json. Documented as
      advanced for v1.0; revisit at v1.1.

      Upstream: carl-core v2.0.2 by Christopher Kahler (MIT)
      Same upstream author as caddy-base (BASE framework).

      To uninstall:
        brew uninstall caddy-carl
        # Per-workspace .carl/ dirs are NOT removed by uninstall (customer-data-local).
        # Customer manually removes per-workspace .carl/ dirs if desired.
    EOS
  end

  test do
    assert_predicate pkgshare/"mcp"/"index.js", :file?
    assert_predicate pkgshare/"mcp"/"package.json", :file?
    assert_predicate pkgshare/"mcp"/"tools"/"carl-json.js", :file?
    assert_predicate pkgshare/"mcp"/"tools"/"decisions.js", :file?
    assert_predicate pkgshare/"mcp"/"tools"/"domains.js", :file?
    assert_predicate pkgshare/"mcp"/"tools"/"staging.js", :file?
    assert_predicate pkgshare/"carl-template"/"carl.json", :file?
    assert_predicate pkgshare/"schemas"/"carl.schema.json", :file?
    assert_predicate pkgshare/"hooks"/"carl-hook.py", :file?
  end
end
