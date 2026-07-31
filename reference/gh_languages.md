# Retrieve the language composition of a repository

Downloads the current number of bytes of code per language, as computed
by GitHub (linguist).

## Usage

``` r
gh_languages(repo, token = gh_token())
```

## Arguments

- repo:

  Character vector of repositories in `"owner/repo"` form.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

## Value

A `data.table` with columns `repo`, `language`, `bytes`, and `share`
(proportion of bytes within the repository).

## Details

This is a *current* snapshot. For the evolution of project size over
time, see
[`loc_evolution()`](https://gvegayon.github.io/aitracking/reference/loc_evolution.md).

## See also

Other retrieval:
[`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md),
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
[`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md),
[`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gh_languages("UofUEpiBio/epiworld")
} # }
```
