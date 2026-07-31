# Retrieve lines added/deleted per commit

Adds per-commit line counts (`additions`, `deletions`) to a commit
history, or–with `files = TRUE`–returns the file-level detail of each
commit. Designed to be piped from
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md).

## Usage

``` r
gh_commit_lines(x, files = FALSE, token = gh_token(), verbose = interactive())
```

## Arguments

- x:

  Either a `data.frame`/`data.table` with columns `repo` and `sha` (as
  returned by
  [`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md)),
  or a character vector of repositories, in which case
  [`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md)
  is called first.

- files:

  Logical scalar. When `TRUE`, returns one row per file changed per
  commit instead of one row per commit.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- verbose:

  Logical scalar. Print a progress bar? (One API call is made per
  commit, so this can take a while for long histories.)

## Value

When `files = FALSE` (the default), a copy of `x` as a `data.table` with
two new integer columns, `additions` and `deletions`. When
`files = TRUE`, a `data.table` with columns `repo`, `sha`, `date` (if
available in `x`), `file`, `status`, `additions`, and `deletions`.

## Details

GitHub's commit-list endpoint does not include line counts, so this
function requests each commit individually
(`/repos/{repo}/commits/{sha}`), i.e., one API call per commit. With an
authenticated token the rate limit is 5,000 calls/hour. For very large
projects, consider subsetting the commit history first.

## See also

Other retrieval:
[`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md),
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
[`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md),
[`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md),
[`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
commits <- gh_commits("UofUEpiBio/epiworld") |>
  gh_commit_lines()

# File-level detail, useful for loc_evolution(<...>) by language
files <- gh_commits("UofUEpiBio/epiworld") |>
  gh_commit_lines(files = TRUE)
} # }
```
