#' Retrieve user interactions within a repository
#'
#' Downloads issues, pull requests, issue/PR comments, and pull request review
#' comments of one or more repositories. This is the conversation layer of a
#' project--including the requests humans make to AI agents in issues and
#' PRs--which survives even when the commits themselves are squash-merged.
#'
#' @param repo Character vector of repositories in `"owner/repo"` form.
#' @param since Optional lower time bound (`Date`, `POSIXct`, or character).
#' Note that, following the GitHub API, for issues/PRs this filters by *last
#' update* time, and for comments by *creation* time.
#' @param token GitHub token (see [gh_token()]).
#' @param max_pages Number of pages (of 100 records each) to retrieve at most
#' per repository and record type.
#'
#' @return A `data.table` with one row per interaction, sorted by time, and
#' columns:
#' - `repo`: the repository.
#' - `type`: one of `"issue"`, `"pull_request"`, `"issue_comment"` (comments
#'   on issues *and* PRs), or `"review_comment"` (inline code-review comments
#'   on PRs).
#' - `number`: the issue/PR number the interaction belongs to.
#' - `user`: GitHub login of the user (bots show as, e.g.,
#'   `"copilot[bot]"`).
#' - `created_at`: creation time (`POSIXct`, UTC).
#' - `title`: issue/PR title (`NA` for comments).
#' - `body`: full text of the issue/PR description or comment.
#'
#' @details
#' Combine with [ai_classify()] to flag which interactions were authored by AI
#' agents (`ai`) and which ones mention or address an AI agent
#' (`ai_mention`)--the latter is a simple proxy for how much humans are
#' prompting AI within the repository.
#'
#' @examples
#' \dontrun{
#' gh_interactions("UofUEpiBio/epiworld") |>
#'   ai_classify()
#' }
#' @family retrieval
#' @export
gh_interactions <- function(
    repo, since = NULL, token = gh_token(), max_pages = Inf
    ) {

  if (length(repo) > 1L)
    return(data.table::rbindlist(lapply(
      repo, gh_interactions, since = since, token = token,
      max_pages = max_pages
    )))

  s <- fmt_gh_time(since)

  issues <- gh_api(
    sprintf("/repos/%s/issues", repo), state = "all", since = s,
    token = token, max_pages = max_pages
  )

  icomments <- gh_api(
    sprintf("/repos/%s/issues/comments", repo), since = s,
    token = token, max_pages = max_pages
  )

  rcomments <- gh_api(
    sprintf("/repos/%s/pulls/comments", repo), since = s,
    token = token, max_pages = max_pages
  )

  out <- rbind(
    as_issues_dt(issues, repo),
    as_comments_dt(icomments, repo, "issue_comment", "issue_url"),
    as_comments_dt(rcomments, repo, "review_comment", "pull_request_url")
  )

  data.table::setorder(out, repo, created_at)
  out[]
}

# Parsed issue/PR records -> data.table
as_issues_dt <- function(issues, repo) {
  data.table::data.table(
    repo       = rep(repo, length(issues)),
    type       = vapply(
      issues,
      function(x) if (is.null(x$pull_request)) "issue" else "pull_request",
      character(1L)
      ),
    number     = vapply(issues, function(x) int1(x$number), integer(1L)),
    user       = vapply(issues, function(x) chr1(x$user$login), character(1L)),
    created_at = parse_gh_time(
      vapply(issues, function(x) chr1(x$created_at), character(1L))
      ),
    title      = vapply(issues, function(x) chr1(x$title), character(1L)),
    body       = vapply(issues, function(x) chr1(x$body), character(1L))
  )
}

# Parsed comment records -> data.table. `url_field` names the field holding
# the parent issue/PR URL, whose trailing number identifies the thread.
as_comments_dt <- function(items, repo, type, url_field) {
  data.table::data.table(
    repo       = rep(repo, length(items)),
    type       = rep(type, length(items)),
    number     = vapply(
      items, function(x) int_from_url(x[[url_field]]), integer(1L)
      ),
    user       = vapply(items, function(x) chr1(x$user$login), character(1L)),
    created_at = parse_gh_time(
      vapply(items, function(x) chr1(x$created_at), character(1L))
      ),
    title      = rep(NA_character_, length(items)),
    body       = vapply(items, function(x) chr1(x$body), character(1L))
  )
}
