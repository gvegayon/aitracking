# Pull requests of UofUEpiBio/epiworld

Pull requests of the [epiworld](https://github.com/UofUEpiBio/epiworld)
repository, including the head branch name, which carries the agent
branch prefixes (`copilot/`, `codex/`) used by
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
as suspected-involvement evidence. Snapshot taken on 2026-07-31 with
`gh_pulls("UofUEpiBio/epiworld")` (see `data-raw/epiworld.R` in the
package sources).

## Usage

``` r
epiworld_pulls
```

## Format

A `data.table` with one row per pull request and columns `repo`,
`number`, `title`, `user`, `branch`, `base`, `state`, `draft`,
`created_at`, `merged_at`, and `closed_at`. See
[`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md)
for details.

## Source

GitHub REST API, <https://github.com/UofUEpiBio/epiworld>.

## See also

Other data:
[`epiworld_assignments`](https://gvegayon.github.io/aitracking/reference/epiworld_assignments.md),
[`epiworld_commits`](https://gvegayon.github.io/aitracking/reference/epiworld_commits.md),
[`epiworld_interactions`](https://gvegayon.github.io/aitracking/reference/epiworld_interactions.md)
