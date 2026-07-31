# aitracking (development version)

* New `gh_assignments()`: issues and pull requests together with the accounts
  they are assigned to, flagging the ones delegated to an AI coding agent
  (`assigned_ai`, `assigned_agent`). Assigning an issue to Copilot is how the
  coding agent is given a task, so these rows measure *delegation* to AI
  rather than AI involvement in the resulting code.
* New `gh_pulls()`: pull requests including the head branch name.
* New `gh_copilot_metrics()` and `gh_copilot_seats()`: organization-level
  Copilot usage. Note that usage metrics require organization ownership and
  the "Copilot usage metrics" policy; there is no public per-repository
  endpoint, and no endpoint exposes tokens or hours spent.
* `ai_classify()` now reports evidence in two tiers. `ai` stays **confirmed**
  involvement (agent identity, or an attribution trailer); the new
  `ai_suspected` marks **suspected** involvement, currently agent branch
  prefixes such as `copilot/...` or `codex/...`. A branch prefix is weaker
  evidence because a human may create the branch on the agent's behalf. The
  new `ai_evidence` column records which rule fired
  (`"identity"`/`"trailer"`/`"branch"`), and `assignee` and `branch` columns
  are now scanned by default.
* `ai_classify()` recognizes the `Assisted-by:` trailer alongside
  `Co-authored-by:` and `Generated with`.
* `ai_patterns()` gained `jules` and `coderabbit`, and split Jules out of the
  `gemini` pattern.
* `plot_timeline()` draws suspected AI involvement as its own band, so the
  confirmed count is never inflated by it.
* Failed API requests now report the HTTP status and its likely cause
  (bad token, exhausted rate limit, missing scope, org policy) instead of a
  generic connection error.
* New example datasets `epiworld_assignments` and `epiworld_pulls`.

# aitracking 0.1.0

* First public version. Includes:
  - GitHub REST API access with base R connections (`gh_api()`, `gh_token()`).
  - Commit history retrieval with per-commit line counts (`gh_commits()`,
    `gh_commit_lines()`).
  - Traffic, release-download, interaction, and language retrieval
    (`gh_traffic()`, `gh_downloads()`, `gh_interactions()`,
    `gh_languages()`).
  - Rule-based AI-involvement classification (`ai_classify()`,
    `ai_patterns()`).
  - Project size evolution (`loc_evolution()`) and activity timelines
    (`plot_timeline()`).
  - Example datasets from the UofUEpiBio/epiworld C++ library.
