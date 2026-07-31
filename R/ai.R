#' Default patterns for detecting AI coding agents
#'
#' Returns the default set of case-insensitive regular expressions used by
#' [ai_classify()] to detect AI coding agents. The names of the vector are the
#' labels reported in the `ai_agent`/`ai_mention` columns.
#'
#' @return A named character vector of regular expressions.
#'
#' @details
#' The defaults aim to be parsimonious rather than exhaustive: they catch the
#' major coding agents (GitHub Copilot, Claude, OpenAI Codex/ChatGPT, Gemini,
#' Devin, aider, Cursor, OpenHands) plus a generic `"bot"` pattern for
#' `*[bot]` accounts. Extend or replace them as needed:
#'
#' ```r
#' pats <- c(ai_patterns(), myagent = "internal-ai-tool")
#' ai_classify(commits, patterns = pats)
#' ```
#'
#' Note that the generic `bot` pattern also captures non-AI automation
#' (e.g., `dependabot[bot]`, `github-actions[bot]`). Drop it with
#' `ai_patterns()[names(ai_patterns()) != "bot"]` if you want AI agents only.
#'
#' @family analysis
#' @export
ai_patterns <- function() {
  c(
    copilot    = "copilot",
    claude     = "claude|anthropic",
    openai     = "chat-?gpt|openai|codex",
    gemini     = "gemini-code|gemini-cli",
    jules      = "google-labs-jules",
    devin      = "devin-ai|devin\\[bot\\]",
    aider      = "aider",
    cursor     = "cursor-?agent|cursor\\[bot\\]",
    openhands  = "openhands|all-?hands-?ai",
    coderabbit = "coderabbit",
    bot        = "\\[bot\\]"
  )
}

# Regex templates. Identities are matched anywhere in the string; the others
# are deliberately narrow so that merely *talking* about an agent does not
# count as the agent having done the work.
.tpl_id      <- "%s"
.tpl_trailer <- "(co-authored-by|generated (with|by)|assisted(-| )by)[^\n]*(%s)"
.tpl_mention <- "(^|[^[:alnum:]])@[[:alnum:]_-]*(%s)"
.tpl_branch  <- "^(%s)[/-]"

# Label of the first pattern matching each element of `x` (NA if none).
match_agent <- function(x, patterns, template = .tpl_id) {

  out <- rep(NA_character_, length(x))

  if (!length(x))
    return(out)

  x <- as.character(x)

  for (i in seq_along(patterns)) {
    hit <- is.na(out) &
      grepl(sprintf(template, patterns[i]), x, ignore.case = TRUE, perl = TRUE)
    out[hit] <- names(patterns)[i]
  }

  out
}

# a, unless it is NA, in which case b
coalesce_chr <- function(a, b) ifelse(is.na(a), b, a)

#' Classify AI involvement in commits and interactions
#'
#' Tags each row of a commit history ([gh_commits()]), interaction table
#' ([gh_interactions()]), or pull request table ([gh_pulls()]) according to
#' whether an AI coding agent was involved. The classification is rule-based,
#' parsimonious, and reports evidence in two tiers: **confirmed** (`ai`) and
#' **suspected** (`ai_suspected`).
#'
#' @param x A `data.frame`/`data.table`, typically the output of
#' [gh_commits()], [gh_commit_lines()], or [gh_interactions()].
#' @param patterns Named character vector of case-insensitive regular
#' expressions identifying AI agents. See [ai_patterns()].
#' @param id_cols,text_cols,branch_cols Character vectors with the names of
#' the identity, free-text, and branch-name columns to scan. By default, the
#' intersection of the columns of `x` with, respectively,
#' `c("author", "author_name", "author_email", "committer", "user",
#' "assignee")`, `c("message", "title", "body")`, and `c("branch")`.
#'
#' @return A copy of `x` as a `data.table` with new columns:
#' - `ai`: logical, `TRUE` on **confirmed** involvement, i.e., an AI account
#'   authored/committed/was assigned the row (`identity`), or the text carries
#'   an attribution trailer naming an agent (`trailer`).
#' - `ai_suspected`: logical, `TRUE` on **suspected** involvement, i.e., the
#'   only evidence is an agent branch prefix (see Details). Confirmed and
#'   suspected are mutually exclusive: a row that is `ai` is never
#'   `ai_suspected`.
#' - `ai_agent`: label of the matching agent (`NA` when neither flag is set).
#' - `ai_evidence`: what triggered the flag---`"identity"`, `"trailer"`, or
#'   `"branch"`---so that a classification can be audited or a tier dropped.
#' - `ai_mention`: (only when text columns are present) label of the AI agent
#'   mentioned/addressed in the text (e.g., `"@copilot fix this"`), `NA`
#'   otherwise. Rows with `!ai & !is.na(ai_mention)` are a proxy for humans
#'   prompting AI agents.
#'
#' @section Why branch prefixes are only "suspected":
#' Coding agents push to prefixed branches (`copilot/fix-thing`,
#' `codex/add-tests`), and that prefix often outlives every other trace: it
#' survives squash-merges, and it is present even when no bot account and no
#' commit trailer appear anywhere. But it is weaker evidence than an identity
#' or a trailer, for a specific reason: **the branch may have been created by
#' a human on the agent's behalf.** Several agents cannot open pull requests
#' themselves, so a developer runs the agent locally, pushes the branch it
#' produced, and opens the PR under their own account. The prefix then tells
#' you AI was probably involved, but not who wrote which line---so
#' \pkg{aitracking} reports it as `ai_suspected` rather than folding it into
#' `ai`.
#'
#' This is not hypothetical: in the `UofUEpiBio/epiworld` history, every
#' `copilot/*` pull request was opened by the `Copilot` bot account, while
#' the `codex/*` ones were opened by a human---same kind of prefix, two
#' different attribution stories. Treat `ai` as a lower bound, `ai |
#' ai_suspected` as an upper bound, and report both when the difference
#' matters.
#'
#' @examples
#' commits <- data.frame(
#'   author  = c("gvegayon", "copilot[bot]", "jdoe"),
#'   message = c(
#'     "Add feature",
#'     "Fix bug",
#'     "Refactor\n\nCo-authored-by: Claude <noreply@anthropic.com>"
#'   )
#' )
#' ai_classify(commits)
#'
#' # Branch prefixes are reported as suspected, not confirmed: here a human
#' # opened the PR off a branch an agent produced.
#' pulls <- data.frame(
#'   user   = c("gvegayon", "Copilot"),
#'   branch = c("codex/switch-docs", "copilot/fix-bug")
#' )
#' ai_classify(pulls)[, c("user", "branch", "ai", "ai_suspected", "ai_evidence")]
#'
#' @family analysis
#' @export
ai_classify <- function(
    x, patterns = ai_patterns(), id_cols = NULL, text_cols = NULL,
    branch_cols = NULL
    ) {

  x <- if (data.table::is.data.table(x))
    data.table::copy(x)
  else
    data.table::as.data.table(x)

  if (is.null(id_cols))
    id_cols <- intersect(
      c("author", "author_name", "author_email", "committer", "user",
        "assignee"),
      names(x)
    )

  if (is.null(text_cols))
    text_cols <- intersect(c("message", "title", "body"), names(x))

  if (is.null(branch_cols))
    branch_cols <- intersect("branch", names(x))

  n        <- nrow(x)
  agent    <- rep(NA_character_, n)
  evidence <- rep(NA_character_, n)
  mention  <- rep(NA_character_, n)

  # Records the *first* piece of evidence found for each row, strongest tier
  # first, so that `evidence` says why the row was flagged.
  add_evidence <- function(lab, tag) {
    newly           <- is.na(agent) & !is.na(lab)
    agent[newly]   <<- lab[newly]
    evidence[newly] <<- tag
  }

  # (a) Direct: an AI account authored, committed, or is assigned
  for (col in id_cols)
    add_evidence(match_agent(x[[col]], patterns, .tpl_id), "identity")

  # (b) Direct: attribution trailer (Co-authored-by:, Assisted-by:, ...)
  for (col in text_cols)
    add_evidence(match_agent(x[[col]], patterns, .tpl_trailer), "trailer")

  # (c) Indirect: agent branch prefix ("copilot/fix-thing", "codex/add-tests").
  # A human may have created the branch on the agent's behalf, so this is
  # recorded as suspected rather than confirmed involvement.
  for (col in branch_cols)
    add_evidence(match_agent(x[[col]], patterns, .tpl_branch), "branch")

  # (d) Mentions: "@<agent>" in the text, i.e. humans addressing an agent
  for (col in text_cols)
    mention <- coalesce_chr(
      mention, match_agent(x[[col]], patterns, .tpl_mention)
      )

  data.table::set(
    x, j = "ai", value = !is.na(evidence) & evidence != "branch"
    )
  data.table::set(
    x, j = "ai_suspected",
    value = !is.na(evidence) & evidence == "branch"
    )
  data.table::set(x, j = "ai_agent", value = agent)
  data.table::set(x, j = "ai_evidence", value = evidence)

  if (length(text_cols))
    data.table::set(x, j = "ai_mention", value = mention)

  x[]
}
