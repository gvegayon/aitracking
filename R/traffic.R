#' Retrieve repository traffic (clones or views)
#'
#' Downloads the clone or view history of one or more repositories from
#' GitHub's traffic API.
#'
#' @param repo Character vector of repositories in `"owner/repo"` form.
#' @param metric Either `"clones"` (default) or `"views"`.
#' @param per Either `"day"` (default) or `"week"`.
#' @param token GitHub token (see [gh_token()]). Note that the traffic API
#' requires **push access** to the repository.
#'
#' @return A `data.table` with columns `repo`, `date` (`POSIXct`, UTC),
#' `count`, and `uniques`.
#'
#' @details
#' GitHub only stores traffic data for the last 14 days, so building a longer
#' clone history requires periodic snapshots (e.g., a scheduled GitHub Action
#' that appends the output of this function to a file).
#'
#' For download counts of release assets--which GitHub does keep
#' indefinitely--see [gh_downloads()].
#'
#' @examples
#' \dontrun{
#' gh_traffic("UofUEpiBio/epiworld") # clones, last 14 days
#' gh_traffic("UofUEpiBio/epiworld", metric = "views", per = "week")
#' }
#' @family retrieval
#' @export
gh_traffic <- function(
    repo, metric = c("clones", "views"), per = c("day", "week"),
    token = gh_token()
    ) {

  metric <- match.arg(metric)
  per    <- match.arg(per)

  if (length(repo) > 1L)
    return(data.table::rbindlist(lapply(
      repo, gh_traffic, metric = metric, per = per, token = token
    )))

  ans     <- gh_api(
    sprintf("/repos/%s/traffic/%s", repo, metric), per = per, token = token
    )
  entries <- ans[[metric]]

  data.table::data.table(
    repo    = rep(repo, length(entries)),
    date    = parse_gh_time(
      vapply(entries, function(e) chr1(e$timestamp), character(1L))
      ),
    count   = vapply(entries, function(e) int1(e$count), integer(1L)),
    uniques = vapply(entries, function(e) int1(e$uniques), integer(1L))
  )
}

#' Retrieve download counts of release assets
#'
#' Downloads the list of release assets of one or more repositories together
#' with their all-time download counts.
#'
#' @param repo Character vector of repositories in `"owner/repo"` form.
#' @param token GitHub token (see [gh_token()]).
#' @param max_pages Number of pages (of 100 releases each) to retrieve at
#' most per repository.
#'
#' @return A `data.table` with columns `repo`, `release` (the tag name),
#' `published_at` (`POSIXct`, UTC), `asset` (file name), and `downloads`
#' (all-time download count). Repositories without release assets contribute
#' no rows.
#'
#' @examples
#' \dontrun{
#' gh_downloads("quarto-dev/quarto-cli")
#' }
#' @family retrieval
#' @export
gh_downloads <- function(repo, token = gh_token(), max_pages = Inf) {

  if (length(repo) > 1L)
    return(data.table::rbindlist(lapply(
      repo, gh_downloads, token = token, max_pages = max_pages
    )))

  releases <- gh_api(
    sprintf("/repos/%s/releases", repo), token = token, max_pages = max_pages
    )

  out <- lapply(releases, function(r) {

    if (!length(r$assets))
      return(NULL)

    data.table::data.table(
      repo         = repo,
      release      = chr1(r$tag_name),
      published_at = parse_gh_time(chr1(r$published_at)),
      asset        = vapply(r$assets, function(a) chr1(a$name), character(1L)),
      downloads    = vapply(
        r$assets, function(a) int1(a$download_count), integer(1L)
        )
    )

  })

  data.table::rbindlist(out)
}
