# Retrieve pull requests, including their head branch

Downloads the pull requests of one or more repositories. Unlike
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
which sees PRs through the issues endpoint, this function returns the
**head branch name**, which is one of the more reliable traces of AI
involvement: coding agents push to prefixed branches such as
`copilot/fix-thing` or `codex/add-tests`, and that prefix survives even
when a human opens the pull request and squash-merges it.

## Usage

``` r
gh_pulls(
  repo,
  state = c("all", "open", "closed"),
  token = gh_token(),
  max_pages = Inf
)
```

## Arguments

- repo:

  Character vector of repositories in `"owner/repo"` form.

- state:

  One of `"all"` (default), `"open"`, or `"closed"`.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- max_pages:

  Number of pages (of 100 PRs each) to retrieve at most per repository.

## Value

A `data.table` with one row per pull request, sorted by time, and
columns `repo`, `number`, `title`, `user` (who opened it), `branch` (the
head ref), `base` (the target branch), `state`, `draft`, `created_at`,
`merged_at`, and `closed_at`.

## Details

[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
scans a `branch` column by default, so piping the result straight into
it picks up the branch-prefix signal on top of the usual identity and
commit-trailer rules.

## See also

Other retrieval:
[`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md),
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
[`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md),
[`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Which PRs came off an agent branch, and who opened them?
gh_pulls("UofUEpiBio/epiworld") |>
  ai_classify() |>
  subset(ai, select = c(number, user, branch, ai_agent))
} # }
```
