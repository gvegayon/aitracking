# Package index

## GitHub API access

Minimal API client built on base R connections.

- [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)
  : Find a GitHub API token
- [`gh_api()`](https://gvegayon.github.io/aitracking/reference/gh_api.md)
  : Low-level access to the GitHub REST API

## Data retrieval

Download commit histories, traffic, interactions, and languages.

- [`gh_commits()`](https://gvegayon.github.io/aitracking/reference/gh_commits.md)
  : Retrieve the commit history of one or more repositories
- [`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md)
  : Retrieve lines added/deleted per commit
- [`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md)
  : Retrieve repository traffic (clones or views)
- [`gh_downloads()`](https://gvegayon.github.io/aitracking/reference/gh_downloads.md)
  : Retrieve download counts of release assets
- [`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md)
  : Retrieve user interactions within a repository
- [`gh_assignments()`](https://gvegayon.github.io/aitracking/reference/gh_assignments.md)
  : Retrieve issue and pull request assignments
- [`gh_pulls()`](https://gvegayon.github.io/aitracking/reference/gh_pulls.md)
  : Retrieve pull requests, including their head branch
- [`gh_languages()`](https://gvegayon.github.io/aitracking/reference/gh_languages.md)
  : Retrieve the language composition of a repository

## Copilot usage

Organization-level Copilot usage, i.e., how much the tool is used rather
than what it left behind in the repository.

- [`gh_copilot_metrics()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_metrics.md)
  : Retrieve Copilot usage metrics for an organization or enterprise
- [`gh_copilot_seats()`](https://gvegayon.github.io/aitracking/reference/gh_copilot_seats.md)
  : Retrieve Copilot seat assignments for an organization

## Analysis and visualization

Classify AI involvement and summarize/plot project activity.

- [`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
  : Classify AI involvement in commits and interactions
- [`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md)
  : Default patterns for detecting AI coding agents
- [`loc_evolution()`](https://gvegayon.github.io/aitracking/reference/loc_evolution.md)
  : Evolution of project size (lines of code) over time
- [`plot_timeline()`](https://gvegayon.github.io/aitracking/reference/plot_timeline.md)
  : Plot a timeline of project activity

## Example data

- [`epiworld_commits`](https://gvegayon.github.io/aitracking/reference/epiworld_commits.md)
  : Commit history of the UofUEpiBio/epiworld C++ library
- [`epiworld_interactions`](https://gvegayon.github.io/aitracking/reference/epiworld_interactions.md)
  : Issue and pull request interactions of UofUEpiBio/epiworld
- [`epiworld_assignments`](https://gvegayon.github.io/aitracking/reference/epiworld_assignments.md)
  : Issue and pull request assignments of UofUEpiBio/epiworld
- [`epiworld_pulls`](https://gvegayon.github.io/aitracking/reference/epiworld_pulls.md)
  : Pull requests of UofUEpiBio/epiworld
