# Sod by area: staggered layout of rectangles with offcut reuse, areas by square
# footage with an allowance, plugs (UF/IFAS Table 3), soil preparation, pallets,
# cost and weight.
# Calculator page: https://calculiva.com/landscaping/sod-calculator/

SOD_YARD <- 3.0 * FOOT
SOD_SQYD <- SOD_YARD * SOD_YARD
SOD_CUYD <- SOD_YARD * SOD_YARD * SOD_YARD
SOD_RECT_MAX <- 300.0 * FOOT
SOD_PIECE_W_MIN <- 4.0 * INCH
SOD_PIECE_W_MAX <- 48.0 * INCH
SOD_PIECE_L_MIN <- 12.0 * INCH
SOD_PIECE_L_MAX <- 120.0 * INCH

format_row <- function(id, name, widthIn, lengthIn, statedSqFt, palletsStatedSqFt = NULL, piecesPerPallet = NULL,
                       palletsSoldAsSqFt = NULL) {
  list(id = id, name = name, widthIn = widthIn, lengthIn = lengthIn, statedSqFt = statedSqFt,
       palletsStatedSqFt = palletsStatedSqFt, piecesPerPallet = piecesPerPallet, palletsSoldAsSqFt = palletsSoldAsSqFt)
}

# The four surveyed sod formats.
# Data sheet sod-format-observations (formats), source
# https://sodsolutions.com/sod-university/square-feet-per-pallet/, verified 2026-09-25,
# market survey expiring 2027-03-25.
SOD_FORMATS <- list(
  format_row("slab-16x24", "Slab, 16 \u00d7 24 in", 16.0, 24.0, 2.66,
             palletsStatedSqFt = c(399.0, 452.0, 503.0), palletsSoldAsSqFt = c(400.0, 450.0, 500.0)),
  format_row("mini-roll-18x40", "Mini hand roll, 18 \u00d7 40 in", 18.0, 40.0, 5.0,
             piecesPerPallet = c(80.0, 90.0, 100.0), palletsSoldAsSqFt = c(400.0, 450.0, 500.0)),
  format_row("roll-24x60", "Roll, 24 \u00d7 60 in", 24.0, 60.0, 10.0),
  format_row("roll-18x80", "Roll, 18 \u00d7 80 in", 18.0, 80.0, 10.0)
)

# The slabs on the three stated slab pallets (399, 452 and 503 sq ft at 2.66 sq ft).
# Data sheet sod-format-observations (derived.slab_pieces_per_stated_pallet), source
# https://sodsolutions.com/sod-university/square-feet-per-pallet/, verified 2026-09-25,
# market survey expiring 2027-03-25.
SLAB_PIECES_PER_STATED_PALLET <- c(150.0, 170.0, 189.0)

# The weight of one pallet of sod, pounds (a range).
# Data sheet sod-format-observations (source sodsolutions,
# https://sodsolutions.com/sod-university/square-feet-per-pallet/), verified 2026-09-25,
# market survey expiring 2027-03-25.
PALLET_WEIGHT_LB <- c(1500.0, 3000.0)

# Data sheet sod-installation-guidance (publisher psu), source
# https://extension.psu.edu/lawn-establishment/, verified 2026-09-25.
# Settled topsoil under new sod, inches.
PSU_TOPSOIL_SETTLED_IN <- c(4.0, 6.0)
# Organic matter layer to incorporate, inches.
PSU_ORGANIC_LAYER_IN <- c(1.0, 2.0)
# Thickest organic layer to incorporate in a single pass, inches.
PSU_ORGANIC_LAYER_MAX_SINGLE_PASS_IN <- 2.0

# The organic matter rate, cubic yards per 1,000 sq ft (NC State).
# Data sheet sod-installation-guidance (publisher ncsu, https://content.ces.ncsu.edu/carolina-lawns),
# sheet source https://extension.psu.edu/lawn-establishment/, verified 2026-09-25.
NCSU_ORGANIC_CUYD_PER_1000_SQFT <- c(1.0, 2.0)

planting_row <- function(species, method, spacingIn, sodSqFtPer1000) {
  list(species = species, method = method, spacingIn = spacingIn, sodSqFtPer1000 = sodSqFtPer1000)
}

# UF/IFAS LH013 Table 3: plugs and sprigs by species.
# Data sheet sod-plugging-ifas (table3), source https://ask.ifas.ufl.edu/publication/LH013,
# verified 2026-09-25.
IFAS_TABLE3 <- list(
  planting_row("St. Augustinegrass", "2-inch plugs", 12.0, c(30.0, 50.0)),
  planting_row("St. Augustinegrass", "sprigs", 12.0, c(10.0, 15.0)),
  planting_row("Centipedegrass", "2-inch plugs", 6.0, c(100.0, 150.0)),
  planting_row("Centipedegrass", "sprigs", 6.0, c(30.0, 50.0)),
  planting_row("Zoysiagrass", "2-inch plugs", 6.0, c(100.0, 150.0)),
  planting_row("Zoysiagrass", "sprigs", 6.0, c(8.0, 15.0)),
  planting_row("Bermudagrass", "2-inch plugs", 12.0, c(30.0, 50.0)),
  planting_row("Bermudagrass", "sprigs", 12.0, c(2.0, 5.0))
)

# The number of two-inch plugs cut from one square yard of sod.
# Data sheet sod-plugging-ifas (conversions.two_inch_plugs_per_sqyd), source
# https://ask.ifas.ufl.edu/publication/LH013, verified 2026-09-25.
TWO_INCH_PLUGS_PER_SQYD <- 324.0

# The plug sizes offered, inches: UF/IFAS LH013 "2-to-4-inch" plugs.
# Data sheet sod-plugging-ifas, source https://ask.ifas.ufl.edu/publication/LH013, verified 2026-09-25.
PLUG_SIZES_IN <- c(2.0, 3.0, 4.0)

#' @export
sod_constants <- function() {
  list(sqFt = SOIL_SQFT, sqYd = SOD_SQYD, cuFt = SOIL_CUFT, cuYd = SOD_CUYD, formats = SOD_FORMATS,
       slabPiecesPerStatedPallet = SLAB_PIECES_PER_STATED_PALLET, palletWeightLb = PALLET_WEIGHT_LB,
       psuTopsoilSettledIn = PSU_TOPSOIL_SETTLED_IN, psuOrganicLayerIn = PSU_ORGANIC_LAYER_IN,
       psuOrganicLayerMaxSinglePassIn = PSU_ORGANIC_LAYER_MAX_SINGLE_PASS_IN,
       ncsuOrganicCuYdPer1000SqFt = NCSU_ORGANIC_CUYD_PER_1000_SQFT, ifasTable3 = IFAS_TABLE3,
       twoInchPlugsPerSqYd = TWO_INCH_PLUGS_PER_SQYD, plugSizesIn = PLUG_SIZES_IN)
}

sod_slug <- function(s) {
  out <- ""
  dash <- FALSE
  for (ch in strsplit(tolower(s), "")[[1]]) {
    if (grepl("^[a-z0-9]$", ch)) {
      if (dash && nchar(out) > 0) out <- paste0(out, "-")
      dash <- FALSE
      out <- paste0(out, ch)
    } else {
      dash <- TRUE
    }
  }
  out
}

leading_number <- function(s) {
  head <- regmatches(s, regexpr("^[0-9.]*", s))
  v <- suppressWarnings(as.numeric(head))
  if (length(v) == 0 || is.na(v)) NaN else v
}

#' @export
sod_new_rules <- function() {
  formats <- lapply(SOD_FORMATS, function(f) {
    list(id = f$id, name = f$name, widthMM = f$widthIn * INCH, lengthMM = f$lengthIn * INCH, statedSqFt = f$statedSqFt,
         palletPieces = if (!is.null(f$palletsStatedSqFt)) SLAB_PIECES_PER_STATED_PALLET else f$piecesPerPallet,
         palletSqFt = nz(f$palletsStatedSqFt, f$palletsSoldAsSqFt),
         soldAsSqFt = f$palletsSoldAsSqFt)
  })
  species <- list()
  for (r in IFAS_TABLE3) {
    if (!grepl("plug", r$method, fixed = TRUE)) next
    species[[length(species) + 1]] <- list(id = sod_slug(r$species), species = r$species, spacingMM = r$spacingIn * INCH,
                                           plugIn = leading_number(r$method), sodSqFtPer1000 = r$sodSqFtPer1000)
  }
  list(formats = formats, allowance = 0.0, allowanceComplex = 0.0, palletLb = PALLET_WEIGHT_LB,
       topsoilMM = PSU_TOPSOIL_SETTLED_IN * INCH, organicLayerMM = PSU_ORGANIC_LAYER_IN * INCH,
       organicLayerMaxMM = PSU_ORGANIC_LAYER_MAX_SINGLE_PASS_IN * INCH, organicRate = NCSU_ORGANIC_CUYD_PER_1000_SQFT,
       species = species, plugsPerSqYd2In = TWO_INCH_PLUGS_PER_SQYD, plugSizes = PLUG_SIZES_IN)
}

#' @export
sod_lay_rect <- function(l, w, piece_w, piece_l) {
  fp <- staggered(l, w, piece_w, piece_l, 0.5, SOD_RECT_MAX, SOD_PIECE_W_MAX)
  ids <- vapply(fp$pieces, function(p) p$id, character(1))
  index <- function(id) match(id, ids)
  n_pieces <- length(fp$pieces)
  buy <- rep("", n_pieces)
  shared <- rep(FALSE, n_pieces)
  groups <- list()
  kept <- 0
  for (s in fp$sources) {
    i <- index(s$pieces[[1]])
    p <- fp$pieces[[i]]
    if (!s$pair && p$role == "full" && p$width < piece_w - EPS) {
      k <- sprintf("%.3f", p$width)
      found <- FALSE
      for (g in seq_along(groups)) {
        if (groups[[g]]$key == k) {
          groups[[g]]$ids <- c(groups[[g]]$ids, i)
          found <- TRUE
          break
        }
      }
      if (!found) groups[[length(groups) + 1]] <- list(key = k, width = p$width, ids = i)
      next
    }
    kept <- kept + 1
    for (id in s$pieces) {
      j <- index(id)
      buy[j] <- s$id
      shared[j] <- s$pair
    }
  }
  strips <- 0
  strip_bought <- 0
  n <- 0
  for (g in groups) {
    per <- as.integer(max(floor_rel(piece_w / g$width), 1.0))
    bought <- as.integer(ceil_rel(length(g$ids) / per))
    strips <- strips + length(g$ids)
    strip_bought <- strip_bought + bought
    for (k in seq_along(g$ids)) {
      i <- g$ids[k]
      buy[i] <- paste0("S", padded(n + (k - 1) %/% per + 1, 3))
      shared[i] <- per > 1 && length(g$ids) > 1
    }
    n <- n + bought
  }
  pieces <- lapply(seq_len(n_pieces), function(i) {
    p <- fp$pieces[[i]]
    list(id = p$id, row = p$row, length = p$length, width = p$width, role = p$role, cut = p$cut,
         buy = buy[i], shared = shared[i])
  })
  cut <- sum(vapply(fp$pieces, function(p) p$cut, logical(1)))
  pairs <- sum(vapply(fp$sources, function(s) s$pair, logical(1)))
  list(pieces = pieces, rows = fp$rows, installed = n_pieces, cut = cut, full = n_pieces - cut,
       pairs = pairs, strips = strips, stripBought = strip_bought, bought = kept + strip_bought)
}

SOD_INPUT_ZERO <- list(format = "", pieceW = 0, pieceL = 0, palletMode = "pieces", palletPieces = 0, palletSqFt = 0,
                       allowance = 0, spare = 0, method = "solid", species = "", spacing = 0, plugSize = 0, topsoil = 0,
                       organic = "layer", organicIn = 0, organicRate = 0, priceMode = "perPallet", price = 0,
                       delivery = 0, payload = 0)

#' @export
sod_new_input <- function(areas = list(), rules = sod_new_rules()) {
  sp <- rules$species[[1]]
  x <- SOD_INPUT_ZERO
  x$format <- rules$formats[[1]]$id
  x$allowance <- rules$allowance
  x$species <- sp$id
  x$spacing <- sp$spacingMM
  x$plugSize <- sp$plugIn
  x$topsoil <- rules$topsoilMM[1]
  x$organicIn <- rules$organicLayerMM[1]
  x$organicRate <- rules$organicRate[1]
  c(list(areas = areas), x)
}

sod_warning <- function(kind, area = "", species = "", spacing = 0.0, tableMM = 0.0, layer = 0.0, maxMM = 0.0,
                        rate = 0.0, range = c(0.0, 0.0), topsoil = 0.0, minMM = 0.0) {
  list(kind = kind, area = area, species = species, spacing = spacing, tableMM = tableMM, layer = layer, maxMM = maxMM,
       rate = rate, range = range, topsoil = topsoil, minMM = minMM)
}

tidy <- function(x) if (abs(x) < 1e-9) 0.0 else x

#' @export
sod_new_plan <- function(input, rules = sod_new_rules()) {
  x <- with_defaults(input, SOD_INPUT_ZERO)
  if (length(x$areas) == 0 || length(x$areas) > 8) input_error("Tick one to eight areas.", "areas")
  # Format: one of the surveyed formats, or a piece entered by hand.
  fmt <- NULL
  for (f in rules$formats) if (f$id == x$format) { fmt <- f; break }
  if (!is.null(fmt)) {
    piece_w <- fmt$widthMM
    piece_l <- fmt$lengthMM
  } else {
    if (x$format != "custom") input_error("Choose a sod format.", "format")
    check_range(x$pieceW, SOD_PIECE_W_MIN, SOD_PIECE_W_MAX, "Enter a piece width from 4 to 48 in (102 to 1,219 mm).", "piece-w")
    check_range(x$pieceL, SOD_PIECE_L_MIN, SOD_PIECE_L_MAX, "Enter a piece length from 12 to 120 in (305 to 3,048 mm).", "piece-l")
    piece_w <- x$pieceW
    piece_l <- x$pieceL
  }
  piece_mm2 <- piece_w * piece_l
  piece_sqft <- piece_mm2 / SOIL_SQFT
  if (x$palletMode == "sqFt") {
    check_range(x$palletSqFt, 50.0, 2000.0, "Enter a pallet coverage from 50 to 2,000 sq ft.", "pallet-sqft")
    per_pallet <- floor_rel(x$palletSqFt / piece_sqft)
    if (per_pallet < 1.0) input_error("The pallet holds less than one piece of this size.", "pallet-sqft")
  } else {
    if (!is_whole(x$palletPieces) || x$palletPieces < 1.0 || x$palletPieces > 2000.0) {
      input_error("Enter a whole number of pieces per pallet from 1 to 2,000.", "pallet-pieces")
    }
    per_pallet <- x$palletPieces
  }
  check_range(x$allowance, 0.0, 30.0, "Enter an allowance from 0 to 30 %.", "allowance")
  check_range(x$spare, 0.0, 30.0, "Enter a spare from 0 to 30 %.", "spare")
  plugs <- x$method == "plugs"
  warnings <- list()
  areas <- list()
  for (a in x$areas) {
    f <- function(k) paste0(a$id, "-", k)
    len <- function(v, k, label, mx) {
      msg <- paste0("Enter ", label, " from 1 to ", shortest(mx / FOOT), " ft (0.3 to ", locale(mx / 1000.0, 1), " m).")
      check_range(v, FOOT, mx, msg, f(k))
    }
    copies <- function(n) {
      if (!is_whole(n) || !(n >= 1.0 && n <= 20.0)) input_error("Enter a whole number of copies from 1 to 20.", f("count"))
    }
    s <- a$shape
    type <- nz(s$type, "")
    count <- 1.0
    layout <- NULL
    no_layout <- FALSE
    if (type == "rect") {
      copies(s$count)
      count <- s$count
      len(s$l, "l", "a length", SOD_RECT_MAX)
      len(s$w, "w", "a width", SOD_RECT_MAX)
      # Beyond 2,500 placed pieces, the drawing gives way to a count by area.
      if (!plugs) {
        if (ceil_rel(s$l / piece_l + 1.0) * ceil_rel(s$w / piece_w) > MAX_PIECES) {
          no_layout <- TRUE
          warnings[[length(warnings) + 1]] <- sod_warning("no-layout", area = a$id)
        } else {
          layout <- sod_lay_rect(s$l, s$w, piece_w, piece_l)
        }
      }
      area_mm2 <- s$l * s$w
    } else if (type == "circle") {
      copies(s$count)
      count <- s$count
      len(s$r, "r", "a radius", 150.0 * FOOT)
      area_mm2 <- pi * s$r * s$r
    } else if (type == "triangle") {
      copies(s$count)
      count <- s$count
      len(s$b, "b", "a base", SOD_RECT_MAX)
      len(s$h, "h", "a height", SOD_RECT_MAX)
      area_mm2 <- s$b * s$h / 2.0
    } else if (type == "knownArea") {
      check_range(s$area, 0.1 * SQ_M, 10000.0 * SQ_M,
                  "Enter an area from 0.1 to 10,000 m\u00b2 (about 1.1 to 107,639 sq ft).", f("area"))
      area_mm2 <- s$area
    } else {
      input_error("Choose a shape.", f("shape"))
    }
    sqft <- area_mm2 * count / SOIL_SQFT
    plan <- list(id = a$id, count = count, areaMM2 = area_mm2, sqFt = sqft, mode = "plugs", layout = NULL,
                 bought = 0.0, extraPct = NULL)
    if (plugs) {
      # counted over the whole lawn below
    } else if (!is.null(layout)) {
      b <- layout$bought
      plan$mode <- "layout"
      plan$bought <- b * count
      plan$extraPct <- tidy((b * piece_mm2 - area_mm2) / area_mm2 * 100.0)
      plan$layout <- layout
    } else {
      bought <- ceil_rel(sqft * (1.0 + x$allowance / 100.0) / piece_sqft)
      plan$mode <- if (no_layout) "noLayout" else "area"
      plan$bought <- bought
      plan$extraPct <- tidy((bought * piece_sqft - sqft) / sqft * 100.0)
    }
    areas[[length(areas) + 1]] <- plan
  }
  lawn_mm2 <- 0.0
  layout_bought <- 0.0
  area_bought <- 0.0
  for (a in areas) {
    lawn_mm2 <- lawn_mm2 + a$areaMM2 * a$count
    if (a$mode == "layout") layout_bought <- layout_bought + a$bought
    if (a$mode %in% c("area", "noLayout")) area_bought <- area_bought + a$bought
  }
  lawn_sqft <- lawn_mm2 / SOIL_SQFT
  spare <- if (plugs) 0.0 else ceil_rel(layout_bought * x$spare / 100.0)
  flat <- ceil_rel(lawn_sqft * (1.0 + rules$allowance / 100.0) / piece_sqft)
  plug <- NULL
  if (plugs) {
    sp <- NULL
    if (x$species != "custom") {
      for (r in rules$species) if (r$id == x$species) { sp <- r; break }
      if (is.null(sp)) input_error("Choose a grass species.", "species")
    }
    check_range(x$spacing, 4.0 * INCH, 24.0 * INCH, "Enter a plug spacing from 4 to 24 in (102 to 610 mm).", "spacing")
    if (!(x$plugSize %in% rules$plugSizes)) input_error("Choose a 2, 3 or 4 in plug.", "plug-size")
    plug_mm <- x$plugSize * INCH
    n <- ceil_rel(lawn_mm2 / (x$spacing * x$spacing))
    sod_sqft <- n * plug_mm * plug_mm / SOIL_SQFT
    table_sqft <- NULL
    table_pieces <- NULL
    if (!is.null(sp) && x$plugSize == sp$plugIn) {
      table_sqft <- c(sp$sodSqFtPer1000[1] * lawn_sqft / 1000.0, sp$sodSqFtPer1000[2] * lawn_sqft / 1000.0)
      table_pieces <- c(ceil_rel(table_sqft[1] / piece_sqft), ceil_rel(table_sqft[2] / piece_sqft))
    }
    if (!is.null(sp) && abs(x$spacing - sp$spacingMM) > EPS) {
      warnings[[length(warnings) + 1]] <- sod_warning("spacing", species = sp$species, spacing = x$spacing, tableMM = sp$spacingMM)
    }
    plug <- list(species = sp, count = n, sodSqFt = sod_sqft, sodSqYd = sod_sqft * SOIL_SQFT / SOD_SQYD,
                 perSqYd = SOD_SQYD / (plug_mm * plug_mm), pieces = ceil_rel(sod_sqft / piece_sqft),
                 tableSqFt = table_sqft, tablePieces = table_pieces)
  }
  pieces <- layout_bought + area_bought + spare
  if (!is.null(plug)) pieces <- plug$pieces
  full <- floor_rel(pieces / per_pallet)
  loose <- pieces - full * per_pallet
  pallets_up <- ceil_rel(pieces / per_pallet)
  leftover <- pallets_up * per_pallet - pieces
  # Soil preparation over the whole lawn: topsoil (Penn State), organic matter as a layer
  # (Penn State) or as a rate per 1,000 sq ft (NC State), with the other publisher's equivalent.
  check_range(x$topsoil, 0.0, 12.0 * INCH, "Enter a topsoil depth from 0 to 12 in (0 to 305 mm).", "topsoil")
  organic_mm3 <- 0.0
  eq_rate <- NULL
  eq_layer <- NULL
  if (x$organic == "layer") {
    check_range(x$organicIn, 0.0, 4.0 * INCH, "Enter an organic layer from 0 to 4 in (0 to 102 mm).", "organic-in")
    organic_mm3 <- lawn_mm2 * x$organicIn
    eq_rate <- organic_mm3 / SOD_CUYD / (lawn_sqft / 1000.0)
    if (x$organicIn > rules$organicLayerMaxMM + EPS) {
      warnings[[length(warnings) + 1]] <- sod_warning("organic-thick", layer = x$organicIn, maxMM = rules$organicLayerMaxMM)
    }
  } else if (x$organic == "rate") {
    check_range(x$organicRate, 0.0, 4.0, "Enter a rate from 0 to 4 cu yd per 1,000 sq ft.", "organic-rate")
    organic_mm3 <- x$organicRate * lawn_sqft / 1000.0 * SOD_CUYD
    eq_layer <- organic_mm3 / lawn_mm2
    lo <- rules$organicRate[1]
    hi <- rules$organicRate[2]
    if (x$organicRate < lo - EPS || x$organicRate > hi + EPS) {
      warnings[[length(warnings) + 1]] <- sod_warning("rate-outside", rate = x$organicRate, range = rules$organicRate)
    }
  }
  if (x$topsoil > EPS && x$topsoil < rules$topsoilMM[1] - EPS) {
    warnings[[length(warnings) + 1]] <- sod_warning("topsoil-thin", topsoil = x$topsoil, minMM = rules$topsoilMM[1])
  }
  topsoil_mm3 <- lawn_mm2 * x$topsoil
  prep <- list(topsoilMM3 = topsoil_mm3, topsoilCuFt = topsoil_mm3 / SOIL_CUFT, topsoilCuYd = topsoil_mm3 / SOD_CUYD,
               organicMM3 = organic_mm3, organicCuFt = organic_mm3 / SOIL_CUFT, organicCuYd = organic_mm3 / SOD_CUYD,
               equivalentRate = eq_rate, equivalentLayerMM = eq_layer)
  # Cost: whole pallets, or full pallets plus loose pieces when priced per piece or per sq ft.
  check_range(x$price, 0.0, 10000.0, "Enter a price from 0 to 10,000 USD.", "price")
  check_range(x$delivery, 0.0, 10000.0, "Enter a delivery charge from 0 to 10,000 USD.", "delivery")
  per_piece <- NULL
  whole <- NULL
  mixed <- NULL
  if (x$priceMode == "perPiece") per_piece <- x$price
  if (x$priceMode == "perSqFt") per_piece <- x$price * piece_sqft
  if (x$price != 0) {
    if (is.null(per_piece)) {
      whole <- pallets_up * x$price + x$delivery
    } else {
      whole <- pallets_up * per_pallet * per_piece + x$delivery
      mixed <- pieces * per_piece + x$delivery
    }
  }
  # Weight: a range per pallet, never a single number.
  if (x$payload != 0) check_range(x$payload, 100.0, 10000.0, "Enter a payload from 100 to 10,000 lb, or 0.", "payload")
  weight_lb <- c(rules$palletLb[1] * pallets_up, rules$palletLb[2] * pallets_up)
  trips <- if (x$payload != 0) c(ceil_rel(weight_lb[1] / x$payload), ceil_rel(weight_lb[2] / x$payload)) else NULL
  list(
    pieceW = piece_w, pieceL = piece_l, pieceMM2 = piece_mm2, pieceSqFt = piece_sqft, perPallet = per_pallet,
    areas = areas,
    totals = list(areaMM2 = lawn_mm2, sqFt = lawn_sqft, layoutBought = layout_bought, areaBought = area_bought,
                  spare = spare, pieces = pieces, flat = flat),
    pallets = list(perPallet = per_pallet, full = full, loose = loose, palletsUp = pallets_up, leftover = leftover),
    plug = plug, prep = prep, cost = list(perPiece = per_piece, whole = whole, mixed = mixed),
    weightLb = weight_lb, trips = trips, warnings = warnings
  )
}

#' @export
sod_format_table <- function(sold_as, sqft, rules = sod_new_rules()) {
  sold <- num(sold_as)
  lapply(rules$formats, function(f) {
    s <- f$widthMM * f$lengthMM / SOIL_SQFT
    list(format = f, sqFt = s, perPallet = vapply(sold, function(v) ceil_rel(v / s), numeric(1)), forLawn = ceil_rel(sqft / s))
  })
}
