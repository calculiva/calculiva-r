# Topsoil and fill dirt by area: volume, bags, bulk, weight and hauling.
# Calculator page: https://calculiva.com/landscaping/soil-calculator/

SOIL_SQFT <- FOOT * FOOT
SOIL_CUFT <- SOIL_SQFT * FOOT
CU_IN <- INCH * INCH * INCH
LITRE <- 1e6
SQ_M <- 1e6

# The number of pounds in a short ton.
# Data sheet soil-weights-and-sale-units (physical_basis.pounds_per_short_ton),
# source https://www.nist.gov/document/2026-hb-130-section-iv-b, verified 2026-09-25.
POUNDS_PER_SHORT_TON <- 2000.0

# The number of cubic feet in a cubic yard.
# Data sheet soil-weights-and-sale-units (physical_basis.cubic_feet_per_cubic_yard),
# source https://www.nist.gov/document/2026-hb-130-section-iv-b, verified 2026-09-25.
CUBIC_FEET_PER_CUBIC_YARD <- 27.0

# The number of cubic inches in a U.S. dry quart (1/32 of the 2,150.42 in3 bushel).
# Data sheet soil-weights-and-sale-units (sale_units.dry_measure.dry_quart_in3),
# source https://www.nist.gov/document/2026-hb-130-section-iv-b
# (NIST Handbook 130, IV-A: https://www.nist.gov/document/2026-hb-130-section-iv), verified 2026-09-25.
DRY_QUART_IN3 <- 67.200625

#' @export
calculiva_units <- function() list(inch = INCH, foot = FOOT)

#' @export
soil_constants <- function() {
  list(poundsPerShortTon = POUNDS_PER_SHORT_TON, cubicFeetPerCubicYard = CUBIC_FEET_PER_CUBIC_YARD,
       dryQuartIn3 = DRY_QUART_IN3, sqFt = SOIL_SQFT, cuFt = SOIL_CUFT)
}

#' @export
soil_new_rules <- function(weights = list()) {
  list(poundsPerTon = POUNDS_PER_SHORT_TON, cuFtPerCuYd = CUBIC_FEET_PER_CUBIC_YARD,
       dryQuartIn3 = DRY_QUART_IN3, weights = weights)
}

soil_weight <- function(rules, id) {
  for (w in rules$weights) if (identical(w$id, id)) return(w)
  NULL
}

#' @export
soil_area_of <- function(id, shape) {
  f <- function(k) paste0(id, "-", k)
  len <- function(v, k, label) check_range(v, LEN_MIN, LEN_MAX, paste0("Enter ", label, LEN_MSG), f(k))
  type <- nz(shape$type, "")
  if (type == "rect") {
    len(shape$l, "l", "a length")
    len(shape$w, "w", "a width")
    return(shape$l * shape$w)
  }
  if (type == "circle") {
    len(shape$d, "d", "a diameter")
    return(pi * shape$d * shape$d / 4.0)
  }
  if (type == "triangle") {
    len(shape$b, "b", "a base")
    len(shape$h, "h", "a height")
    return(shape$b * shape$h / 2.0)
  }
  if (type == "knownArea") {
    check_range(shape$area, 0.1 * SQ_M, 10000.0 * SQ_M,
                "Enter an area from 0.1 to 10,000 m\u00b2 (about 1.1 to 107,639 sq ft).", f("area"))
    return(shape$area)
  }
  input_error("Choose a shape.", f("shape"))
}

bag_bounds <- function(unit) {
  if (unit == "dryQuarts") return(list(lo = 1.0, hi = 400.0, name = "dry quarts"))
  if (unit == "liters") return(list(lo = 1.0, hi = 300.0, name = "liters"))
  list(lo = 0.05, hi = 10.0, name = "cu ft")
}

#' @export
soil_bag_cu_ft <- function(size, unit, dry_quart_in3) {
  if (unit == "dryQuarts") return(size * dry_quart_in3 * CU_IN / SOIL_CUFT)
  if (unit == "liters") return(size * LITRE / SOIL_CUFT)
  size
}

SOIL_INPUT_DEFAULTS <- list(bulkBy = "yard", delivery = 0, increment = 0, extra = 0, payload = 0,
                            bedVolume = 0, wheelbarrow = 0)
MATERIAL_DEFAULTS <- list(bagSize = 0, bagUnit = "cuFt", bagPrice = 0, bulkPrice = 0, weight = "")

#' @export
soil_new_plan <- function(input, rules) {
  x <- with_defaults(input, SOIL_INPUT_DEFAULTS)
  if (length(x$areas) == 0 || length(x$areas) > 8) input_error("Enter one to eight areas.", "areas")
  check_range(x$delivery, 0.0, 10000.0, "Enter a delivery charge from 0 to 10,000 USD.", "delivery")
  if (x$increment != 0) check_range(x$increment, 0.1, 10.0, "Enter a sale increment from 0.1 to 10 cu yd, or 0.", "increment")
  check_range(x$extra, 0.0, 100.0, "Enter an extra from 0 to 100 %.", "extra")
  if (x$payload != 0) check_range(x$payload, 100.0, 20000.0, "Enter a payload from 100 to 20,000 lb, or 0.", "payload")
  if (x$bedVolume != 0) check_range(x$bedVolume, 1.0, 200.0, "Enter a bed volume from 1 to 200 cu ft, or 0.", "bed-volume")
  if (x$wheelbarrow != 0) check_range(x$wheelbarrow, 1.0, 20.0, "Enter a wheelbarrow volume from 1 to 20 cu ft, or 0.", "wheelbarrow")
  per_yd <- rules$cuFtPerCuYd
  lb_ton <- rules$poundsPerTon
  areas <- list()
  for (a in x$areas) {
    a <- with_defaults(a, list(count = 1, material = "topsoil"))
    area_mm2 <- soil_area_of(a$id, a$shape)
    check_range(a$depth, 3.0, 1500.0, "Enter a depth from 1/8 in to 59 in (3 to 1,500 mm).", paste0(a$id, "-depth"))
    if (!is_whole(a$count) || a$count < 1.0 || a$count > 100.0) {
      input_error("Enter a whole number of copies from 1 to 100.", paste0(a$id, "-count"))
    }
    volume <- area_mm2 * a$depth * a$count
    areas[[length(areas) + 1]] <- list(
      id = a$id, material = a$material, count = a$count, depth = a$depth, areaMM2 = area_mm2,
      sqFt = area_mm2 / SOIL_SQFT, volume = volume, cuFt = volume / SOIL_CUFT, cuYd = volume / SOIL_CUFT / per_yd
    )
  }
  materials <- list()
  for (mid in c("topsoil", "fill")) {
    if (!any(vapply(areas, function(a) a$material == mid, logical(1)))) next
    f <- function(k) paste0(mid, "-", k)
    if (is.null(x[[mid]])) input_error("Enter the bag and bulk details of this material.", f("bag"))
    m <- with_defaults(x[[mid]], MATERIAL_DEFAULTS)
    if (m$bagSize != 0) {
      b <- bag_bounds(m$bagUnit)
      check_range(m$bagSize, b$lo, b$hi, paste0("Enter a bag size from ", js_num(b$lo), " to ", js_num(b$hi), " ", b$name, ", or 0."), f("bag"))
    }
    check_range(m$bagPrice, 0.0, 100000.0, "Enter a bag price from 0 to 100,000 USD.", f("bag-price"))
    check_range(m$bulkPrice, 0.0, 100000.0, "Enter a bulk price from 0 to 100,000 USD.", f("bulk-price"))
    w <- soil_weight(rules, m$weight)
    if (is.null(w)) input_error("Choose a material weight.", f("weight"))
    volume <- 0.0
    for (a in areas) if (a$material == mid) volume <- volume + a$volume
    cuft <- volume / SOIL_CUFT
    cuyd <- cuft / per_yd
    ordered_cuft <- cuft * (1.0 + x$extra / 100.0)
    ordered_cuyd <- ordered_cuft / per_yd
    ordered_volume <- ordered_cuft * SOIL_CUFT
    # Bags are whole; bulk rounds up to the supplier's sale increment, never down.
    bc <- NULL
    bags <- NULL
    bag_cost <- NULL
    if (m$bagSize != 0) {
      bc <- soil_bag_cu_ft(m$bagSize, m$bagUnit, rules$dryQuartIn3)
      bags <- ceil_rel(ordered_cuft / bc)
      if (m$bagPrice != 0) bag_cost <- bags * m$bagPrice
    }
    bulk_cuyd <- ordered_cuyd
    if (x$increment != 0) bulk_cuyd <- ceil_rel(ordered_cuyd / x$increment) * x$increment
    bulk_surplus <- (bulk_cuyd - ordered_cuyd) * per_yd
    loose_lb <- bulk_cuyd * w$loose
    bulk_tons <- loose_lb / lb_ton
    bulk_cost <- NULL
    if (m$bulkPrice != 0) {
      bulk_cost <- if (x$bulkBy == "yard") bulk_cuyd * m$bulkPrice + x$delivery else bulk_tons * m$bulkPrice + x$delivery
    }
    cheaper <- NULL
    if (!is.null(bag_cost) && !is.null(bulk_cost)) cheaper <- if (bag_cost <= bulk_cost) "bags" else "bulk"
    # Continuous break-even: the volume where bulk with delivery equals bags, unrounded.
    bag_per <- NULL
    bulk_per <- NULL
    break_even <- NULL
    if (!is.null(bc) && bc != 0 && m$bagPrice != 0) bag_per <- m$bagPrice / bc
    if (m$bulkPrice != 0) {
      bulk_per <- if (x$bulkBy == "yard") m$bulkPrice / per_yd else m$bulkPrice * w$loose / lb_ton / per_yd
    }
    if (!is.null(bag_per) && !is.null(bulk_per) && bag_per > bulk_per) break_even <- x$delivery / (bag_per - bulk_per)
    # Hauling: weight is read on the unrounded order (what one loads oneself).
    ordered_loose <- ordered_cuyd * w$loose
    bank_lb <- ordered_cuyd * w$bank
    settled <- ordered_cuft * w$loadFactor
    by_w <- NULL
    by_v <- NULL
    if (x$payload != 0) by_w <- ceil_rel(ordered_loose / x$payload)
    if (x$bedVolume != 0) by_v <- ceil_rel(ordered_cuft / x$bedVolume)
    trips <- NULL
    binding <- NULL
    if (!is.null(by_w) && !is.null(by_v)) {
      trips <- max(by_w, by_v)
      binding <- if (by_w > by_v) "weight" else if (by_v > by_w) "volume" else "both"
    } else if (!is.null(by_w)) {
      trips <- by_w
      binding <- "weight"
    } else if (!is.null(by_v)) {
      trips <- by_v
      binding <- "volume"
    }
    loads <- NULL
    lb_per_load <- NULL
    if (x$wheelbarrow != 0) {
      loads <- ceil_rel(ordered_cuft / x$wheelbarrow)
      lb_per_load <- x$wheelbarrow / per_yd * w$loose
    }
    materials[[length(materials) + 1]] <- list(
      id = mid, weight = w, volume = volume, cuFt = cuft, cuYd = cuyd,
      orderedCuFt = ordered_cuft, orderedCuYd = ordered_cuyd, orderedVolume = ordered_volume,
      bagCuFt = bc, bags = bags, bagCost = bag_cost, bulkCuYd = bulk_cuyd,
      bulkVolume = bulk_cuyd * per_yd * SOIL_CUFT, bulkSurplusCuFt = bulk_surplus, looseLb = loose_lb,
      bulkTons = bulk_tons, bulkCost = bulk_cost, cheaper = cheaper, bagPerCuFt = bag_per,
      bulkPerCuFt = bulk_per, breakEvenCuFt = break_even, orderedLooseLb = ordered_loose,
      bankLb = bank_lb, settledCuFt = settled, tripsByWeight = by_w, tripsByVolume = by_v,
      trips = trips, binding = binding, wheelbarrowLoads = loads, lbPerLoad = lb_per_load
    )
  }
  keys <- c("volume", "cuFt", "cuYd", "orderedCuFt", "orderedCuYd", "orderedVolume", "bulkCuYd", "looseLb")
  totals <- as.list(rep(0.0, length(keys)))
  names(totals) <- keys
  with_trips <- FALSE
  trips <- 0.0
  loads <- 0.0
  for (m in materials) {
    for (k in keys) totals[[k]] <- totals[[k]] + m[[k]]
    if (!is.null(m$trips)) {
      with_trips <- TRUE
      trips <- trips + m$trips
    }
    if (!is.null(m$wheelbarrowLoads)) loads <- loads + m$wheelbarrowLoads
  }
  totals["trips"] <- list(if (with_trips) trips else NULL)
  totals["wheelbarrowLoads"] <- list(if (x$wheelbarrow != 0) loads else NULL)
  warnings <- list()
  for (m in materials) {
    if (x$increment != 0 && m$bulkSurplusCuFt > EPS) {
      warnings[[length(warnings) + 1]] <- list(material = m$id, surplusCuFt = m$bulkSurplusCuFt)
    }
  }
  list(areas = areas, materials = materials, totals = totals, warnings = warnings)
}

#' @export
soil_coverage <- function(depths_in, rules, weight_id) {
  w <- soil_weight(rules, weight_id)
  if (is.null(w)) input_error("Choose a material weight.", "weight")
  in_per_ft <- FOOT / INCH
  lapply(num(depths_in), function(inches) {
    per_yd <- rules$cuFtPerCuYd * in_per_ft / inches
    list(inches = inches, sqFtPerCuYd = per_yd, sqFtPerTon = per_yd * rules$poundsPerTon / w$loose,
         sqFtPerCuFt = in_per_ft / inches)
  })
}
