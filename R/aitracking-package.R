#' @keywords internal
"_PACKAGE"

#' @import data.table
#' @importFrom utils txtProgressBar setTxtProgressBar URLencode
#' @importFrom graphics barplot legend abline
NULL

utils::globalVariables(c(
  ".", "ai", "ai_agent", "ai_mention", "additions", "deletions", "delta",
  "loc", "language", "repo", "sha", "bytes", "share", "i.date", "created_at"
))
