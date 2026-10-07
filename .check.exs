[
  ## don't run tools concurrently
  # parallel: false,

  ## don't print info about skipped tools
  # skipped: false,

  ## always run tools in fix mode (put it in ~/.check.exs locally, not in project config)
  # fix: true,

  ## don't retry automatically even if last run resulted in failures
  retry: false,

  ## list of tools (see `mix check` docs for a list of default curated tools)
  tools: [
    ## curated tools may be disabled (e.g. the check for compilation warnings)
    # {:compiler, false},
    {:npm_test, false},
    {:sobelow, false},
    {:doctor, false},

    ## ...or have command & args adjusted (e.g. enable skip comments for sobelow)
    # {:sobelow, "mix sobelow --exit --skip"},

    ## ...or reordered (e.g. to see output from dialyzer before others)
    # {:dialyzer, order: -1},

    ## ...or reconfigured (e.g. disable parallel execution of ex_unit in umbrella)
    # {:ex_unit, umbrella: [parallel: false]},
    {:gettext, "mix gettext.extract --check-up-to-date",
     fix: "mix gettext.extract --merge priv/gettext"},

    ## custom new tools may be added (Mix tasks or arbitrary commands)
    # run phx_schema before any other tool
    {:phx_swagger_generate, "mix phx.swagger.generate", order: -1},

    ## `mix hex.audit` can't ignore advisories, so fail only on ones not listed here:
    ##   - EEF-CVE-2026-64941 (phoenix_live_view 0.20.17): fixed only in LiveView 1.x,
    ##     remove once we've updated to LiveView 1.x
    ##   - EEF-CVE-2026-43966, EEF-CVE-2026-43969 (cowlib 2.20.0): no patched cowlib
    ##     release yet, remove once there is one
    {:hex_audit,
     [
       "sh",
       "-c",
       """
       output=$(mix hex.audit 2>&1) && exit 0
       echo "$output"
       echo "$output" | grep -q "retired" && exit 1
       ! echo "$output" | grep -E "^  [a-z_]+ [0-9.]+ - " |
         grep -vE "EEF-CVE-2026-(64941|43966|43969) "
       """
     ]}
    # {:my_task, "mix my_task", env: %{"MIX_ENV" => "prod"}},
    # {:my_tool, ["my_tool", "arg with spaces"]}
  ]
]
