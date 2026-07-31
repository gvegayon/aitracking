# Retrieve issue and pull request assignments

Downloads the issues and pull requests of one or more repositories
together with the accounts they are assigned to, and flags the
assignments handed to an AI coding agent. Assigning an issue to an agent
(e.g., selecting "Copilot" in the Assignees box) is how GitHub's coding
agent is asked to do a task, so these rows are a direct measure of
*delegation* to AI, as opposed to the AI involvement in the resulting
code that
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md)
plus
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
measure.

## Usage

``` r
gh_assignments(
  repo,
  state = c("all", "open", "closed"),
  since = NULL,
  ai_only = FALSE,
  patterns = ai_patterns(),
  token = gh_token(),
  max_pages = Inf
)
```

## Arguments

- repo:

  Character vector of repositories in `"owner/repo"` form.

- state:

  One of `"all"` (default), `"open"`, or `"closed"`.

- since:

  Optional lower bound on the *last update* time (`Date`, `POSIXct`, or
  character), following the GitHub API.

- ai_only:

  Logical scalar. When `TRUE`, only assignments to AI agents are
  returned.

- patterns:

  Named character vector of agent patterns used to decide what counts as
  an AI assignee. See
  [`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md).

- token:

  GitHub token (see
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).

- max_pages:

  Number of pages (of 100 records each) to retrieve at most per
  repository.

## Value

A `data.table` with **one row per issue/assignee pair**, sorted by time,
and columns:

- `repo`, `type` (`"issue"` or `"pull_request"`), `number`, `title`.

- `user`: login of the account that *opened* the issue/PR.

- `assignee`: login of the assigned account, `NA` when nobody is
  assigned.

- `assignee_type`: `"User"` or `"Bot"`, as reported by GitHub.

- `assigned_ai`: logical, `TRUE` when the assignee matches an AI agent.

- `assigned_agent`: which agent (`NA` otherwise).

- `state`, `created_at`, `closed_at`.

Issues with several assignees contribute one row each; unassigned issues
contribute a single row with `assignee = NA`, so that shares (e.g., the
fraction of issues delegated to an agent) can be computed from the same
table.

## Details

Note that GitHub reports the Copilot coding agent as the login `Copilot`
with `assignee_type == "Bot"`, *without* the usual `[bot]` suffix (its
underlying account is `copilot-swe-agent[bot]`). Matching on
`assignee_type` alone is not enough either: some agents (e.g.,
`cursoragent`, `openhands-agent`) are plain `"User"` accounts. This is
why the default detection is pattern-based; see
[`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md).

## See also

Other retrieval:
[`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md),
[`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md),
[`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md),
[`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md),
[`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md),
[`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md),
[`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Everything delegated to an AI agent
gh_assignments("UofUEpiBio/epiworld", ai_only = TRUE)

# Share of issues/PRs delegated to an agent
a <- gh_assignments("UofUEpiBio/epiworld")
mean(a$assigned_ai)
} # }
```
