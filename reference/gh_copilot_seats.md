# Retrieve Copilot seat assignments for an organization

Downloads the list of Copilot seats assigned in an organization,
including when each seat was created and when the user was last active.
This is the most widely accessible Copilot endpoint: unlike
[`gh_copilot_metrics()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_metrics.md)
it needs only `read:org` (plus organization ownership) and no
usage-metrics policy.

## Usage

``` r
gh_copilot_seats(org, token = gh_token(), max_pages = Inf)
```

## Arguments

- org:

  Character vector of organization logins.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- max_pages:

  Number of pages (of 100 seats each) to retrieve at most.

## Value

A `data.table` with columns `org`, `user`, `created_at`,
`last_activity_at`, `last_activity_editor`, and `plan_type`. An
organization with no Copilot seats contributes no rows.

## Details

`last_activity_at` and `last_activity_editor` are the closest thing the
API offers to "how much has this person used Copilot": they tell you
whether and where a seat is being exercised, but not how much.

## See also

Other copilot:
[`gh_copilot_metrics()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_metrics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gh_copilot_seats("my-org")
} # }
```
