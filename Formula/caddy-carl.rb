class CaddyCarl < Formula
  desc "CARL framework for Caddy customers (rule routing + decision logging + 31 MCP tools)"
  homepage "https://meetcaddy.com"
  url "https://github.com/meetcaddy/carl.git",
      revision: "2467983de41294deb1721df3dbb8445a720fc5b9",
      using:    :git
  version "2.1.0"
  license "MIT"

  depends_on "node"

  def install
    # The repo layout mirrors the Cellar layout 1:1 (mcp/, carl-template/,
    # schemas/, hooks/), so installation is a straight copy. The
    # customer's /caddy:carl-setup helper reads from pkgshare/mcp/ +
    # pkgshare/carl-template/ to wire CARL into a workspace's `.carl/`
    # directory. CARL ships no ~/.claude/ commands or skills, so caddy-link
    # has nothing to do here.
    #
    # 2.1.0 replaces the previous npm carl-core 2.0.2 repackaging (and its
    # revision-1 hook patch, which the repo now carries directly). On top of
    # carl-core 2.0.2 it adds: concurrency-safe carl.json writes, the
    # carl_v2_update_rule tool, local-calendar-day date stamping,
    # case-insensitive domain lookup, and v1 decision tools that write the
    # consolidated store the hook reads. See VERSION-NOTES.md.
    pkgshare.install Dir["*"]
  end

  def caveats
    <<~EOS
      CARL installed to:
        #{opt_pkgshare}

      Caddy's distribution of CARL: carl-core 2.0.2 (Chris Kahler, MIT) plus
      correctness fixes. See VERSION-NOTES.md in the share directory.

      CARL is MCP-only (31 tools, no slash commands). Recommended starting
      set (the operator-rhythm core):
        carl_v2_log_decision      carl_v2_search_decisions
        carl_v2_get_domain        carl_v2_list_domains
        carl_v2_get_config        carl_v2_stage_proposal
        carl_v2_approve_proposal  carl_v2_get_staged
      For rule maintenance:
        carl_v2_update_rule       amend a rule's text in place, preserving
                                  its id, added date, and source. Never use
                                  carl_v2_replace_rules for wording changes.
      + 22 more (v1 legacy + v2 advanced: rule CRUD, archival, domain mgmt)

      Wire CARL per-workspace by running /caddy:carl-setup inside Claude
      Code from each workspace where you want carl-mcp tools available.
    EOS
  end

  test do
    assert_predicate pkgshare/"mcp"/"index.js", :file?
    assert_predicate pkgshare/"mcp"/"tools"/"dates.js", :file?
    assert_predicate pkgshare/"carl-template"/"carl.json", :file?
    assert_predicate pkgshare/"hooks"/"carl-hook.py", :file?
  end
end
