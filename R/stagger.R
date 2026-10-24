# The staggered row layout used by sod_lay_rect: horizontal rows, unbalanced
# edge row, no gap, no kerf, factory-end pairing of start and end offcuts.

# The upper bound on individually placed pieces in one layout.
MAX_PIECES <- 2500

positive <- function(v, key, label, lo, hi) {
  if (!is.finite(v) || v < lo || v > hi) {
    input_error(paste0("Enter ", label, " between ", shortest(lo), " and ", shortest(hi), " mm."), key)
  }
}

row_widths <- function(span, width) {
  if (!(span > 0.0 && width > 0.0)) input_error("The usable width must be positive.", "roomW")
  n <- ceil_ulp(span / width)
  if (n == 1.0) return(span)
  last <- span - (n - 1.0) * width
  c(rep(width, n - 1), last)
}

# Remainder of x by y (Go: math.Mod) for the non-negative values of the layout.
fmod <- function(x, y) {
  r <- x %% y
  if (r >= y) r - y else r
}

# Pairs start and end offcuts that fit one piece. Each pair uses opposite
# factory ends; no same-end pairing or face flipping.
pair_cuts <- function(pieces, plank_l) {
  sources <- list()
  assigned <- rep(FALSE, length(pieces))
  add <- function(idx) {
    assigned[idx] <<- TRUE
    sources[[length(sources) + 1]] <<- list(
      id = paste0("B", padded(length(sources) + 1, 3)),
      pieces = vapply(idx, function(i) pieces[[i]]$id, character(1)),
      pair = length(idx) == 2
    )
  }
  roles <- vapply(pieces, function(p) p$role, character(1))
  lengths <- vapply(pieces, function(p) p$length, numeric(1))
  starts <- which(roles == "start")
  # Longest start first; ties keep their order.
  starts <- starts[order(-lengths[starts], starts)]
  for (a in starts) {
    best <- -1
    for (i in seq_along(pieces)) {
      if (roles[i] == "end" && !assigned[i] && lengths[i] + lengths[a] <= plank_l + EPS) {
        if (best < 0 || !(lengths[best] >= lengths[i])) best <- i
      }
    }
    if (best >= 0) add(c(best, a))
  }
  for (i in seq_along(pieces)) {
    if (!assigned[i]) add(i)
  }
  sources
}

# Lays horizontal staggered rows over room_w x room_h, the first row starting
# with a full plank, offset of a plank per row, start and end offcuts paired
# when they fit one plank.
staggered <- function(room_w, room_h, plank_w, plank_l, offset, max_room, max_plank_w) {
  positive(room_w, "roomW", "the room width", 10.0, max_room)
  positive(room_h, "roomH", "the room length", 10.0, max_room)
  positive(plank_w, "plankW", "the plank width", 10.0, max_plank_w)
  positive(plank_l, "plankL", "the plank length", 10.0, 6000.0)
  first <- plank_l
  span <- room_h
  run <- room_w
  widths <- row_widths(span, plank_w)
  if (length(widths) > MAX_PIECES) input_error("Use a larger plank or a smaller field.", "plankW")
  rows <- vector("list", length(widths))
  pieces <- list()
  across <- 0.0
  for (index in seq_along(widths)) {
    width <- widths[index]
    phase <- first + (index - 1) * offset * plank_l
    start <- fmod(fmod(phase, plank_l) + plank_l, plank_l)
    if (start < EPS || plank_l - start < EPS) start <- plank_l
    row_id <- paste0("R", padded(index, 2))
    pos <- 0.0
    while (pos < run - EPS) {
      if (length(pieces) >= MAX_PIECES) input_error("This field exceeds 2,500 placed planks.", "roomW")
      proposed <- if (pos == 0.0) start else plank_l
      len <- min(proposed, run - pos)
      at_start <- pos < EPS
      at_end <- pos + len >= run - EPS
      role <- if (len >= plank_l - EPS) {
        "full"
      } else if (at_start && at_end) {
        "isolated"
      } else if (at_start) {
        "start"
      } else {
        "end"
      }
      pieces[[length(pieces) + 1]] <- list(
        id = paste0("P", padded(length(pieces) + 1, 3)), row = row_id, length = len, width = width, role = role,
        cut = len < plank_l - EPS || width < plank_w - EPS
      )
      pos <- pos + len
    }
    rows[[index]] <- list(id = row_id, width = width, across = across)
    across <- across + width
  }
  list(rows = rows, pieces = pieces, sources = pair_cuts(pieces, plank_l))
}
