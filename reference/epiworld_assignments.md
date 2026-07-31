# Issue and pull request assignments of UofUEpiBio/epiworld

Issues and pull requests of the
[epiworld](https://github.com/UofUEpiBio/epiworld) repository together
with the accounts they are assigned to, including the ones delegated to
the Copilot coding agent. Snapshot taken on 2026-07-31 with
`gh_assignments("UofUEpiBio/epiworld")` (see `data-raw/epiworld.R` in
the package sources).

## Usage

``` r
epiworld_assignments
```

## Format

A `data.table` with one row per issue/assignee pair and columns `repo`,
`type`, `number`, `title`, `user`, `assignee`, `assignee_type`,
`assigned_ai`, `assigned_agent`, `state`, `created_at`, and `closed_at`.
See
[`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md)
for details.

## Source

GitHub REST API, <https://github.com/UofUEpiBio/epiworld>.

## See also

Other data:
[`epiworld_commits`](https://gvegayon.github.io/aitracking/reference/epiworld_commits.md),
[`epiworld_interactions`](https://gvegayon.github.io/aitracking/reference/epiworld_interactions.md),
[`epiworld_pulls`](https://gvegayon.github.io/aitracking/reference/epiworld_pulls.md)
