# Offline tests of the JSON -> data.table parsers, run against real API
# responses stored in fixtures/ (trimmed to the fields the parsers read).
# These cover the retrieval code paths without needing network or a token.

fixture <- function(name) {
  path <- file.path("fixtures", name)
  if (!file.exists(path))
    path <- system.file("tinytest", "fixtures", name, package = "aitracking")
  jsonlite::fromJSON(path, simplifyVector = FALSE)
}

# Commits ------------------------------------------------------------------

cm <- aitracking:::as_commits_dt(fixture("commits.json"), "UofUEpiBio/epiworld")

expect_true(inherits(cm, "data.table"))
expect_equal(nrow(cm), 2L)
expect_equal(
  names(cm),
  c("repo", "sha", "author", "author_name", "author_email", "committer",
    "date", "message")
)
expect_true(inherits(cm$date, "POSIXct"))
expect_equal(unique(cm$repo), "UofUEpiBio/epiworld")
expect_true(all(nchar(cm$sha) == 40L))
expect_false(anyNA(cm$author_name))

# Sorted oldest to newest
expect_equal(cm$date, sort(cm$date))

# A commit whose author is not linked to a GitHub account yields NA, not an
# error or a zero-length column
anon <- fixture("commits.json")
anon[[1L]]$author <- NULL
anon_dt <- aitracking:::as_commits_dt(anon, "a/b")
expect_true(is.na(anon_dt[sha == fixture("commits.json")[[1L]]$sha, author]))

# Empty responses give a zero-row table with the right columns
empty <- aitracking:::as_commits_dt(list(), "a/b")
expect_equal(nrow(empty), 0L)
expect_true("sha" %in% names(empty))

# Commit file detail -------------------------------------------------------

detail <- fixture("commit_detail.json")

expect_equal(aitracking:::int1(detail$stats$additions), 1043L)
expect_equal(aitracking:::int1(detail$stats$deletions), 264L)

fl <- aitracking:::as_commit_files_dt(detail, "UofUEpiBio/epiworld", "07e6239")
expect_true(inherits(fl, "data.table"))
expect_equal(nrow(fl), 3L)
expect_equal(
  names(fl), c("repo", "sha", "file", "status", "additions", "deletions")
)
expect_true(is.integer(fl$additions))

# Commits with no file list (e.g., very large merges) give NULL
expect_null(
  aitracking:::as_commit_files_dt(list(stats = list()), "a/b", "abc")
)

# Issues, PRs and comments -------------------------------------------------

iss <- aitracking:::as_issues_dt(fixture("issues.json"), "UofUEpiBio/epiworld")

expect_equal(nrow(iss), 3L)
expect_true(all(iss$type %in% c("issue", "pull_request")))
# The fixture holds two PRs and one plain issue
expect_equal(sum(iss$type == "pull_request"), 2L)
expect_equal(sum(iss$type == "issue"), 1L)
expect_true(is.integer(iss$number))
expect_true(inherits(iss$created_at, "POSIXct"))

ic <- aitracking:::as_comments_dt(
  fixture("issue_comments.json"), "UofUEpiBio/epiworld",
  "issue_comment", "issue_url"
)
expect_equal(nrow(ic), 2L)
expect_equal(unique(ic$type), "issue_comment")
expect_true(all(is.na(ic$title)))
expect_true(all(ic$number > 0L)) # parsed out of the issue URL

rc <- aitracking:::as_comments_dt(
  fixture("review_comments.json"), "UofUEpiBio/epiworld",
  "review_comment", "pull_request_url"
)
expect_equal(unique(rc$type), "review_comment")
expect_true(all(rc$number > 0L))

# The three tables stack, which is what gh_interactions() relies on
expect_equal(ncol(rbind(iss, ic, rc)), ncol(iss))

# Traffic and downloads ----------------------------------------------------

tr <- aitracking:::as_traffic_dt(
  fixture("clones.json")$clones, "UofUEpiBio/epiworld"
  )
expect_equal(nrow(tr), 3L)
expect_equal(names(tr), c("repo", "date", "count", "uniques"))
expect_true(inherits(tr$date, "POSIXct"))
expect_true(all(tr$count >= tr$uniques))

dl <- aitracking:::as_downloads_dt(fixture("releases.json"), "quarto-dev/quarto-cli")
expect_true(inherits(dl, "data.table"))
# Only the release carrying assets contributes rows
expect_equal(nrow(dl), 2L)
expect_equal(unique(dl$release), "v1.11.1")
expect_true(is.integer(dl$downloads))
expect_true(inherits(dl$published_at, "POSIXct"))

# Languages ----------------------------------------------------------------

lg <- aitracking:::as_languages_dt(fixture("languages.json"), "UofUEpiBio/epiworld")

expect_equal(names(lg), c("repo", "language", "bytes", "share"))
expect_equal(sum(lg$share), 1, tolerance = 1e-10)
expect_equal(lg$language[1L], "C++")     # sorted by bytes, descending
expect_true(all(diff(lg$bytes) <= 0))

# End-to-end: parsers feed the analysis functions --------------------------

tagged <- ai_classify(cm)
expect_true(all(c("ai", "ai_agent", "ai_mention") %in% names(tagged)))

# File-level detail carries no date of its own; gh_commit_lines() joins it in
# from the commit table before loc_evolution() can use it.
fl_dated <- aitracking:::as_commit_files_dt(
  detail, "UofUEpiBio/epiworld", "07e6239"
)
expect_error(loc_evolution(fl_dated), pattern = "date")

fl_dated[, date := cm$date[1L]]
lo <- loc_evolution(fl_dated)
expect_true("language" %in% names(lo))
# All three files in this commit are C++ headers
expect_equal(unique(lo$language), "C++")
expect_equal(lo$delta, sum(fl_dated$additions) - sum(fl_dated$deletions))
