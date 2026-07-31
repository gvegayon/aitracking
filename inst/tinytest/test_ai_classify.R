# ai_classify: identity, trailer, and mention detection --------------------

commits <- data.frame(
  repo         = "owner/repo",
  sha          = as.character(1:5),
  author       = c("gvegayon", "copilot[bot]", "octocat", "jdoe", "app/cool"),
  author_email = c(
    "g@example.org", "copilot@github.com", "octo@example.org",
    "j@example.org", "cool@example.org"
  ),
  message      = c(
    "Plain human commit",
    "Bug fix",
    "Refactor\n\nCo-authored-by: Claude <noreply@anthropic.com>",
    "Could @claude take a look at this?",
    "Mentions copilot in passing, which should NOT be flagged"
  ),
  date         = as.POSIXct("2024-01-01", tz = "UTC") + 1:5
)

out <- ai_classify(commits)

expect_true(inherits(out, "data.table"))
expect_equal(out$ai, c(FALSE, TRUE, TRUE, FALSE, FALSE))
expect_equal(out$ai_agent, c(NA, "copilot", "claude", NA, NA))
expect_equal(out$ai_mention, c(NA, NA, NA, "claude", NA))

# Evidence is recorded, and nothing here is merely "suspected"
expect_equal(out$ai_evidence, c(NA, "identity", "trailer", NA, NA))
expect_true(all(!out$ai_suspected))

# "Assisted-by:" is recognized alongside "Co-authored-by:" and
# "Generated with", since projects are adopting it to mark AI assistance
# without implying co-authorship
trailers <- data.frame(message = c(
  "Fix\n\nAssisted-by: Claude <noreply@anthropic.com>",
  "Fix\n\nGenerated with Copilot",
  "Fix\n\nreviewed-by: a human"
))
expect_equal(ai_classify(trailers)$ai, c(TRUE, TRUE, FALSE))
expect_equal(ai_classify(trailers)$ai_evidence[1:2], c("trailer", "trailer"))

# The input must not be modified in place
expect_false("ai" %in% names(commits))

dt_in <- data.table::as.data.table(commits)
invisible(ai_classify(dt_in))
expect_false("ai" %in% names(dt_in))

# Custom patterns
out2 <- ai_classify(commits, patterns = c(myagent = "octocat"))
expect_equal(out2$ai_agent, c(NA, NA, "myagent", NA, NA))

# ai_patterns returns a named character vector
pats <- ai_patterns()
expect_true(is.character(pats))
expect_true(length(names(pats)) == length(pats))

# Generic bot accounts are labeled 'bot' (and can be dropped)
bots <- data.frame(user = c("dependabot[bot]", "jdoe"), body = c("x", "y"))
out3 <- ai_classify(bots)
expect_equal(out3$ai_agent, c("bot", NA))
out4 <- ai_classify(bots, patterns = ai_patterns()[names(ai_patterns()) != "bot"])
expect_equal(out4$ai, c(FALSE, FALSE))
