#' Retrieve the commit history of one or more repositories
#'
#' Downloads the commit history of one or more GitHub repositories as a
#' [data.table::data.table]. By default the entire history is retrieved; use
#' `since`/`until` (or `max_pages`) to subset it.
#'
#' @param repo Character vector of repositories in `"owner/repo"` form, e.g.,
#' `"UofUEpiBio/epiworld"`. When more than one repository is passed, the
#' results are stacked (the `repo` column identifies each one).
#' @param since,until Optional lower/upper bounds for the commit time. Can be
#' `Date`, `POSIXct`, or character (`"YYYY-MM-DD"` or full ISO 8601).
#' @param path Optional character scalar. Only commits touching this file path
#' are returned.
#' @param token GitHub token (see [gh_token()]).
#' @param max_pages Number of pages (of 100 commits each) to retrieve at most
#' per repository. Defaults to `Inf` (the full history).
#'
#' @return A `data.table` with one row per commit, sorted from oldest to
#' newest, and columns:
#' - `repo`: the repository (`"owner/repo"`).
#' - `sha`: commit hash.
#' - `author`: GitHub login of the author (`NA` if not linked to an account).
#' - `author_name`, `author_email`: name/email recorded in the commit.
#' - `committer`: name of the committer (e.g., `"GitHub"` for squash merges
#'   done through the web interface).
#' - `date`: author timestamp as `POSIXct` (UTC).
#' - `message`: full commit message.
#'
#' @details
#' Line counts are not part of GitHub's commit-list endpoint; pipe the result
#' into [gh_commit_lines()] to add them.
#'
#' @examples
#' \dontrun{
#' commits <- gh_commits("UofUEpiBio/epiworld", since = "2024-01-01")
#'
#' # Piping into the classifier and the plotting function
#' gh_commits("UofUEpiBio/epiworld") |>
#'   ai_classify() |>
#'   plot_timeline()
#' }
#' @family retrieval
#' @export
gh_commits <- function(
    repo, since = NULL, until = NULL, path = NULL, token = gh_token(),
    max_pages = Inf
    ) {

  if (length(repo) > 1L)
    return(data.table::rbindlist(lapply(
      repo, gh_commits,
      since = since, until = until, path = path, token = token,
      max_pages = max_pages
    )))

  ans <- gh_api(
    sprintf("/repos/%s/commits", repo),
    since = fmt_gh_time(since), until = fmt_gh_time(until), path = path,
    token = token, max_pages = max_pages
  )

  as_commits_dt(ans, repo)
}

# Parsed commit records -> data.table (kept separate so it can be tested
# offline against the fixtures in inst/tinytest/fixtures)
as_commits_dt <- function(ans, repo) {

  out <- data.table::data.table(
    repo         = rep(repo, length(ans)),
    sha          = vapply(ans, function(x) chr1(x$sha), character(1L)),
    author       = vapply(ans, function(x) chr1(x$author$login), character(1L)),
    author_name  = vapply(ans, function(x) chr1(x$commit$author$name), character(1L)),
    author_email = vapply(ans, function(x) chr1(x$commit$author$email), character(1L)),
    committer    = vapply(ans, function(x) chr1(x$commit$committer$name), character(1L)),
    date         = parse_gh_time(
      vapply(ans, function(x) chr1(x$commit$author$date), character(1L))
      ),
    message      = vapply(ans, function(x) chr1(x$commit$message), character(1L))
  )

  data.table::setorder(out, repo, date)
  out[]
}

#' Retrieve lines added/deleted per commit
#'
#' Adds per-commit line counts (`additions`, `deletions`) to a commit history,
#' or--with `files = TRUE`--returns the file-level detail of each commit.
#' Designed to be piped from [gh_commits()].
#'
#' @param x Either a `data.frame`/`data.table` with columns `repo` and `sha`
#' (as returned by [gh_commits()]), or a character vector of repositories, in
#' which case [gh_commits()] is called first.
#' @param files Logical scalar. When `TRUE`, returns one row per file changed
#' per commit instead of one row per commit.
#' @param token GitHub token (see [gh_token()]).
#' @param verbose Logical scalar. Print a progress bar? (One API call is made
#' per commit, so this can take a while for long histories.)
#'
#' @return When `files = FALSE` (the default), a copy of `x` as a `data.table`
#' with two new integer columns, `additions` and `deletions`. When
#' `files = TRUE`, a `data.table` with columns `repo`, `sha`, `date` (if
#' available in `x`), `file`, `status`, `additions`, and `deletions`.
#'
#' @details
#' GitHub's commit-list endpoint does not include line counts, so this
#' function requests each commit individually (`/repos/{repo}/commits/{sha}`),
#' i.e., one API call per commit. With an authenticated token the rate limit
#' is 5,000 calls/hour. For very large projects, consider subsetting the
#' commit history first.
#'
#' @examples
#' \dontrun{
#' commits <- gh_commits("UofUEpiBio/epiworld") |>
#'   gh_commit_lines()
#'
#' # File-level detail, useful for loc_evolution(<...>) by language
#' files <- gh_commits("UofUEpiBio/epiworld") |>
#'   gh_commit_lines(files = TRUE)
#' }
#' @family retrieval
#' @export
gh_commit_lines <- function(
    x, files = FALSE, token = gh_token(), verbose = interactive()
    ) {

  if (is.character(x))
    x <- gh_commits(x, token = token)

  x <- data.table::as.data.table(x)

  if (!all(c("repo", "sha") %in% names(x)))
    stop_("`x` must have columns 'repo' and 'sha' (see ?gh_commits).")

  n         <- nrow(x)
  additions <- rep(NA_integer_, n)
  deletions <- rep(NA_integer_, n)
  fdetail   <- if (files) vector("list", n) else NULL

  pb <- if (verbose && n > 1L)
    txtProgressBar(min = 0L, max = n, style = 3L)
  else
    NULL

  for (i in seq_len(n)) {

    ans <- gh_api(
      sprintf("/repos/%s/commits/%s", x$repo[i], x$sha[i]), token = token
      )

    additions[i] <- int1(ans$stats$additions)
    deletions[i] <- int1(ans$stats$deletions)

    if (files)
      fdetail[[i]] <- as_commit_files_dt(ans, x$repo[i], x$sha[i])

    if (!is.null(pb))
      setTxtProgressBar(pb, i)

  }

  if (!is.null(pb))
    close(pb)

  if (files) {

    out <- data.table::rbindlist(fdetail)

    if ("date" %in% names(x) && nrow(out))
      out[x, on = c("repo", "sha"), date := i.date]

    return(out[])

  }

  out <- data.table::copy(x)
  data.table::set(out, j = "additions", value = additions)
  data.table::set(out, j = "deletions", value = deletions)
  out[]
}

# File-level detail of a single parsed commit response -> data.table
as_commit_files_dt <- function(ans, repo, sha) {

  if (!length(ans$files))
    return(NULL)

  data.table::data.table(
    repo      = repo,
    sha       = sha,
    file      = vapply(ans$files, function(f) chr1(f$filename), character(1L)),
    status    = vapply(ans$files, function(f) chr1(f$status), character(1L)),
    additions = vapply(ans$files, function(f) int1(f$additions), integer(1L)),
    deletions = vapply(ans$files, function(f) int1(f$deletions), integer(1L))
  )
}
