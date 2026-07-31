#' Retrieve issue and pull request assignments
#'
#' Downloads the issues and pull requests of one or more repositories together
#' with the accounts they are assigned to, and flags the assignments handed to
#' an AI coding agent. Assigning an issue to an agent (e.g., selecting
#' "Copilot" in the Assignees box) is how GitHub's coding agent is asked to do
#' a task, so these rows are a direct measure of *delegation* to AI, as
#' opposed to the AI involvement in the resulting code that [gh_commits()]
#' plus [ai_classify()] measure.
#'
#' @param repo Character vector of repositories in `"owner/repo"` form.
#' @param state One of `"all"` (default), `"open"`, or `"closed"`.
#' @param since Optional lower bound on the *last update* time (`Date`,
#' `POSIXct`, or character), following the GitHub API.
#' @param ai_only Logical scalar. When `TRUE`, only assignments to AI agents
#' are returned.
#' @param patterns Named character vector of agent patterns used to decide
#' what counts as an AI assignee. See [ai_patterns()].
#' @param token GitHub token (see [gh_token()]).
#' @param max_pages Number of pages (of 100 records each) to retrieve at most
#' per repository.
#'
#' @return A `data.table` with **one row per issue/assignee pair**, sorted by
#' time, and columns:
#' - `repo`, `type` (`"issue"` or `"pull_request"`), `number`, `title`.
#' - `user`: login of the account that *opened* the issue/PR.
#' - `assignee`: login of the assigned account, `NA` when nobody is assigned.
#' - `assignee_type`: `"User"` or `"Bot"`, as reported by GitHub.
#' - `assigned_ai`: logical, `TRUE` when the assignee matches an AI agent.
#' - `assigned_agent`: which agent (`NA` otherwise).
#' - `state`, `created_at`, `closed_at`.
#'
#' Issues with several assignees contribute one row each; unassigned issues
#' contribute a single row with `assignee = NA`, so that shares (e.g., the
#' fraction of issues delegated to an agent) can be computed from the same
#' table.
#'
#' @details
#' Note that GitHub reports the Copilot coding agent as the login `Copilot`
#' with `assignee_type == "Bot"`, *without* the usual `[bot]` suffix (its
#' underlying account is `copilot-swe-agent[bot]`). Matching on
#' `assignee_type` alone is not enough either: some agents (e.g.,
#' `cursoragent`, `openhands-agent`) are plain `"User"` accounts. This is why
#' the default detection is pattern-based; see [ai_patterns()].
#'
#' @examples
#' \dontrun{
#' # Everything delegated to an AI agent
#' gh_assignments("UofUEpiBio/epiworld", ai_only = TRUE)
#'
#' # Share of issues/PRs delegated to an agent
#' a <- gh_assignments("UofUEpiBio/epiworld")
#' mean(a$assigned_ai)
#' }
#' @family retrieval
#' @export
gh_assignments <- function(
    repo, state = c("all", "open", "closed"), since = NULL, ai_only = FALSE,
    patterns = ai_patterns(), token = gh_token(), max_pages = Inf
    ) {

  state <- match.arg(state)

  if (length(repo) > 1L)
    return(data.table::rbindlist(lapply(
      repo, gh_assignments, state = state, since = since, ai_only = ai_only,
      patterns = patterns, token = token, max_pages = max_pages
    )))

  ans <- gh_api(
    sprintf("/repos/%s/issues", repo), state = state,
    since = fmt_gh_time(since), token = token, max_pages = max_pages
  )

  out <- as_assignments_dt(ans, repo, patterns = patterns)

  if (ai_only)
    out <- out[assigned_ai == TRUE]

  out[]
}

# Parsed issue records -> one row per issue/assignee pair
as_assignments_dt <- function(ans, repo, patterns = ai_patterns()) {

  rows <- lapply(ans, function(x) {

    assignees <- x$assignees

    # Keep unassigned issues as a single NA row so that denominators work
    if (!length(assignees))
      assignees <- list(list(login = NA_character_, type = NA_character_))

    data.table::data.table(
      repo          = repo,
      type          = if (is.null(x$pull_request)) "issue" else "pull_request",
      number        = int1(x$number),
      title         = chr1(x$title),
      user          = chr1(x$user$login),
      assignee      = vapply(assignees, function(a) chr1(a$login), character(1L)),
      assignee_type = vapply(assignees, function(a) chr1(a$type), character(1L)),
      state         = chr1(x$state),
      created_at    = parse_gh_time(chr1(x$created_at)),
      closed_at     = parse_gh_time(chr1(x$closed_at))
    )

  })

  out <- data.table::rbindlist(rows)

  if (!nrow(out)) {
    out <- data.table::data.table(
      repo = character(), type = character(), number = integer(),
      title = character(), user = character(), assignee = character(),
      assignee_type = character(), state = character(),
      created_at = parse_gh_time(character()),
      closed_at = parse_gh_time(character())
    )
  }

  agent <- match_agent(out$assignee, patterns)
  data.table::set(out, j = "assigned_ai", value = !is.na(agent))
  data.table::set(out, j = "assigned_agent", value = agent)

  data.table::setcolorder(
    out,
    c("repo", "type", "number", "title", "user", "assignee", "assignee_type",
      "assigned_ai", "assigned_agent", "state", "created_at", "closed_at")
  )

  data.table::setorder(out, repo, created_at, assignee, na.last = TRUE)
  out[]
}

#' Retrieve pull requests, including their head branch
#'
#' Downloads the pull requests of one or more repositories. Unlike
#' [gh_interactions()], which sees PRs through the issues endpoint, this
#' function returns the **head branch name**, which is one of the more
#' reliable traces of AI involvement: coding agents push to prefixed branches
#' such as `copilot/fix-thing` or `codex/add-tests`, and that prefix survives
#' even when a human opens the pull request and squash-merges it.
#'
#' @param repo Character vector of repositories in `"owner/repo"` form.
#' @param state One of `"all"` (default), `"open"`, or `"closed"`.
#' @param token GitHub token (see [gh_token()]).
#' @param max_pages Number of pages (of 100 PRs each) to retrieve at most per
#' repository.
#'
#' @return A `data.table` with one row per pull request, sorted by time, and
#' columns `repo`, `number`, `title`, `user` (who opened it), `branch` (the
#' head ref), `base` (the target branch), `state`, `draft`, `created_at`,
#' `merged_at`, and `closed_at`.
#'
#' @details
#' [ai_classify()] scans a `branch` column by default, so piping the result
#' straight into it picks up the branch-prefix signal on top of the usual
#' identity and commit-trailer rules.
#'
#' @examples
#' \dontrun{
#' # Which PRs came off an agent branch, and who opened them?
#' gh_pulls("UofUEpiBio/epiworld") |>
#'   ai_classify() |>
#'   subset(ai, select = c(number, user, branch, ai_agent))
#' }
#' @family retrieval
#' @export
gh_pulls <- function(
    repo, state = c("all", "open", "closed"), token = gh_token(),
    max_pages = Inf
    ) {

  state <- match.arg(state)

  if (length(repo) > 1L)
    return(data.table::rbindlist(lapply(
      repo, gh_pulls, state = state, token = token, max_pages = max_pages
    )))

  ans <- gh_api(
    sprintf("/repos/%s/pulls", repo), state = state, token = token,
    max_pages = max_pages
  )

  as_pulls_dt(ans, repo)
}

# Parsed pull request records -> data.table
as_pulls_dt <- function(ans, repo) {

  out <- data.table::data.table(
    repo       = rep(repo, length(ans)),
    number     = vapply(ans, function(x) int1(x$number), integer(1L)),
    title      = vapply(ans, function(x) chr1(x$title), character(1L)),
    user       = vapply(ans, function(x) chr1(x$user$login), character(1L)),
    branch     = vapply(ans, function(x) chr1(x$head$ref), character(1L)),
    base       = vapply(ans, function(x) chr1(x$base$ref), character(1L)),
    state      = vapply(ans, function(x) chr1(x$state), character(1L)),
    draft      = vapply(
      ans, function(x) isTRUE(x$draft), logical(1L)
      ),
    created_at = parse_gh_time(
      vapply(ans, function(x) chr1(x$created_at), character(1L))
      ),
    merged_at  = parse_gh_time(
      vapply(ans, function(x) chr1(x$merged_at), character(1L))
      ),
    closed_at  = parse_gh_time(
      vapply(ans, function(x) chr1(x$closed_at), character(1L))
      )
  )

  data.table::setorder(out, repo, created_at)
  out[]
}
