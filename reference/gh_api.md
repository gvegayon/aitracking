# Low-level access to the GitHub REST API

A minimal GitHub API client built on base R connections
([`url()`](https://rdrr.io/r/base/connections.html)), used by all the
`gh_*` retrieval functions in this package. Array-returning endpoints
are paginated automatically.

## Usage

``` r
gh_api(endpoint, ..., token = gh_token(), per_page = 100L, max_pages = Inf)
```

## Arguments

- endpoint:

  Character scalar. The API endpoint, e.g.,
  `"/repos/{owner}/{repo}/commits"` (with `{owner}`/`{repo}` already
  filled in). See <https://docs.github.com/en/rest>.

- ...:

  Named query parameters, e.g., `since = "2024-01-01T00:00:00Z"`. `NULL`
  parameters are dropped.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- per_page:

  Integer. Results per page (max. 100).

- max_pages:

  Number of pages to retrieve at most. Defaults to `Inf`, i.e., retrieve
  everything.

## Value

A list with the parsed JSON response. For paginated (array) endpoints,
the concatenated list of records across pages.

## See also

Other api:
[`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Number of stargazers of a repository
gh_api("/repos/UofUEpiBio/epiworld")$stargazers_count
} # }
```
