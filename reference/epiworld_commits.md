# Commit history of the UofUEpiBio/epiworld C++ library

Full commit history of the
[epiworld](https://github.com/UofUEpiBio/epiworld) C++ header-only
library for agent-based epidemiological simulations, including
per-commit line counts. Snapshot taken on 2026-07-31 with
`gh_commits("UofUEpiBio/epiworld") |> gh_commit_lines()` (see
`data-raw/epiworld.R` in the package sources).

## Usage

``` r
epiworld_commits
```

## Format

A `data.table` with one row per commit and columns `repo`, `sha`,
`author`, `author_name`, `author_email`, `committer`, `date`, `message`,
`additions`, and `deletions`. See
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md)
and
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md)
for details.

## Source

GitHub REST API, <https://github.com/UofUEpiBio/epiworld>.

## See also

Other data:
[`epiworld_assignments`](https://gvegayon.github.io/aitracking/reference/epiworld_assignments.md),
[`epiworld_interactions`](https://gvegayon.github.io/aitracking/reference/epiworld_interactions.md),
[`epiworld_pulls`](https://gvegayon.github.io/aitracking/reference/epiworld_pulls.md)
