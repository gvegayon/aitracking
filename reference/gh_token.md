# Find a GitHub API token

Looks for a GitHub personal access token (PAT) in the following order:
the `token` argument itself, the `GITHUB_PAT` environment variable, the
`GITHUB_TOKEN` environment variable, and–if the gitcreds package is
installed–the git credential store (the same one used by the gh package
and the `gh` command line client).

## Usage

``` r
gh_token(token = NULL)
```

## Arguments

- token:

  Optional character scalar. If non-empty, it is returned as-is.

## Value

A character scalar with the token, or the empty string `""` when no
token was found (requests then go out unauthenticated).

## Details

All API-calling functions in aitracking take a `token` argument that
defaults to `gh_token()`, so in most setups authentication "just works":
either because `GITHUB_PAT`/`GITHUB_TOKEN` is set, or because a token is
available from the git credential store.

Unauthenticated requests are possible but heavily rate-limited by GitHub
(60 requests/hour versus 5,000/hour with a token).

## See also

Other api:
[`gh_api()`](https://gvegayon.github.io/aitracking/reference/gh_api.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gh_token() # What token would be used?
} # }
```
