# Classify AI involvement in commits and interactions

Tags each row of a commit history
([`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md))
or interaction table
([`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md))
according to whether an AI coding agent was involved. The classification
is rule-based and parsimonious: a row is flagged when (a) an identity
column (author, committer, user, email) matches an AI agent pattern, or
(b) a text column (message, title, body) contains an attribution trailer
such as `Co-authored-by: ... <agent>` or `Generated with <agent>`.

## Usage

``` r
ai_classify(x, patterns = ai_patterns(), id_cols = NULL, text_cols = NULL)
```

## Arguments

- x:

  A `data.frame`/`data.table`, typically the output of
  [`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
  [`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
  or
  [`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md).

- patterns:

  Named character vector of case-insensitive regular expressions
  identifying AI agents. See
  [`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md).

- id_cols, text_cols:

  Character vectors with the names of the identity and free-text columns
  to scan. By default, the intersection of
  `c("author", "author_name", "author_email", "committer", "user")` and
  `c("message", "title", "body")` with the columns of `x`.

## Value

A copy of `x` as a `data.table` with new columns:

- `ai`: logical, `TRUE` when an AI agent authored or co-authored the
  row.

- `ai_agent`: label of the first matching pattern (`NA` when `ai` is
  `FALSE`).

- `ai_mention`: (only when text columns are present) label of the AI
  agent mentioned/addressed in the text (e.g., `"@copilot fix this"`),
  `NA` otherwise. Rows with `!ai & !is.na(ai_mention)` are a proxy for
  humans prompting AI agents.

## See also

Other analysis:
[`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md),
[`loc_evolution()`](https://gvegayon.github.io/aitracking/reference/loc_evolution.md),
[`plot_timeline()`](https://gvegayon.github.io/aitracking/reference/plot_timeline.md)

## Examples

``` r
commits <- data.frame(
  author  = c("gvegayon", "copilot[bot]", "jdoe"),
  message = c(
    "Add feature",
    "Fix bug",
    "Refactor\n\nCo-authored-by: Claude <noreply@anthropic.com>"
  )
)
ai_classify(commits)
#>          author                                                    message
#>          <char>                                                     <char>
#> 1:     gvegayon                                                Add feature
#> 2: copilot[bot]                                                    Fix bug
#> 3:         jdoe Refactor\n\nCo-authored-by: Claude <noreply@anthropic.com>
#>        ai ai_agent ai_mention
#>    <lgcl>   <char>     <char>
#> 1:  FALSE     <NA>       <NA>
#> 2:   TRUE  copilot       <NA>
#> 3:   TRUE   claude       <NA>
```
