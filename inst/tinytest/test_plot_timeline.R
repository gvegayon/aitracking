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

# Without the ai column
out <- plot_timeline(cm[, setdiff(names(cm), "ai")], by = "commits")
expect_true(is.data.frame(out))

dev.off()

# Errors are informative
expect_error(plot_timeline(data.frame(x = 1)), pattern = "date")
expect_error(
  plot_timeline(cm[, c("repo", "date")], by = "lines"),
  pattern = "additions"
)
