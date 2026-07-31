# loc_evolution: commit-level and file-level inputs ------------------------

cm <- data.frame(
  repo      = "owner/repo",
  sha       = as.character(1:3),
  date      = as.POSIXct("2024-01-01", tz = "UTC") + (1:3) * 86400,
  additions = c(10L, 5L, 0L),
  deletions = c(0L, 2L, 3L)
)

lo <- loc_evolution(cm)
expect_true(inherits(lo, "data.table"))
expect_equal(lo$loc, c(10, 13, 10))
expect_equal(lo$delta, c(10, 3, -3))

# Missing stats count as zero
cm_na <- cm
cm_na$additions[2] <- NA_integer_
expect_equal(loc_evolution(cm_na)$loc, c(10, 8, 5))

# File-level input: evolution by language
fl <- data.frame(
  repo      = "owner/repo",
  sha       = c("1", "1", "2"),
  date      = as.POSIXct("2024-01-01", tz = "UTC") + c(1, 1, 2) * 86400,
  file      = c("R/a.R", "src/b.cpp", "R/a.R"),
  additions = c(10L, 20L, 5L),
  deletions = c(0L, 0L, 10L)
)

lo2 <- loc_evolution(fl)
expect_true("language" %in% names(lo2))
expect_equal(lo2[lo2$language == "R", ]$loc, c(10, 5))
expect_equal(lo2[lo2$language == "C++", ]$loc, 20)

# Errors on missing columns
expect_error(loc_evolution(data.frame(a = 1)), pattern = "additions")

# Extension-to-language mapping
expect_equal(
  aitracking:::ext_language(
    c("R/x.R", "include/epiworld.hpp", "Makefile", "README", "a/b.py")
  ),
  c("R", "C++", "Makefile", "Other", "Python")
)
