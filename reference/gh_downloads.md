# Retrieve download counts of release assets

Downloads the list of release assets of one or more repositories
together with their all-time download counts.

## Usage

``` r
gh_downloads(repo, token = gh_token(), max_pages = Inf)
```

## Arguments

- repo:

  Character vector of repositories in `"owner/repo"` form.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- max_pages:

  Number of pages (of 100 releases each) to retrieve at most per
  repository.

## Value

A `data.table` with columns `repo`, `release` (the tag name),
`published_at` (`POSIXct`, UTC), `asset` (file name), and `downloads`
(all-time download count). Repositories without release assets
contribute no rows.

## See also

Other retrieval:
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
[`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md),
[`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gh_downloads("quarto-dev/quarto-cli")
} # }
```
