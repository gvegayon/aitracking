# Evolution of project size (lines of code) over time

Computes the cumulative net lines of code (additions minus deletions) of
a project over time from its commit history. With file-level input (from
`gh_commit_lines(x, files = TRUE)`), the evolution is broken down by
language, mapped from file extensions.

## Usage

``` r
loc_evolution(x)
```

## Arguments

- x:

  A `data.frame`/`data.table` with columns `date`, `additions`, and
  `deletions`–i.e., the output of
  [`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md).
  If a `file` column is present (from `gh_commit_lines(files = TRUE)`),
  the result is computed by language.

## Value

A `data.table` with columns `repo`, `date`, `delta` (net lines changed
at that time), and `loc` (cumulative net lines), plus `language` when
`x` has file-level detail. Sorted by time within `repo` (and
`language`).

## Details

The measure is approximate: it counts net *lines changed* as reported by
GitHub, which includes documentation, data, and other non-code files
(unless you filter them out beforehand). Commits with missing statistics
contribute zero.

## See also

Other analysis:
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md),
[`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md),
[`plot_timeline()`](https://gvegayon.github.io/aitracking/reference/plot_timeline.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gh_commits("UofUEpiBio/epiworld") |>
  gh_commit_lines(files = TRUE) |>
  loc_evolution()
} # }
```
