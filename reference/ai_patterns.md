# Default patterns for detecting AI coding agents

Returns the default set of case-insensitive regular expressions used by
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md)
to detect AI coding agents. The names of the vector are the labels
reported in the `ai_agent`/`ai_mention` columns.

## Usage

``` r
ai_patterns()
```

## Value

A named character vector of regular expressions.

## Details

The defaults aim to be parsimonious rather than exhaustive: they catch
the major coding agents (GitHub Copilot, Claude, OpenAI Codex/ChatGPT,
Gemini, Devin, aider, Cursor, OpenHands) plus a generic `"bot"` pattern
for `*[bot]` accounts. Extend or replace them as needed:

    pats <- c(ai_patterns(), myagent = "internal-ai-tool")
    ai_classify(commits, patterns = pats)

Note that the generic `bot` pattern also captures non-AI automation
(e.g., `dependabot[bot]`, `github-actions[bot]`). Drop it with
`ai_patterns()[names(ai_patterns()) != "bot"]` if you want AI agents
only.

## See also

Other analysis:
[`ai_classify()`](https://gvegayon.github.io/aitracking/reference/ai_classify.md),
[`loc_evolution()`](https://gvegayon.github.io/aitracking/reference/loc_evolution.md),
[`plot_timeline()`](https://gvegayon.github.io/aitracking/reference/plot_timeline.md)
