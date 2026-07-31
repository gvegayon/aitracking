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

# Single GET request; returns the parsed JSON as a list
gh_get <- function(url, token = gh_token()) {

  con <- base::url(url, headers = gh_headers(token))
  on.exit(try(close(con), silent = TRUE), add = TRUE)

  txt <- tryCatch(
    readLines(con, warn = FALSE),
    error = function(e) stop_(
      "GitHub API request failed [", url, "]: ", conditionMessage(e),
      if (!nzchar(token))
        "\nNote: no token was found, so the request went out unauthenticated (see ?gh_token)."
      else
        ""
    )
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
