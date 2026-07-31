# Retrieve repository traffic (clones or views)

Downloads the clone or view history of one or more repositories from
GitHub's traffic API.

## Usage

``` r
gh_traffic(
  repo,
  metric = c("clones", "views"),
  per = c("day", "week"),
  token = gh_token()
)
```

## Arguments

- repo:

  Character vector of repositories in `"owner/repo"` form.

- metric:

  Either `"clones"` (default) or `"views"`.

- per:

  Either `"day"` (default) or `"week"`.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).
  Note that the traffic API requires **push access** to the repository.

## Value

A `data.table` with columns `repo`, `date` (`POSIXct`, UTC), `count`,
and `uniques`.

## Details

GitHub only stores traffic data for the last 14 days, so building a
longer clone history requires periodic snapshots (e.g., a scheduled
GitHub Action that appends the output of this function to a file).

For download counts of release assets–which GitHub does keep
indefinitely–see
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md).

## See also

Other retrieval:
[`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md),
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
[`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md),
[`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gh_traffic("UofUEpiBio/epiworld") # clones, last 14 days
gh_traffic("UofUEpiBio/epiworld", metric = "views", per = "week")
} # }
```
