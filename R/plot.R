#' Plot a timeline of project activity
#'
#' Visualizes the activity of a project over time in one of two ways: number
#' of commits (`by = "commits"`) or lines added/deleted (`by = "lines"`).
#' When the input has been through [ai_classify()], commit bars are split into
#' human and AI contributions.
#'
#' @param x A `data.frame`/`data.table` with a date column (`POSIXct`; see
#' `date_col`), typically the output of [gh_commits()], [gh_commit_lines()],
#' or [ai_classify()]. For `by = "lines"`, columns `additions` and
#' `deletions` are required (see [gh_commit_lines()]).
#' @param by Either `"commits"` (default, i.e., a row count) or `"lines"`.
#' Despite the name, `by = "commits"` counts rows generically, so it works
#' just as well on issues/PRs (see Examples) as on commits.
#' @param interval Time bin: `"month"` (default), `"week"`, or `"day"`. Bins
#' are calendar-aligned (e.g., `"week"` bins start on Sundays), and only span
#' the range actually present in `x`--filter `x` first to zoom into a shorter
#' window (see Examples).
#' @param date_col,ai_col,suspected_col Names of the columns holding,
#' respectively, the timestamp, the confirmed-AI-involvement flag, and the
#' suspected-AI-involvement flag. Default to `"date"`, `"ai"`, and
#' `"ai_suspected"`--the names [gh_commits()] and [ai_classify()] use. Pass
#' `ai_col = "assigned_ai"` to plot the output of [gh_assignments()], whose
#' columns are named differently; `suspected_col` can be left at its default
#' since a column that does not exist is treated as "no suspected tier"
#' (see `by = "commits"` below).
#' @param main Plot title. A sensible default is used when `NULL`.
#' @param col Bar colors. Defaults: gray/gold/red (human/suspected/confirmed)
#' for commits, blue/red (added/deleted) for lines.
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
#' # Zoom into a shorter window by filtering first, and switch to daily bins
#' epiworld_commits[epiworld_commits$date < as.POSIXct("2022-01-01"), ] |>
#'   plot_timeline(by = "commits", interval = "day")
#'
#' # Reuse on a differently-shaped table, e.g. gh_assignments()'s output
#' data(epiworld_assignments)
#' epiworld_assignments |>
#'   plot_timeline(
#'     by = "commits", date_col = "created_at", ai_col = "assigned_ai",
#'     main = "Issues/PRs assigned over time"
#'   )
#'
#' @family analysis
#' @export
plot_timeline <- function(
    x, by = c("commits", "lines"), interval = c("month", "week", "day"),
    date_col = "date", ai_col = "ai", suspected_col = "ai_suspected",
    main = NULL, col = NULL, legend_pos = "topleft", las = 2L, ...
    ) {

  by       <- match.arg(by)
  interval <- match.arg(interval)

  if (!date_col %in% names(x))
    stop_(
      "`x` must have a '", date_col, "' column (see the `date_col` argument)."
    )

  d   <- as.Date(cut(as.POSIXct(x[[date_col]]), breaks = interval))
  lev <- seq(min(d, na.rm = TRUE), max(d, na.rm = TRUE), by = interval)
  f   <- factor(as.character(d), levels = as.character(lev))

  labs <- format(lev, if (interval == "month") "%Y-%m" else "%Y-%m-%d")
  if (length(labs) > 24L) {
    keep <- seq(1L, length(labs), by = ceiling(length(labs) / 24L))
    labs[setdiff(seq_along(labs), keep)] <- ""
  }

  if (by == "commits") {

    if (ai_col %in% names(x)) {

      ai <- as.logical(x[[ai_col]])

      # Suspected involvement (branch-prefix evidence only) gets its own
      # band, so the confirmed count is never inflated by it. Tables with no
      # `suspected_col` (e.g. gh_assignments()'s output) simply have none.
      susp <- if (suspected_col %in% names(x))
        as.logical(x[[suspected_col]])
      else
        rep(FALSE, nrow(x))

      show_susp <- any(susp, na.rm = TRUE)

      m <- rbind(
        human = tapply(!ai & !susp, f, sum, default = 0L),
        susp  = tapply(susp, f, sum, default = 0L),
        ai    = tapply(ai, f, sum, default = 0L)
      )

      keys <- c("Human", "AI (suspected)", "AI (confirmed)")

      if (is.null(col))
        col <- c("gray70", "goldenrod", "tomato")

      if (!show_susp) {
        m    <- m[c("human", "ai"), , drop = FALSE]
        keys <- keys[c(1L, 3L)]
        col  <- col[c(1L, 3L)]
      }

      barplot(
        m, col = col, border = NA, las = las, names.arg = labs,
        main = main %||% "Commits over time", ...
      )

      if (!is.null(legend_pos))
        legend(legend_pos, fill = col, legend = keys, bty = "n")

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
