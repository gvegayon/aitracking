#' Retrieve the language composition of a repository
#'
#' Downloads the current number of bytes of code per language, as computed by
#' GitHub (linguist).
#'
#' @param repo Character vector of repositories in `"owner/repo"` form.
#' @param token GitHub token (see [gh_token()]).
#'
#' @return A `data.table` with columns `repo`, `language`, `bytes`, and
#' `share` (proportion of bytes within the repository).
#'
#' @details
#' This is a *current* snapshot. For the evolution of project size over time,
#' see [loc_evolution()].
#'
#' @examples
#' \dontrun{
#' gh_languages("UofUEpiBio/epiworld")
#' }
#' @family retrieval
#' @export
gh_languages <- function(repo, token = gh_token()) {

  if (length(repo) > 1L)
    return(data.table::rbindlist(lapply(repo, gh_languages, token = token)))

  as_languages_dt(gh_api(sprintf("/repos/%s/languages", repo), token = token), repo)
}

# Parsed languages response -> data.table
as_languages_dt <- function(ans, repo) {

  out <- data.table::data.table(
    repo     = rep(repo, length(ans)),
    language = as.character(names(ans)),
    bytes    = as.numeric(unlist(ans, use.names = FALSE))
  )

  out[, share := bytes / sum(bytes), by = repo]
  data.table::setorder(out, repo, -bytes)
  out[]
}

# File extension -> language (approximate; used by loc_evolution)
.ext_map <- c(
  r = "R", rmd = "R Markdown", rnw = "R", qmd = "Quarto", md = "Markdown",
  c = "C", h = "C/C++", cpp = "C++", cc = "C++", cxx = "C++", hpp = "C++",
  hh = "C++", ipp = "C++", cu = "CUDA",
  py = "Python", jl = "Julia", js = "JavaScript", jsx = "JavaScript",
  ts = "TypeScript", tsx = "TypeScript", java = "Java", kt = "Kotlin",
  go = "Go", rs = "Rust", rb = "Ruby", pl = "Perl", php = "PHP",
  f = "Fortran", f90 = "Fortran", f95 = "Fortran",
  sh = "Shell", bash = "Shell", zsh = "Shell", ps1 = "PowerShell",
  html = "HTML", htm = "HTML", css = "CSS", scss = "CSS",
  yml = "YAML", yaml = "YAML", json = "JSON", toml = "TOML", xml = "XML",
  tex = "TeX", bib = "TeX", sql = "SQL", cmake = "CMake", mk = "Makefile",
  ipynb = "Jupyter", svg = "SVG", csv = "Data", tsv = "Data", rda = "Data",
  rds = "Data", dcf = "Metadata"
)

# Vectorized mapping of file paths to languages
ext_language <- function(path) {

  base <- tolower(basename(path))
  ext  <- sub(".*\\.", "", base)

  out <- unname(.ext_map[ext])
  out[base %in% c("makefile", "gnumakefile")] <- "Makefile"
  out[base == "cmakelists.txt"]               <- "CMake"
  out[base %in% c("description", "namespace")] <- "Metadata"
  out[is.na(out)] <- "Other"
  out
}

#' Evolution of project size (lines of code) over time
#'
#' Computes the cumulative net lines of code (additions minus deletions) of a
#' project over time from its commit history. With file-level input (from
#' `gh_commit_lines(x, files = TRUE)`), the evolution is broken down by
#' language, mapped from file extensions.
#'
#' @param x A `data.frame`/`data.table` with columns `date`, `additions`, and
#' `deletions`--i.e., the output of [gh_commit_lines()]. If a `file` column is
#' present (from `gh_commit_lines(files = TRUE)`), the result is computed by
#' language.
#'
#' @return A `data.table` with columns `repo`, `date`, `delta` (net lines
#' changed at that time), and `loc` (cumulative net lines), plus `language`
#' when `x` has file-level detail. Sorted by time within `repo` (and
#' `language`).
#'
#' @details
#' The measure is approximate: it counts net *lines changed* as reported by
#' GitHub, which includes documentation, data, and other non-code files
#' (unless you filter them out beforehand). Commits with missing statistics
#' contribute zero.
#'
#' @examples
#' \dontrun{
#' gh_commits("UofUEpiBio/epiworld") |>
#'   gh_commit_lines(files = TRUE) |>
#'   loc_evolution()
#' }
#' @family analysis
#' @export
loc_evolution <- function(x) {

  x <- data.table::as.data.table(x)

  if (!all(c("date", "additions", "deletions") %in% names(x)))
    stop_(
      "`x` must have columns 'date', 'additions', and 'deletions' ",
      "(see ?gh_commit_lines)."
    )

  tmp <- data.table::data.table(
    repo  = if ("repo" %in% names(x)) x[["repo"]] else rep("", nrow(x)),
    date  = x[["date"]],
    delta = data.table::fcoalesce(as.numeric(x[["additions"]]), 0) -
      data.table::fcoalesce(as.numeric(x[["deletions"]]), 0)
  )

  if ("file" %in% names(x)) {

    tmp[, language := ext_language(x[["file"]])]
    tmp <- tmp[, list(delta = sum(delta)), by = list(repo, language, date)]
    data.table::setorder(tmp, repo, language, date)
    tmp[, loc := cumsum(delta), by = list(repo, language)]

  } else {

    tmp <- tmp[, list(delta = sum(delta)), by = list(repo, date)]
    data.table::setorder(tmp, repo, date)
    tmp[, loc := cumsum(delta), by = repo]

  }

  tmp[]
}
