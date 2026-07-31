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

#' Issue and pull request assignments of UofUEpiBio/epiworld
#'
#' Issues and pull requests of the
#' [epiworld](https://github.com/UofUEpiBio/epiworld) repository together with
#' the accounts they are assigned to, including the ones delegated to the
#' Copilot coding agent. Snapshot taken on 2026-07-31 with
#' `gh_assignments("UofUEpiBio/epiworld")` (see `data-raw/epiworld.R` in the
#' package sources).
#'
#' @format A `data.table` with one row per issue/assignee pair and columns
#' `repo`, `type`, `number`, `title`, `user`, `assignee`, `assignee_type`,
#' `assigned_ai`, `assigned_agent`, `state`, `created_at`, and `closed_at`.
#' See [gh_assignments()] for details.
#'
#' @source GitHub REST API, <https://github.com/UofUEpiBio/epiworld>.
#' @family data
"epiworld_assignments"

#' Pull requests of UofUEpiBio/epiworld
#'
#' Pull requests of the
#' [epiworld](https://github.com/UofUEpiBio/epiworld) repository, including
#' the head branch name, which carries the agent branch prefixes
#' (`copilot/`, `codex/`) used by [ai_classify()] as suspected-involvement
#' evidence. Snapshot taken on 2026-07-31 with
#' `gh_pulls("UofUEpiBio/epiworld")` (see `data-raw/epiworld.R` in the package
#' sources).
#'
#' @format A `data.table` with one row per pull request and columns `repo`,
#' `number`, `title`, `user`, `branch`, `base`, `state`, `draft`,
#' `created_at`, `merged_at`, and `closed_at`. See [gh_pulls()] for details.
#'
#' @source GitHub REST API, <https://github.com/UofUEpiBio/epiworld>.
#' @family data
"epiworld_pulls"
