#' Commit history of the UofUEpiBio/epiworld C++ library
#'
#' Full commit history of the
#' [epiworld](https://github.com/UofUEpiBio/epiworld) C++ header-only library
#' for agent-based epidemiological simulations, including per-commit line
#' counts. Snapshot taken on 2026-07-31 with
#' `gh_commits("UofUEpiBio/epiworld") |> gh_commit_lines()` (see
#' `data-raw/epiworld.R` in the package sources).
#'
#' @format A `data.table` with one row per commit and columns `repo`, `sha`,
#' `author`, `author_name`, `author_email`, `committer`, `date`, `message`,
#' `additions`, and `deletions`. See [gh_commits()] and [gh_commit_lines()]
#' for details.
#'
#' @source GitHub REST API, <https://github.com/UofUEpiBio/epiworld>.
#' @family data
"epiworld_commits"

#' Issue and pull request interactions of UofUEpiBio/epiworld
#'
#' Issues, pull requests, and comments of the
#' [epiworld](https://github.com/UofUEpiBio/epiworld) repository. Snapshot
#' taken on 2026-07-31 with `gh_interactions("UofUEpiBio/epiworld")` (see
#' `data-raw/epiworld.R` in the package sources).
#'
#' @format A `data.table` with one row per interaction and columns `repo`,
#' `type`, `number`, `user`, `created_at`, `title`, and `body`. See
#' [gh_interactions()] for details.
#'
#' @source GitHub REST API, <https://github.com/UofUEpiBio/epiworld>.
#' @family data
"epiworld_interactions"
