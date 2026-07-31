# AGENTS.md — Notes for AI agents working on this repository

`aitracking` is an R package to measure the effects of AI-assisted
coding on software projects using the GitHub REST API.

## Design principles (do not break these)

- **Base R first.** Use base R whenever possible; reach for `data.table`
  when more data-processing power is needed. Do **not** add dependencies
  without a very good reason. The only hard dependencies are
  `data.table` and `jsonlite`.
- **No `gh`/`httr`/`httr2` dependency, on purpose.** The GitHub API
  client is implemented with base R connections
  ([`url()`](https://rdrr.io/r/base/connections.html) + headers) in
  [R/api.R](https://gvegayon.github.io/aitracking/R/api.R)
  ([`gh_api()`](https://gvegayon.github.io/aitracking/reference/gh_api.md),
  `gh_get()`,
  [`gh_token()`](https://gvegayon.github.io/aitracking/reference/gh_token.md)).
  Keep it that way.
- **snake_case** for all function names and arguments.
- **Pipe-friendly:** every user-facing function takes the data (or the
  repo) as its **first argument** and returns something the next
  function can consume with R’s native pipe `|>`.
  [`plot_timeline()`](https://gvegayon.github.io/aitracking/reference/plot_timeline.md)
  returns its input invisibly for the same reason.
- **Retrieval functions return `data.table`s** with a `repo` column so
  that results from multiple repositories can be stacked.
- **[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
  must stay parsimonious.** It is a rule-based classifier (identity
  columns + commit-message trailers + `@`-mentions). Patterns live in
  [`ai_patterns()`](https://gvegayon.github.io/aitracking/reference/ai_patterns.md);
  extend the vector rather than adding complexity.

## Toolchain

- **Testing:** [tinytest](https://github.com/markvanderloo/tinytest).
  Tests live in `inst/tinytest/test_*.R` and are run by
  `tests/tinytest.R`. Network-dependent tests must be wrapped in
  `if (at_home() && nzchar(gh_token())) { ... }` so CRAN/CI never need a
  token.
- **Test parsing offline, not over the network.** Each retrieval
  function is split in two: the part that calls the API, and an internal
  `as_*_dt()` parser that turns the parsed JSON into a `data.table`
  (`as_commits_dt()`, `as_commit_files_dt()`, `as_issues_dt()`,
  `as_comments_dt()`, `as_traffic_dt()`, `as_downloads_dt()`,
  `as_languages_dt()`). The parsers are tested in
  `inst/tinytest/test_parsers.R` against real API responses stored in
  `inst/tinytest/fixtures/*.json`, trimmed to the fields the parsers
  read. When you add a retrieval function, follow the same split and add
  a fixture; when GitHub changes a payload, refresh the fixture. This is
  what keeps coverage meaningful without a token.
- **Documentation:** roxygen2 with markdown
  (`Roxygen: list(markdown = TRUE)`). Regenerate with
  `Rscript -e 'roxygen2::roxygenize()'`. Never edit `man/` or
  `NAMESPACE` by hand.
- **Vignettes and README:** Quarto. The vignette engine is
  `quarto::html` (see `VignetteBuilder` in DESCRIPTION). `README.md` is
  generated from `README.qmd`; edit the `.qmd` and re-render with
  `quarto render README.qmd` — never edit `README.md` directly.
- **Vignettes must build offline.** They use the shipped datasets
  (`epiworld_commits`, `epiworld_interactions`); API-calling chunks are
  shown with `#| eval: false`.

## Common tasks

``` sh
# Regenerate docs + install
Rscript -e 'roxygen2::roxygenize()'
R CMD INSTALL .

# Run tests (installed package)
Rscript -e 'tinytest::test_package("aitracking")'
# ...or on the sources during development
Rscript -e 'tinytest::run_test_dir("inst/tinytest")'

# Full check
R CMD build .
R CMD check --as-cran aitracking_*.tar.gz

# Re-render the README
quarto render README.qmd

# Regenerate the example datasets (~700 API calls; needs a token)
Rscript data-raw/epiworld.R
```

## CI (GitHub Actions)

- `R-CMD-check.yaml`: runs `R CMD check` on Linux (release + devel),
  macOS, and Windows. Quarto CLI is installed on all runners (needed for
  the vignette). It also installs the package itself (`local::.`):
  quarto renders the vignette in a **separate R process**, which on
  Windows cannot see the temporary check library, so without this
  [`library(aitracking)`](https://github.com/gvegayon/aitracking) fails
  there while Linux and macOS pass. Don’t remove it.
- `pkgdown.yaml`: builds the site and deploys it to the `gh-pages`
  branch → <https://gvegayon.github.io/aitracking/>.
- `test-coverage.yaml`: runs covr and uploads to Codecov. Requires the
  `CODECOV_TOKEN` repository secret.

## Gotchas

- [`gh_commit_lines()`](https://gvegayon.github.io/aitracking/reference/gh_commit_lines.md)
  makes **one API call per commit**. Authenticated rate limit is
  5,000/hour. Don’t call it on huge histories in examples or tests.
- GitHub’s traffic API
  ([`gh_traffic()`](https://gvegayon.github.io/aitracking/reference/gh_traffic.md))
  requires push access to the repo and only holds 14 days of history.
- The `/repos/{repo}/issues` endpoint returns PRs too;
  [`gh_interactions()`](https://gvegayon.github.io/aitracking/reference/gh_interactions.md)
  distinguishes them via the `pull_request` field.
- `data/` is generated by `data-raw/epiworld.R`; don’t edit `.rda` files
  directly. If you regenerate them, update the snapshot date in
  [R/data.R](https://gvegayon.github.io/aitracking/R/data.R) and re-run
  roxygen2.
