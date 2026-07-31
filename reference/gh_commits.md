# Retrieve the commit history of one or more repositories

Downloads the commit history of one or more GitHub repositories as a
[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).
By default the entire history is retrieved; use `since`/`until` (or
`max_pages`) to subset it.

## Usage

``` r
gh_commits(
  repo,
  since = NULL,
  until = NULL,
  path = NULL,
  token = gh_token(),
  max_pages = Inf
)
```

## Arguments

- repo:

  Character vector of repositories in `"owner/repo"` form, e.g.,
  `"UofUEpiBio/epiworld"`. When more than one repository is passed, the
  results are stacked (the `repo` column identifies each one).

- since, until:

  Optional lower/upper bounds for the commit time. Can be `Date`,
  `POSIXct`, or character (`"YYYY-MM-DD"` or full ISO 8601).

- path:

  Optional character scalar. Only commits touching this file path are
  returned.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- max_pages:

  Number of pages (of 100 commits each) to retrieve at most per
  repository. Defaults to `Inf` (the full history).

## Value

A `data.table` with one row per commit, sorted from oldest to newest,
and columns:

- `repo`: the repository (`"owner/repo"`).

- `sha`: commit hash.

- `author`: GitHub login of the author (`NA` if not linked to an
  account).

- `author_name`, `author_email`: name/email recorded in the commit.

- `committer`: name of the committer (e.g., `"GitHub"` for squash merges
  done through the web interface).

- `date`: author timestamp as `POSIXct` (UTC).

- `message`: full commit message.

## Details

Line counts are not part of GitHub's commit-list endpoint; pipe the
result into
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md)
to add them.

## See also

Other retrieval:
[`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md),
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
[`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md),
[`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md),
[`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
commits <- gh_commits("UofUEpiBio/epiworld", since = "2024-01-01")

# Piping into the classifier and the plotting function
gh_commits("UofUEpiBio/epiworld") |>
  ai_classify() |>
  plot_timeline()
} # }
```
