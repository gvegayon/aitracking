# Plot a timeline of project activity

Visualizes the activity of a project over time in one of two ways:
number of commits (`by = "commits"`) or lines added/deleted
(`by = "lines"`). When the input has been through
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md),
commit bars are split into human and AI contributions.

## Usage

``` r
plot_timeline(
  x,
  by = c("commits", "lines"),
  interval = c("month", "week", "day"),
  main = NULL,
  col = NULL,
  legend_pos = "topleft",
  las = 2L,
  ...
)
```

## Arguments

- x:

  A `data.frame`/`data.table` with a `date` column (`POSIXct`),
  typically the output of
  [`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
  [`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
  or
  [`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md).
  For `by = "lines"`, columns `additions` and `deletions` are required
  (see
  [`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md)).

- by:

  Either `"commits"` (default) or `"lines"`.

- interval:

  Time bin: `"month"` (default), `"week"`, or `"day"`.

- main:

  Plot title. A sensible default is used when `NULL`.

- col:

  Bar colors. Defaults: gray/red (human/AI) for commits, blue/red
  (added/deleted) for lines.

- legend_pos:

  Position of the legend (see
  [`graphics::legend()`](https://rdrr.io/r/graphics/legend.html)), or
  `NULL` to suppress it.

- las:

  Orientation of axis labels (see
  [`graphics::par()`](https://rdrr.io/r/graphics/par.html)).

- ...:

  Further arguments passed to
  [`graphics::barplot()`](https://rdrr.io/r/graphics/barplot.html).

## Value

`x`, invisibly, so the function can be used mid-pipe.

## See also

Other analysis:
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md),
[`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md),
[`loc_evolution()`](https://gvegayon.github.io/aitracking/reference/loc_evolution.md)

## Examples

``` r
data(epiworld_commits)

epiworld_commits |>
  ai_classify() |>
  plot_timeline(by = "commits")


epiworld_commits |>
  plot_timeline(by = "lines")

```
