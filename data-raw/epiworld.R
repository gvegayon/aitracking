# Regenerates the epiworld example datasets shipped with the package.
# Run from the package root with an authenticated token (see ?gh_token):
#
#   Rscript data-raw/epiworld.R
#
# Note: gh_commit_lines() makes one API call per commit, so this script
# uses ~700 API calls (rate limit with a token: 5,000/hour).
library(aitracking)

# Abort early if we are not authenticated (anonymous = 60 calls/hour)
rl <- gh_api("/rate_limit")$resources$core
if (rl$limit < 5000L)
  stop("Not authenticated: set GITHUB_PAT before running this script.")
message("Authenticated; ", rl$remaining, " API calls remaining this hour.")

repo <- "UofUEpiBio/epiworld"

message("Fetching the commit history of ", repo, "...")
commits <- gh_commits(repo)
message("  ", nrow(commits), " commits.")

message("Fetching per-commit line counts (one API call per commit)...")
epiworld_commits <- gh_commit_lines(commits, verbose = TRUE)

message("Fetching issue/PR interactions...")
epiworld_interactions <- gh_interactions(repo)
message("  ", nrow(epiworld_interactions), " interactions.")

dir.create("data", showWarnings = FALSE)
save(epiworld_commits, file = "data/epiworld_commits.rda", compress = "xz")
save(
  epiworld_interactions, file = "data/epiworld_interactions.rda",
  compress = "xz"
)

message("Done. Files written to data/.")
