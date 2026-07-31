# Retrieve Copilot usage metrics for an organization or enterprise

Wrapper around GitHub's Copilot usage metrics API, which reports how
much Copilot is actually being *used*—code suggestions and acceptances,
chat activity, active users—as opposed to what aitracking's other
functions infer from repository history.

## Usage

``` r
gh_copilot_metrics(
  owner,
  report = c("organization-28-day", "organization-1-day", "users-28-day", "users-1-day",
    "repos-1-day", "user-teams-1-day", "enterprise-28-day", "enterprise-1-day"),
  day = NULL,
  level = c("orgs", "enterprises"),
  token = gh_token()
)
```

## Arguments

- owner:

  Character scalar. Organization login or enterprise slug.

- report:

  One of `"organization-28-day"` (default), `"organization-1-day"`,
  `"users-28-day"`, `"users-1-day"`, `"repos-1-day"`, or
  `"user-teams-1-day"`. Enterprise reports use
  `"enterprise-28-day"`/`"enterprise-1-day"` in place of the
  organization ones.

- day:

  Date (or `"YYYY-MM-DD"`) for the `*-1-day` reports. Metrics are
  processed once per day for the previous day, so the most recent day
  available is yesterday.

- level:

  Either `"orgs"` (default) or `"enterprises"`.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

## Value

A list with the parsed API response. For 28-day reports this is the
report metadata (`report_start_day`, `report_end_day`) plus
`download_links`; for 1-day reports, `report_day` plus `download_links`.
The metric values themselves live in the files behind `download_links`,
which are pre-signed URLs you fetch separately (they are not part of the
JSON response).

## Access requirements

This endpoint is gated well beyond a normal token, which is why it is
not usable for arbitrary public repositories:

- The **"Copilot usage metrics" policy must be enabled** for the
  organization/enterprise. Without it every request fails with
  `HTTP 403` regardless of your token.

- You must be an **organization owner** (or enterprise owner/billing
  manager), with `read:org` for organization reports and
  `manage_billing:copilot` or `read:enterprise` for enterprise ones.

There is **no public, per-repository endpoint** for suggestion or token
counts: metrics are aggregated at the organization/enterprise level (the
`repos-1-day` report breaks pull request activity down by repository,
but only within an org you administer). Nothing exposes "tokens spent"
or "hours used"; the closest available quantities are
suggestion/acceptance counts, lines suggested/accepted, and
active/engaged user counts. For third-party repositories, the
history-based measures in this package (see
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md))
are the only option.

## See also

[`gh_copilot_seats()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_seats.md)
for seat assignment, which needs only `read:org` and is therefore usable
much more often.

Other copilot:
[`gh_copilot_seats()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_seats.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires org ownership *and* the usage-metrics policy enabled
m <- gh_copilot_metrics("my-org")
m$download_links

# Per-repository pull request metrics for a given day
gh_copilot_metrics("my-org", report = "repos-1-day", day = Sys.Date() - 1)
} # }
```
