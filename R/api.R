#' Find a GitHub API token
#'
#' Looks for a GitHub personal access token (PAT) in the following order:
#' the `token` argument itself, the `GITHUB_PAT` environment variable, the
#' `GITHUB_TOKEN` environment variable, and--if the \pkg{gitcreds} package is
#' installed--the git credential store (the same one used by the \pkg{gh}
#' package and the `gh` command line client).
#'
#' All API-calling functions in \pkg{aitracking} take a `token` argument that
#' defaults to `gh_token()`, so in most setups authentication "just works":
#' either because `GITHUB_PAT`/`GITHUB_TOKEN` is set, or because a token is
#' available from the git credential store.
#'
#' Unauthenticated requests are possible but heavily rate-limited by GitHub
#' (60 requests/hour versus 5,000/hour with a token).
#'
#' @param token Optional character scalar. If non-empty, it is returned as-is.
#'
#' @return A character scalar with the token, or the empty string `""` when no
#' token was found (requests then go out unauthenticated).
#'
#' @examples
#' \dontrun{
#' gh_token() # What token would be used?
#' }
#' @family api
#' @export
gh_token <- function(token = NULL) {

  if (!is.null(token) && nzchar(token))
    return(token)

  for (ev in c("GITHUB_PAT", "GITHUB_TOKEN")) {
    val <- Sys.getenv(ev)
    if (nzchar(val))
      return(val)
  }

  if (requireNamespace("gitcreds", quietly = TRUE)) {
    cred <- tryCatch(
      gitcreds::gitcreds_get(url = "https://github.com"),
      error = function(e) NULL
    )
    if (!is.null(cred) && nzchar(cred$password))
      return(cred$password)
  }

  ""
}

# Standard headers for every request
gh_headers <- function(token) {

  headers <- c(
    Accept                 = "application/vnd.github+json",
    "X-GitHub-Api-Version" = "2022-11-28",
    "User-Agent"           = "aitracking R package (https://github.com/gvegayon/aitracking)"
  )

  if (nzchar(token))
    headers <- c(headers, Authorization = paste("Bearer", token))

  headers
}

# Turns a failed request into an actionable message. base R connections do
# not expose the response body, so the HTTP status (which `url()` reports as
# a warning) is all we have to work with; map it to the usual causes.
gh_error_message <- function(url, status, token) {

  code <- if (is.na(status)) NA_character_ else sub("^([0-9]+).*", "\\1", status)

  hint <- switch(
    code %||% "",
    "401" = paste(
      "The token was rejected. It may be expired or malformed;",
      "see ?gh_token for where tokens are looked up."
    ),
    "403" = paste(
      "Access denied. Common causes: the rate limit is exhausted (60",
      "requests/hour without a token, 5,000 with one), the token lacks the",
      "required scope, or the endpoint is gated behind an organization",
      "policy (this is what Copilot metrics endpoints return when the",
      "'Copilot usage metrics' policy is off)."
    ),
    "404" = paste(
      "Not found. Either the resource does not exist, or the token cannot",
      "see it (private repositories need a token with 'repo' scope)."
    ),
    "422" = "The request was rejected as invalid; check the parameters.",
    NULL
  )

  paste0(
    "GitHub API request failed",
    if (!is.na(status)) paste0(" [HTTP ", status, "]") else "",
    ":\n  ", url,
    if (!is.null(hint)) paste0("\n  ", hint) else "",
    if (!nzchar(token))
      "\n  No token was found, so the request went out unauthenticated (see ?gh_token)."
    else
      ""
  )
}

# Single GET request; returns the parsed JSON as a list
gh_get <- function(url, token = gh_token()) {

  con <- base::url(url, headers = gh_headers(token))
  on.exit(try(close(con), silent = TRUE), add = TRUE)

  # `url()` reports the HTTP status in a warning and then throws a generic
  # "cannot open the connection" error; catch the warning to keep the status.
  status <- NA_character_

  txt <- withCallingHandlers(
    tryCatch(
      readLines(con, warn = FALSE),
      error = function(e) stop_(gh_error_message(url, status, token))
    ),
    warning = function(w) {
      m <- regmatches(
        conditionMessage(w),
        regexpr("HTTP status was '[^']+'", conditionMessage(w))
      )
      if (length(m))
        status <<- sub("HTTP status was '([^']+)'", "\\1", m)
      invokeRestart("muffleWarning")
    }
  )

  jsonlite::fromJSON(paste(txt, collapse = "\n"), simplifyVector = FALSE)
}

#' Low-level access to the GitHub REST API
#'
#' A minimal GitHub API client built on base R connections ([url()]), used by
#' all the `gh_*` retrieval functions in this package. Array-returning
#' endpoints are paginated automatically.
#'
#' @param endpoint Character scalar. The API endpoint, e.g.,
#' `"/repos/{owner}/{repo}/commits"` (with `{owner}`/`{repo}` already filled
#' in). See <https://docs.github.com/en/rest>.
#' @param ... Named query parameters, e.g., `since = "2024-01-01T00:00:00Z"`.
#' `NULL` parameters are dropped.
#' @param token GitHub token (see [gh_token()]).
#' @param per_page Integer. Results per page (max. 100).
#' @param max_pages Number of pages to retrieve at most. Defaults to `Inf`,
#' i.e., retrieve everything.
#'
#' @return A list with the parsed JSON response. For paginated (array)
#' endpoints, the concatenated list of records across pages.
#'
#' @examples
#' \dontrun{
#' # Number of stargazers of a repository
#' gh_api("/repos/UofUEpiBio/epiworld")$stargazers_count
#' }
#' @family api
#' @export
gh_api <- function(
    endpoint, ..., token = gh_token(), per_page = 100L, max_pages = Inf
    ) {

  params <- list(...)
  params <- params[!vapply(params, is.null, logical(1L))]

  res  <- list()
  page <- 1L

  repeat {

    query <- c(params, list(per_page = per_page, page = page))
    qs    <- paste(
      names(query),
      vapply(
        query, function(v) URLencode(as.character(v)[1L], reserved = TRUE),
        character(1L)
        ),
      sep = "=", collapse = "&"
    )

    ans <- gh_get(
      paste0("https://api.github.com", endpoint, "?", qs), token = token
      )

    # Object (named) responses are not paginated: return them as-is
    if (length(names(ans)) > 0L)
      return(ans)

    res <- c(res, ans)

    if (length(ans) < per_page || page >= max_pages)
      break

    page <- page + 1L

  }

  res
}
