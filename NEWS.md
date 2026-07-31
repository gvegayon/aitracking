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
