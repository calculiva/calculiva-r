# Number helpers shared by the estimators: tolerant rounding, range checks and
# the number formats used in error messages (Go: internal/num).

# One inch and one foot in millimetres (exact by definition of the
# international inch and foot).
INCH <- 25.4
FOOT <- 304.8

# Absolute tolerance of the range checks, in the unit of the value.
EPS <- 1e-7

# Bounds of a plan length, mm, and the end of the message that states them.
LEN_MIN <- 50.0
LEN_MAX <- 60000.0
LEN_MSG <- " from 50 mm to 60 m (about 2 in to 196 ft)."

nz <- function(x, default) if (is.null(x)) default else x

num <- function(x) as.numeric(unlist(x))

# The Go module computes in float64: whole numbers given as R integers (1L, or
# the whole numbers read by jsonlite) become doubles, so that a product such as
# area x depth x count cannot overflow R's 32-bit integers.
as_dbl <- function(x) {
  if (is.list(x)) {
    y <- lapply(x, as_dbl)
    names(y) <- names(x)
    return(y)
  }
  if (is.integer(x)) as.double(x) else x
}

# Fills the missing fields of a list with their defaults.
with_defaults <- function(x, defaults) {
  x <- nz(x, list())
  for (k in names(defaults)) {
    if (is.null(x[[k]])) x[k] <- list(defaults[[k]])
  }
  x
}

input_error <- function(message, field) {
  stop(structure(
    class = c("calculiva_input_error", "error", "condition"),
    list(message = paste0(message, " (", field, ")"), call = NULL, field = field, input_message = message)
  ))
}

# Checks that v is a finite number within [lo, hi] (tolerance 1e-7).
check_range <- function(v, lo, hi, message, field) {
  if (length(v) != 1L || !is.finite(v) || v < lo - EPS || v > hi + EPS) {
    input_error(message, field)
  }
  invisible(NULL)
}

is_whole <- function(v) v == trunc(v)

# Rounds up, forgiving a relative 1e-9 of floating-point noise.
ceil_rel <- function(n) ceiling(n - 1e-9 * max(abs(n), 1.0))

# Rounds down, forgiving a relative 1e-9 of floating-point noise.
floor_rel <- function(n) floor(n + 1e-9 * max(abs(n), 1.0))

# Rounds up, forgiving eight ULPs.
ceil_ulp <- function(n) ceiling(n - .Machine$double.eps * max(n, 1.0) * 8)

# The shortest decimal that reads back as v, without exponent (Go:
# strconv.FormatFloat(v, 'f', -1, 64)).
shortest <- function(v) {
  if (is.finite(v) && is_whole(v) && abs(v) < 1e15) {
    return(sprintf("%.0f", v))
  }
  max_digits <- ceiling(.Machine$double.digits * log10(2)) + 1
  for (d in seq_len(max_digits)) {
    s <- sprintf(paste0("%.", d - 1, "e"), v)
    if (as.numeric(s) == v) break
  }
  parts <- strsplit(s, "e", fixed = TRUE)[[1]]
  digits <- gsub("[-.]", "", parts[1])
  e <- as.integer(parts[2])
  n <- nchar(digits)
  out <- if (e < 0) {
    paste0("0.", strrep("0", -e - 1), digits)
  } else if (n <= e + 1) {
    paste0(digits, strrep("0", e + 1 - n))
  } else {
    paste0(substr(digits, 1, e + 1), ".", substr(digits, e + 2, n))
  }
  if (v < 0) paste0("-", out) else out
}

# JavaScript's String(n) for the values used in messages.
js_num <- function(v) shortest(v)

# JavaScript's toLocaleString('en-US', {maximumFractionDigits}) for the values
# used in messages: grouped thousands, trailing zeros removed.
locale <- function(v, digits) {
  s <- sprintf(paste0("%.", digits, "f"), v)
  parts <- strsplit(s, ".", fixed = TRUE)[[1]]
  whole <- parts[1]
  frac <- if (length(parts) > 1) sub("0+$", "", parts[2]) else ""
  neg <- startsWith(whole, "-")
  body <- strsplit(sub("^-+", "", whole), "")[[1]]
  grouped <- ""
  for (i in seq_along(body)) {
    if (i > 1 && (length(body) - i + 1) %% 3 == 0) grouped <- paste0(grouped, ",")
    grouped <- paste0(grouped, body[i])
  }
  out <- ""
  if (neg && (gsub("[0,]", "", grouped) != "" || frac != "")) out <- "-"
  out <- paste0(out, grouped)
  if (frac != "") out <- paste0(out, ".", frac)
  out
}

padded <- function(n, width) formatC(as.integer(n), width = width, flag = "0")
