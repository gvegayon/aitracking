# Assignment and pull request parsers, plus the evidence tiers that depend
# on them. Fixtures are real epiworld API responses (see test_parsers.R).

fixture <- function(name) {
  path <- file.path("fixtures", name)
  if (!file.exists(path))
    path <- system.file("tinytest", "fixtures", name, package = "aitracking")
  jsonlite::fromJSON(path, simplifyVector = FALSE)
}

# Assignments --------------------------------------------------------------

as_dt <- aitracking:::as_assignments_dt(
  fixture("assignments.json"), "UofUEpiBio/epiworld"
  )

expect_true(inherits(as_dt, "data.table"))
expect_equal(
  names(as_dt),
  c("repo", "type", "number", "title", "user", "assignee", "assignee_type",
    "assigned_ai", "assigned_agent", "state", "created_at", "closed_at")
)

# Two issues with two assignees each, plus one unassigned issue kept as a
# single NA row (so shares can be computed off the same table)
expect_equal(nrow(as_dt), 5L)
expect_equal(sum(is.na(as_dt$assignee)), 1L)
expect_equal(sum(as_dt$assigned_ai), 2L)
expect_equal(unique(as_dt$assigned_agent[as_dt$assigned_ai]), "copilot")

# Copilot is a Bot but carries no "[bot]" suffix in its login
cop <- as_dt[assignee == "Copilot"]
expect_equal(unique(cop$assignee_type), "Bot")
expect_true(all(cop$assigned_ai))

# Humans are not flagged
expect_true(all(!as_dt[assignee == "gvegayon", assigned_ai]))

# Unassigned rows are never AI
expect_true(all(!as_dt[is.na(assignee), assigned_ai]))

# The generic "[bot]" pattern alone would miss Copilot; the copilot pattern
# is what catches it
only_bot <- aitracking:::as_assignments_dt(
  fixture("assignments.json"), "a/b",
  patterns = c(bot = "\\[bot\\]")
)
expect_equal(sum(only_bot$assigned_ai), 0L)

# Empty input still yields a well-formed, zero-row table
empty <- aitracking:::as_assignments_dt(list(), "a/b")
expect_equal(nrow(empty), 0L)
expect_true(all(c("assigned_ai", "assignee_type") %in% names(empty)))

# Pull requests ------------------------------------------------------------

pl <- aitracking:::as_pulls_dt(fixture("pulls.json"), "UofUEpiBio/epiworld")

expect_equal(nrow(pl), 3L)
expect_true(all(c("branch", "base", "merged_at", "draft") %in% names(pl)))
expect_true(is.logical(pl$draft))
expect_true(inherits(pl$created_at, "POSIXct"))
expect_true(any(grepl("^copilot/", pl$branch)))
expect_true(any(grepl("^codex/", pl$branch)))

# Evidence tiers -----------------------------------------------------------

cl <- ai_classify(pl)

expect_true(all(
  c("ai", "ai_suspected", "ai_agent", "ai_evidence") %in% names(cl)
))

# The copilot/* PR was opened by the Copilot bot -> confirmed via identity
cop_pr <- cl[grepl("^copilot/", branch)]
expect_true(all(cop_pr$ai))
expect_false(any(cop_pr$ai_suspected))
expect_equal(unique(cop_pr$ai_evidence), "identity")

# The codex/* PR was opened by a human -> suspected via branch prefix only
cdx <- cl[grepl("^codex/", branch)]
expect_false(any(cdx$ai))
expect_true(all(cdx$ai_suspected))
expect_equal(unique(cdx$ai_evidence), "branch")
expect_equal(unique(cdx$user), "gvegayon")

# A plain human branch is neither
hum <- cl[grepl("^gvegayon/", branch)]
expect_false(any(hum$ai))
expect_false(any(hum$ai_suspected))
expect_true(all(is.na(hum$ai_evidence)))

# Confirmed and suspected are mutually exclusive
expect_true(all(!(cl$ai & cl$ai_suspected)))

# Dropping the branch column removes the suspected tier entirely
no_branch <- ai_classify(pl, branch_cols = character())
expect_false(any(no_branch$ai_suspected))

# Identity evidence wins over branch evidence for the same row
both <- ai_classify(data.frame(user = "Copilot", branch = "codex/thing"))
expect_equal(both$ai_evidence, "identity")
expect_true(both$ai)
expect_false(both$ai_suspected)

# Copilot seats ------------------------------------------------------------

st <- aitracking:::as_seats_dt(fixture("seats.json")$seats, "my-org")

expect_equal(nrow(st), 2L)
expect_equal(st$user, c("octocat", "hubot"))
expect_true(inherits(st$last_activity_at, "POSIXct"))
expect_true(is.na(st$last_activity_at[2L])) # never active
expect_equal(unique(st$plan_type), "business")

expect_equal(nrow(aitracking:::as_seats_dt(list(), "my-org")), 0L)

# gh_copilot_metrics argument checking (no network needed) -----------------

expect_error(
  gh_copilot_metrics("my-org", report = "repos-1-day"),
  pattern = "needs a `day`"
)
