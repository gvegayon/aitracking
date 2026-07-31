# plot_timeline: runs silently and returns its input invisibly --------------

set.seed(88)
n  <- 50L
cm <- data.frame(
  repo      = "owner/repo",
  date      = as.POSIXct("2023-06-01", tz = "UTC") +
    cumsum(sample(86400 * (1:5), n, replace = TRUE)),
  additions = rpois(n, 50L),
  deletions = rpois(n, 20L),
  ai        = sample(c(TRUE, FALSE), n, replace = TRUE)
)

pdf(NULL)

out <- plot_timeline(cm, by = "commits")
expect_identical(out, cm)

out <- plot_timeline(cm, by = "lines", interval = "week")
expect_identical(out, cm)

# Daily bins on a short window
out <- plot_timeline(cm[1:5, ], by = "commits", interval = "day")
expect_identical(out, cm[1:5, ])

# Without the ai column
out <- plot_timeline(cm[, setdiff(names(cm), "ai")], by = "commits")
expect_true(is.data.frame(out))

# Custom date_col/ai_col, e.g. gh_assignments()'s column names
renamed <- cm
names(renamed)[names(renamed) == "date"] <- "created_at"
names(renamed)[names(renamed) == "ai"]   <- "assigned_ai"
out <- plot_timeline(
  renamed, by = "commits", date_col = "created_at", ai_col = "assigned_ai"
)
expect_identical(out, renamed)

# A suspected_col that isn't present is treated as "no suspected tier",
# not an error
out <- plot_timeline(
  renamed, by = "commits", date_col = "created_at", ai_col = "assigned_ai",
  suspected_col = "does_not_exist"
)
expect_identical(out, renamed)

dev.off()

# Errors are informative
expect_error(plot_timeline(data.frame(x = 1)), pattern = "date")
expect_error(
  plot_timeline(cm[, c("repo", "date")], by = "lines"),
  pattern = "additions"
)
expect_error(
  plot_timeline(cm, date_col = "nope"), pattern = "nope"
)
