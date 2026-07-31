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
    copilot   = "copilot",
    claude    = "claude|anthropic",
    openai    = "chat-?gpt|openai|codex",
    gemini    = "gemini-code|gemini-cli|google-labs-jules",
    devin     = "devin-ai|devin\\[bot\\]",
    aider     = "aider",
    cursor    = "cursor-?agent|cursor\\[bot\\]",
    openhands = "openhands|all-?hands-?ai",
    bot       = "\\[bot\\]"
  )
}

#' Classify AI involvement in commits and interactions
#'
#' Tags each row of a commit history ([gh_commits()]) or interaction table
#' ([gh_interactions()]) according to whether an AI coding agent was involved.
#' The classification is rule-based and parsimonious: a row is flagged when
#' (a) an identity column (author, committer, user, email) matches an AI agent
#' pattern, or (b) a text column (message, title, body) contains an
#' attribution trailer such as `Co-authored-by: ... <agent>` or
#' `Generated with <agent>`.
#'
#' @param x A `data.frame`/`data.table`, typically the output of
#' [gh_commits()], [gh_commit_lines()], or [gh_interactions()].
#' @param patterns Named character vector of case-insensitive regular
#' expressions identifying AI agents. See [ai_patterns()].
#' @param id_cols,text_cols Character vectors with the names of the identity
#' and free-text columns to scan. By default, the intersection of
#' `c("author", "author_name", "author_email", "committer", "user")` and
#' `c("message", "title", "body")` with the columns of `x`.
#'
#' @return A copy of `x` as a `data.table` with new columns:
#' - `ai`: logical, `TRUE` when an AI agent authored or co-authored the row.
#' - `ai_agent`: label of the first matching pattern (`NA` when `ai` is
#'   `FALSE`).
#' - `ai_mention`: (only when text columns are present) label of the AI agent
#'   mentioned/addressed in the text (e.g., `"@copilot fix this"`), `NA`
#'   otherwise. Rows with `!ai & !is.na(ai_mention)` are a proxy for humans
#'   prompting AI agents.
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
#' @family analysis
#' @export
ai_classify <- function(
    x, patterns = ai_patterns(), id_cols = NULL, text_cols = NULL
    ) {

  x <- if (data.table::is.data.table(x))
    data.table::copy(x)
  else
    data.table::as.data.table(x)

  if (is.null(id_cols))
    id_cols <- intersect(
      c("author", "author_name", "author_email", "committer", "user"),
      names(x)
    )

  if (is.null(text_cols))
    text_cols <- intersect(c("message", "title", "body"), names(x))

  n       <- nrow(x)
  agent   <- rep(NA_character_, n)
  mention <- rep(NA_character_, n)

  for (i in seq_along(patterns)) {

    pat <- patterns[i]
    lab <- names(patterns)[i]

    # (a) Identity columns: direct match
    hit <- rep(FALSE, n)
    for (col in id_cols)
      hit <- hit | grepl(pat, x[[col]], ignore.case = TRUE, perl = TRUE)

    # (b) Text columns: attribution trailers only (parsimonious on purpose)
    trailer <- sprintf(
      "(co-authored-by|generated (with|by)|assisted (with|by))[^\n]*(%s)", pat
    )
    for (col in text_cols)
      hit <- hit | grepl(trailer, x[[col]], ignore.case = TRUE, perl = TRUE)

    # (c) Mentions: "@...<agent>" in the text (humans addressing AI)
    at <- sprintf("(^|[^[:alnum:]])@[[:alnum:]_-]*(%s)", pat)
    hit_mention <- rep(FALSE, n)
    for (col in text_cols)
      hit_mention <- hit_mention |
        grepl(at, x[[col]], ignore.case = TRUE, perl = TRUE)

    agent[is.na(agent) & hit]             <- lab
    mention[is.na(mention) & hit_mention] <- lab

  }

  data.table::set(x, j = "ai", value = !is.na(agent))
  data.table::set(x, j = "ai_agent", value = agent)

  if (length(text_cols))
    data.table::set(x, j = "ai_mention", value = mention)

  x[]
}
