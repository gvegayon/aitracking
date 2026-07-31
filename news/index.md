# Changelog

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
