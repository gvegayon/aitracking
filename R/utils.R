# Internal helpers (not exported)

`%||%` <- function(a, b) if (is.null(a)) b else a

# Safe scalar extractors for parsed JSON (NULL -> NA)
chr1 <- function(x) if (is.null(x)) NA_character_ else as.character(x)[1L]
int1 <- function(x) if (is.null(x)) NA_integer_ else as.integer(x)[1L]

# GitHub timestamps come as, e.g., "2023-01-15T12:34:56Z" (UTC)
parse_gh_time <- function(x) {
  as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
}

# Format R dates/times (or "YYYY-MM-DD" strings) as ISO 8601 for the API
fmt_gh_time <- function(x) {
  if (is.null(x)) return(NULL)
  if (inherits(x, "Date")) return(format(x, "%Y-%m-%dT00:00:00Z"))
  if (inherits(x, "POSIXt")) return(format(x, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
  x <- as.character(x)[1L]
  if (grepl("^\\d{4}-\\d{2}-\\d{2}$", x)) return(paste0(x, "T00:00:00Z"))
  x
}

# Extract the trailing number of an API URL (e.g., .../issues/123 -> 123L)
int_from_url <- function(x) {
  x <- chr1(x)
  if (is.na(x)) return(NA_integer_)
  as.integer(basename(x))
}

stop_ <- function(...) stop(..., call. = FALSE)
