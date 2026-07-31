# Changelog

## aitracking (development version)

- New
  [`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md):
  issues and pull requests together with the accounts they are assigned
  to, flagging the ones delegated to an AI coding agent (`assigned_ai`,
  `assigned_agent`). Assigning an issue to Copilot is how the coding
  agent is given a task, so these rows measure *delegation* to AI rather
  than AI involvement in the resulting code.
- New
  [`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md):
  pull requests including the head branch name.
- New
  [`gh_copilot_metrics()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_metrics.md)
  and
  [`gh_copilot_seats()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_seats.md):
  organization-level Copilot usage. Note that usage metrics require
  organization ownership and the “Copilot usage metrics” policy; there
  is no public per-repository endpoint, and no endpoint exposes tokens
  or hours spent.
- [`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
  now reports evidence in two tiers. `ai` stays **confirmed**
  involvement (agent identity, or an attribution trailer); the new
  `ai_suspected` marks **suspected** involvement, currently agent branch
  prefixes such as `copilot/...` or `codex/...`. A branch prefix is
  weaker evidence because a human may create the branch on the agent’s
  behalf. The new `ai_evidence` column records which rule fired
  (`"identity"`/`"trailer"`/`"branch"`), and `assignee` and `branch`
  columns are now scanned by default.
- [`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
  recognizes the `Assisted-by:` trailer alongside `Co-authored-by:` and
  `Generated with`.
- [`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md)
  gained `jules` and `coderabbit`, and split Jules out of the `gemini`
  pattern.
- [`plot_timeline()`](https://gvegayon.github.io/aitracking/reference/plot_timeline.md)
  draws suspected AI involvement as its own band, so the confirmed count
  is never inflated by it.
- Failed API requests now report the HTTP status and its likely cause
  (bad token, exhausted rate limit, missing scope, org policy) instead
  of a generic connection error.
- New example datasets `epiworld_assignments` and `epiworld_pulls`.

## aitracking 0.1.0

- First public version. Includes:
  - GitHub REST API access with base R connections
    ([`gh_api()`](https://gvegayon.github.io/aitracking/reference/gh_api.md),
    [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).
  - Commit history retrieval with per-commit line counts
    ([`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
    [`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md)).
  - Traffic, release-download, interaction, and language retrieval
    ([`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md),
    [`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
    [`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
    [`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md)).
  - Rule-based AI-involvement classification
    ([`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md),
    [`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md)).
  - Project size evolution
    ([`loc_evolution()`](https://gvegayon.github.io/aitracking/reference/loc_evolution.md))
    and activity timelines
    ([`plot_timeline()`](https://gvegayon.github.io/aitracking/reference/plot_timeline.md)).
  - Example datasets from the UofUEpiBio/epiworld C++ library.
