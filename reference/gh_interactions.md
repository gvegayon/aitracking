# Retrieve user interactions within a repository

Downloads issues, pull requests, issue/PR comments, and pull request
review comments of one or more repositories. This is the conversation
layer of a project–including the requests humans make to AI agents in
issues and PRs–which survives even when the commits themselves are
squash-merged.

## Usage

``` r
gh_interactions(repo, since = NULL, token = gh_token(), max_pages = Inf)
```

## Arguments

- repo:

  Character vector of repositories in `"owner/repo"` form.

- since:

  Optional lower time bound (`Date`, `POSIXct`, or character). Note
  that, following the GitHub API, for issues/PRs this filters by *last
  update* time, and for comments by *creation* time.

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- max_pages:

  Number of pages (of 100 records each) to retrieve at most per
  repository and record type.

## Value

A `data.table` with one row per interaction, sorted by time, and
columns:

- `repo`: the repository.

- `type`: one of `"issue"`, `"pull_request"`, `"issue_comment"`
  (comments on issues *and* PRs), or `"review_comment"` (inline
  code-review comments on PRs).

- `number`: the issue/PR number the interaction belongs to.

- `user`: GitHub login of the user (bots show as, e.g.,
  `"copilot[bot]"`).

- `created_at`: creation time (`POSIXct`, UTC).

- `title`: issue/PR title (`NA` for comments).

- `body`: full text of the issue/PR description or comment.

## Details

Combine with
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
to flag which interactions were authored by AI agents (`ai`) and which
ones mention or address an AI agent (`ai_mention`)–the latter is a
simple proxy for how much humans are prompting AI within the repository.

## See also

Other retrieval:
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
[`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md),
[`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gh_interactions("UofUEpiBio/epiworld") |>
  ai_classify()
} # }
```
