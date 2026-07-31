#' Plot a timeline of project activity
#'
#' Visualizes the activity of a project over time in one of two ways: number
#' of commits (`by = "commits"`) or lines added/deleted (`by = "lines"`).
#' When the input has been through [ai_classify()], commit bars are split into
#' human and AI contributions.
#'
#' @param x A `data.frame`/`data.table` with a `date` column (`POSIXct`),
#' typically the output of [gh_commits()], [gh_commit_lines()], or
#' [ai_classify()]. For `by = "lines"`, columns `additions` and `deletions`
#' are required (see [gh_commit_lines()]).
#' @param by Either `"commits"` (default) or `"lines"`.
#' @param interval Time bin: `"month"` (default), `"week"`, or `"day"`.
#' @param main Plot title. A sensible default is used when `NULL`.
#' @param col Bar colors. Defaults: gray/red (human/AI) for commits,
#' blue/red (added/deleted) for lines.
#' @param legend_pos Position of the legend (see [graphics::legend()]), or
#' `NULL` to suppress it.
#' @param las Orientation of axis labels (see [graphics::par()]).
#' @param ... Further arguments passed to [graphics::barplot()].
#'
#' @return `x`, invisibly, so the function can be used mid-pipe.
#'
#' @examples
#' data(epiworld_commits)
#'
#' epiworld_commits |>
#'   ai_classify() |>
#'   plot_timeline(by = "commits")
#'
#' epiworld_commits |>
#'   plot_timeline(by = "lines")
#'
#' @family analysis
#' @export
plot_timeline <- function(
    x, by = c("commits", "lines"), interval = c("month", "week", "day"),
    main = NULL, col = NULL, legend_pos = "topleft", las = 2L, ...
    ) {

  by       <- match.arg(by)
  interval <- match.arg(interval)

  if (!"date" %in% names(x))
    stop_("`x` must have a 'date' column (see ?gh_commits).")

  d   <- as.Date(cut(as.POSIXct(x[["date"]]), breaks = interval))
  lev <- seq(min(d, na.rm = TRUE), max(d, na.rm = TRUE), by = interval)
  f   <- factor(as.character(d), levels = as.character(lev))

  labs <- format(lev, if (interval == "month") "%Y-%m" else "%Y-%m-%d")
  if (length(labs) > 24L) {
    keep <- seq(1L, length(labs), by = ceiling(length(labs) / 24L))
    labs[setdiff(seq_along(labs), keep)] <- ""
  }

  if (by == "commits") {

    if ("ai" %in% names(x)) {

      m <- rbind(
        human = tapply(!x[["ai"]], f, sum, default = 0L),
        ai    = tapply(x[["ai"]], f, sum, default = 0L)
      )

      if (is.null(col))
        col <- c("gray70", "tomato")

      barplot(
        m, col = col, border = NA, las = las, names.arg = labs,
        main = main %||% "Commits over time", ...
      )

      if (!is.null(legend_pos))
        legend(
          legend_pos, fill = col, legend = c("Human", "AI-involved"),
          bty = "n"
        )

    } else {

      cnt <- tapply(rep(1L, length(f)), f, sum, default = 0L)

      barplot(
        cnt, col = col %||% "gray70", border = NA, las = las,
        names.arg = labs, main = main %||% "Commits over time", ...
      )

    }

  } else {

    if (!all(c("additions", "deletions") %in% names(x)))
      stop_(
        "`by = \"lines\"` requires columns 'additions' and 'deletions' ",
        "(see ?gh_commit_lines)."
      )

    m <- rbind(
      added   = tapply(x[["additions"]], f, sum, na.rm = TRUE, default = 0),
      deleted = -tapply(x[["deletions"]], f, sum, na.rm = TRUE, default = 0)
    )

    if (is.null(col))
      col <- c("steelblue", "tomato")

    barplot(
      m, col = col, border = NA, las = las, names.arg = labs,
      main = main %||% "Lines added/deleted over time", ...
    )

    abline(h = 0)

    if (!is.null(legend_pos))
      legend(
        legend_pos, fill = col, legend = c("Added", "Deleted"), bty = "n"
      )

  }

  invisible(x)
}
