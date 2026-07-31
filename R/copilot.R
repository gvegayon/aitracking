#' Retrieve Copilot usage metrics for an organization or enterprise
#'
#' Wrapper around GitHub's Copilot usage metrics API, which reports how much
#' Copilot is actually being *used*---code suggestions and acceptances, chat
#' activity, active users---as opposed to what \pkg{aitracking}'s other
#' functions infer from repository history.
#'
#' @param owner Character scalar. Organization login or enterprise slug.
#' @param report One of `"organization-28-day"` (default),
#' `"organization-1-day"`, `"users-28-day"`, `"users-1-day"`,
#' `"repos-1-day"`, or `"user-teams-1-day"`. Enterprise reports use
#' `"enterprise-28-day"`/`"enterprise-1-day"` in place of the organization
#' ones.
#' @param day Date (or `"YYYY-MM-DD"`) for the `*-1-day` reports. Metrics are
#' processed once per day for the previous day, so the most recent day
#' available is yesterday.
#' @param level Either `"orgs"` (default) or `"enterprises"`.
#' @param token GitHub token (see [gh_token()]).
#'
#' @return A list with the parsed API response. For 28-day reports this is
#' the report metadata (`report_start_day`, `report_end_day`) plus
#' `download_links`; for 1-day reports, `report_day` plus `download_links`.
#' The metric values themselves live in the files behind `download_links`,
#' which are pre-signed URLs you fetch separately (they are not part of the
#' JSON response).
#'
#' @section Access requirements:
#' This endpoint is gated well beyond a normal token, which is why it is not
#' usable for arbitrary public repositories:
#' - The **"Copilot usage metrics" policy must be enabled** for the
#'   organization/enterprise. Without it every request fails with
#'   `HTTP 403` regardless of your token.
#' - You must be an **organization owner** (or enterprise owner/billing
#'   manager), with `read:org` for organization reports and
#'   `manage_billing:copilot` or `read:enterprise` for enterprise ones.
#'
#' There is **no public, per-repository endpoint** for suggestion or token
#' counts: metrics are aggregated at the organization/enterprise level (the
#' `repos-1-day` report breaks pull request activity down by repository, but
#' only within an org you administer). Nothing exposes "tokens spent" or
#' "hours used"; the closest available quantities are suggestion/acceptance
#' counts, lines suggested/accepted, and active/engaged user counts. For
#' third-party repositories, the history-based measures in this package
#' (see [ai_classify()]) are the only option.
#'
#' @seealso [gh_copilot_seats()] for seat assignment, which needs only
#' `read:org` and is therefore usable much more often.
#'
#' @examples
#' \dontrun{
#' # Requires org ownership *and* the usage-metrics policy enabled
#' m <- gh_copilot_metrics("my-org")
#' m$download_links
#'
#' # Per-repository pull request metrics for a given day
#' gh_copilot_metrics("my-org", report = "repos-1-day", day = Sys.Date() - 1)
#' }
#' @family copilot
#' @export
gh_copilot_metrics <- function(
    owner,
    report = c(
      "organization-28-day", "organization-1-day", "users-28-day",
      "users-1-day", "repos-1-day", "user-teams-1-day",
      "enterprise-28-day", "enterprise-1-day"
    ),
    day = NULL, level = c("orgs", "enterprises"), token = gh_token()
    ) {

  report <- match.arg(report)
  level  <- match.arg(level)

  one_day <- grepl("1-day$", report)

  if (one_day && is.null(day))
    stop_(
      "`report = \"", report, "\"` needs a `day` (metrics are processed ",
      "daily, so the latest available day is yesterday)."
    )

  # 28-day reports are served from a /latest sub-resource
  endpoint <- sprintf(
    "/%s/%s/copilot/metrics/reports/%s%s",
    level, owner, report, if (one_day) "" else "/latest"
  )

  gh_api(
    endpoint,
    day = if (one_day) format(as.Date(day), "%Y-%m-%d") else NULL,
    token = token
  )
}

#' Retrieve Copilot seat assignments for an organization
#'
#' Downloads the list of Copilot seats assigned in an organization, including
#' when each seat was created and when the user was last active. This is the
#' most widely accessible Copilot endpoint: unlike [gh_copilot_metrics()] it
#' needs only `read:org` (plus organization ownership) and no usage-metrics
#' policy.
#'
#' @param org Character vector of organization logins.
#' @param token GitHub token (see [gh_token()]).
#' @param max_pages Number of pages (of 100 seats each) to retrieve at most.
#'
#' @return A `data.table` with columns `org`, `user`, `created_at`,
#' `last_activity_at`, `last_activity_editor`, and `plan_type`. An
#' organization with no Copilot seats contributes no rows.
#'
#' @details
#' `last_activity_at` and `last_activity_editor` are the closest thing the
#' API offers to "how much has this person used Copilot": they tell you
#' whether and where a seat is being exercised, but not how much.
#'
#' @examples
#' \dontrun{
#' gh_copilot_seats("my-org")
#' }
#' @family copilot
#' @export
gh_copilot_seats <- function(org, token = gh_token(), max_pages = Inf) {

  if (length(org) > 1L)
    return(data.table::rbindlist(lapply(
      org, gh_copilot_seats, token = token, max_pages = max_pages
    )))

  ans <- gh_api(
    sprintf("/orgs/%s/copilot/billing/seats", org), token = token,
    max_pages = max_pages
  )

  as_seats_dt(ans$seats, org)
}

# Parsed seat records -> data.table
as_seats_dt <- function(seats, org) {

  if (!length(seats))
    return(data.table::data.table(
      org = character(), user = character(),
      created_at = parse_gh_time(character()),
      last_activity_at = parse_gh_time(character()),
      last_activity_editor = character(), plan_type = character()
    ))

  data.table::data.table(
    org                  = rep(org, length(seats)),
    user                 = vapply(
      seats, function(s) chr1(s$assignee$login), character(1L)
      ),
    created_at           = parse_gh_time(
      vapply(seats, function(s) chr1(s$created_at), character(1L))
      ),
    last_activity_at     = parse_gh_time(
      vapply(seats, function(s) chr1(s$last_activity_at), character(1L))
      ),
    last_activity_editor = vapply(
      seats, function(s) chr1(s$last_activity_editor), character(1L)
      ),
    plan_type            = vapply(
      seats, function(s) chr1(s$plan_type), character(1L)
      )
  )
}
