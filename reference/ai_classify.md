# Classify AI involvement in commits and interactions

Tags each row of a commit history
([`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md)),
interaction table
([`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md)),
or pull request table
([`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md))
according to whether an AI coding agent was involved. The classification
is rule-based, parsimonious, and reports evidence in two tiers:
**confirmed** (`ai`) and **suspected** (`ai_suspected`).

## Usage

``` r
ai_classify(
  x,
  patterns = ai_patterns(),
  id_cols = NULL,
  text_cols = NULL,
  branch_cols = NULL
)
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

- id_cols, text_cols, branch_cols:

  Character vectors with the names of the identity, free-text, and
  branch-name columns to scan. By default, the intersection of the
  columns of `x` with, respectively,
  `c("author", "author_name", "author_email", "committer", "user", "assignee")`,
  `c("message", "title", "body")`, and `c("branch")`.

## Value

A copy of `x` as a `data.table` with new columns:

- `ai`: logical, `TRUE` on **confirmed** involvement, i.e., an AI
  account authored/committed/was assigned the row (`identity`), or the
  text carries an attribution trailer naming an agent (`trailer`).

- `ai_suspected`: logical, `TRUE` on **suspected** involvement, i.e.,
  the only evidence is an agent branch prefix (see Details). Confirmed
  and suspected are mutually exclusive: a row that is `ai` is never
  `ai_suspected`.

- `ai_agent`: label of the matching agent (`NA` when neither flag is
  set).

- `ai_evidence`: what triggered the flag—`"identity"`, `"trailer"`, or
  `"branch"`—so that a classification can be audited or a tier dropped.

- `ai_mention`: (only when text columns are present) label of the AI
  agent mentioned/addressed in the text (e.g., `"@copilot fix this"`),
  `NA` otherwise. Rows with `!ai & !is.na(ai_mention)` are a proxy for
  humans prompting AI agents.

## Why branch prefixes are only "suspected"

Coding agents push to prefixed branches (`copilot/fix-thing`,
`codex/add-tests`), and that prefix often outlives every other trace: it
survives squash-merges, and it is present even when no bot account and
no commit trailer appear anywhere. But it is weaker evidence than an
identity or a trailer, for a specific reason: **the branch may have been
created by a human on the agent's behalf.** Several agents cannot open
pull requests themselves, so a developer runs the agent locally, pushes
the branch it produced, and opens the PR under their own account. The
prefix then tells you AI was probably involved, but not who wrote which
line—so aitracking reports it as `ai_suspected` rather than folding it
into `ai`.

This is not hypothetical: in the `UofUEpiBio/epiworld` history, every
`copilot/*` pull request was opened by the `Copilot` bot account, while
the `codex/*` ones were opened by a human—same kind of prefix, two
different attribution stories. Treat `ai` as a lower bound,
`ai | ai_suspected` as an upper bound, and report both when the
difference matters.

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
#>        ai ai_suspected ai_agent ai_evidence ai_mention
#>    <lgcl>       <lgcl>   <char>      <char>     <char>
#> 1:  FALSE        FALSE     <NA>        <NA>       <NA>
#> 2:   TRUE        FALSE  copilot    identity       <NA>
#> 3:   TRUE        FALSE   claude     trailer       <NA>

# Branch prefixes are reported as suspected, not confirmed: here a human
# opened the PR off a branch an agent produced.
pulls <- data.frame(
  user   = c("gvegayon", "Copilot"),
  branch = c("codex/switch-docs", "copilot/fix-bug")
)
ai_classify(pulls)[, c("user", "branch", "ai", "ai_suspected", "ai_evidence")]
#>        user            branch     ai ai_suspected ai_evidence
#>      <char>            <char> <lgcl>       <lgcl>      <char>
#> 1: gvegayon codex/switch-docs  FALSE         TRUE      branch
#> 2:  Copilot   copilot/fix-bug   TRUE        FALSE    identity
```
