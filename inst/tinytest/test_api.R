# gh_token lookup order ----------------------------------------------------

old <- Sys.getenv(c("GITHUB_PAT", "GITHUB_TOKEN"), unset = NA)

Sys.setenv(GITHUB_PAT = "aaa", GITHUB_TOKEN = "bbb")
expect_equal(gh_token(), "aaa")

Sys.unsetenv("GITHUB_PAT")
expect_equal(gh_token(), "bbb")

# An explicit token always wins
expect_equal(gh_token("ccc"), "ccc")

# Restore the environment
for (ev in names(old)) {
  if (is.na(old[ev])) Sys.unsetenv(ev) else do.call(Sys.setenv, as.list(old[ev]))
}

# Internal helpers ----------------------------------------------------------

expect_equal(
  aitracking:::fmt_gh_time("2024-01-02"),
  "2024-01-02T00:00:00Z"
)
expect_equal(
  aitracking:::fmt_gh_time(as.Date("2024-01-02")),
  "2024-01-02T00:00:00Z"
)
expect_null(aitracking:::fmt_gh_time(NULL))

tm <- aitracking:::parse_gh_time("2024-01-02T03:04:05Z")
expect_true(inherits(tm, "POSIXct"))
expect_equal(format(tm, "%Y-%m-%d %H:%M:%S", tz = "UTC"), "2024-01-02 03:04:05")

expect_equal(
  aitracking:::int_from_url("https://api.github.com/repos/a/b/issues/42"),
  42L
)

# Network tests (only run locally, with a token available) ------------------

if (at_home() && nzchar(gh_token())) {

  cm <- gh_commits("UofUEpiBio/epiworld", max_pages = 1L)
  expect_true(inherits(cm, "data.table"))
  expect_true(nrow(cm) > 0L)
  expect_true(all(c("repo", "sha", "author", "date", "message") %in% names(cm)))
  expect_true(inherits(cm$date, "POSIXct"))

  # Piping into gh_commit_lines
  cl <- gh_commit_lines(utils::head(cm, 2L), verbose = FALSE)
  expect_true(all(c("additions", "deletions") %in% names(cl)))
  expect_equal(nrow(cl), 2L)

  # Languages
  lang <- gh_languages("UofUEpiBio/epiworld")
  expect_true("C++" %in% lang$language)
  expect_equal(sum(lang$share), 1, tolerance = 1e-8)

}
