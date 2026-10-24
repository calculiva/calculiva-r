# Mulch by area: beds, tree rings, known areas, play structures and swings (CPSC).
# Calculator page: https://calculiva.com/landscaping/mulch-calculator/

MULCH_DEPTH_MIN <- 3.0
MULCH_DEPTH_MAX <- 600.0
MULCH_DEPTH_MSG <- "Enter a depth from 1/8 in to about 24 in (3 to 600 mm)."
MULCH_EXISTING_MSG <- "Enter the depth already in place from 0 to about 24 in (600 mm)."

publisher <- function(id, name, url, depthIn = NULL, fineDepthIn = NULL, trunkGapIn = NULL, ringRadiusByTreeFt = NULL) {
  list(id = id, name = name, sourceURL = url, depthIn = depthIn, fineDepthIn = fineDepthIn,
       trunkGapIn = trunkGapIn, ringRadiusByTreeFt = ringRadiusByTreeFt)
}

# The mulch depth and trunk-gap guidance, publisher by publisher. A single
# published value v is stored as the range [v, v]; Casey Trees and Maple Grove
# publish it inside their 3-3-3 rule.
# Data sheet mulch-depth-guidance (publishers), source https://extension.psu.edu/mulching-landscape-trees/,
# verified 2026-09-25.
MULCH_PUBLISHERS <- list(
  publisher("psu", "Penn State Extension", "https://extension.psu.edu/mulching-landscape-trees/",
            depthIn = c(2.0, 4.0), fineDepthIn = c(1.0, 2.0)),
  publisher("umd", "University of Maryland Extension", "https://extension.umd.edu/resource/mulching-trees-and-shrubs",
            depthIn = c(1.0, 3.0), trunkGapIn = c(3.0, 3.0)),
  publisher("isu", "Iowa State University Extension", "https://yardandgarden.extension.iastate.edu/how-to/using-mulch-garden",
            depthIn = c(2.0, 4.0)),
  publisher("ucm", "UC Marin Master Gardeners (UC ANR)", "https://ucanr.edu/site/uc-marin-master-gardeners/applying-mulch",
            trunkGapIn = c(6.0, 12.0)),
  publisher("ncufc", "NCUFC", "https://www.ncufc.org/proper-mulching-for-trees.php",
            depthIn = c(2.0, 4.0), trunkGapIn = c(1.0, 2.0),
            ringRadiusByTreeFt = list(list(size = "small", ft = 3.0), list(size = "medium", ft = 8.0), list(size = "large", ft = 12.0))),
  publisher("casey", "Casey Trees", "https://caseytrees.org/2024/05/mulching-dos-and-donts/",
            trunkGapIn = c(3.0, 3.0)),
  publisher("maplegrove", "City of Maple Grove, Minnesota", "https://www.maplegrovemn.gov/DocumentCenter/View/1996/How-to-apply-mulch-around-trees-PDF",
            trunkGapIn = c(3.0, 3.0))
)

# CPSC rules. Data sheet playground-surfacing-cpsc, source https://www.cpsc.gov/s3fs-public/324.pdf,
# verified 2026-09-25 (compression read on https://www.cpsc.gov/s3fs-public/325.pdf).
# Extent in all directions, feet (home_handbook.extent.all_directions_ft).
CPSC_ALL_DIRECTIONS_FT <- 6.0
# To-fro swings: front and back as a multiple of the top bar height
# (home_handbook.extent.swing_front_back_multiple_of_top_bar).
CPSC_SWING_MULTIPLE <- 2.0
# Tire swings: feet added to the chain height (home_handbook.extent.tire_swing_extra_ft).
CPSC_TIRE_SWING_EXTRA_FT <- 6.0
# Tallest equipment covered by wood mulch or chips, feet
# (home_handbook.loose_fill.wood_mulch_chips_max_equipment_ft).
CPSC_WOOD_MULCH_MAX_EQUIPMENT_FT <- 8.0
# Height below which equipment is "low", feet (home_handbook.loose_fill.low_equipment_ft).
CPSC_LOW_EQUIPMENT_FT <- 4.0
# Maintained loose-fill depth, inches (home_handbook.loose_fill.maintained_depth_in).
CPSC_MAINTAINED_DEPTH_IN <- 9.0
# Initial fill that compresses to the maintained depth, inches (home_handbook.loose_fill.initial_fill_in).
CPSC_INITIAL_FILL_IN <- 12.0
# Minimum surfacing under low equipment, inches (home_handbook.loose_fill.low_equipment_min_depth_in).
CPSC_LOW_EQUIPMENT_MIN_DEPTH_IN <- 6.0
# Fraction by which loose fill compresses at least over time (public_handbook.compression_min_fraction).
CPSC_COMPRESSION_MIN_FRACTION <- 0.25

#' @export
mulch_constants <- function() {
  list(cpscAllDirectionsFt = CPSC_ALL_DIRECTIONS_FT, cpscSwingMultiple = CPSC_SWING_MULTIPLE,
       cpscTireSwingExtraFt = CPSC_TIRE_SWING_EXTRA_FT, cpscWoodMulchMaxEquipmentFt = CPSC_WOOD_MULCH_MAX_EQUIPMENT_FT,
       cpscLowEquipmentFt = CPSC_LOW_EQUIPMENT_FT, cpscMaintainedDepthIn = CPSC_MAINTAINED_DEPTH_IN,
       cpscInitialFillIn = CPSC_INITIAL_FILL_IN, cpscLowEquipmentMinDepthIn = CPSC_LOW_EQUIPMENT_MIN_DEPTH_IN,
       cpscCompressionMinFraction = CPSC_COMPRESSION_MIN_FRACTION, publishers = MULCH_PUBLISHERS)
}

#' @export
mulch_new_rules <- function() {
  psu <- NULL
  for (p in MULCH_PUBLISHERS) if (p$id == "psu") { psu <- p; break }
  upper <- function(v) if (is.null(v)) NaN else max(v[1], v[2])
  list(
    cuFtPerCuYd = CUBIC_FEET_PER_CUBIC_YARD,
    cpsc = list(
      allDirectionsMM = CPSC_ALL_DIRECTIONS_FT * FOOT, swingMultiple = CPSC_SWING_MULTIPLE,
      tireExtraMM = CPSC_TIRE_SWING_EXTRA_FT * FOOT, maxEquipmentMM = CPSC_WOOD_MULCH_MAX_EQUIPMENT_FT * FOOT,
      lowEquipmentMM = CPSC_LOW_EQUIPMENT_FT * FOOT, maintainedMM = CPSC_MAINTAINED_DEPTH_IN * INCH,
      lowMaintainedMM = CPSC_LOW_EQUIPMENT_MIN_DEPTH_IN * INCH, compression = CPSC_COMPRESSION_MIN_FRACTION
    ),
    maxDepth = list(coarse = upper(psu$depthIn) * INCH, fine = upper(psu$fineDepthIn) * INCH)
  )
}

#' @export
mulch_new_ring_guidance <- function() {
  gaps <- list()
  radii <- list()
  for (p in MULCH_PUBLISHERS) {
    if (!is.null(p$trunkGapIn)) {
      gaps[[length(gaps) + 1]] <- list(id = p$id, publisher = p$name, size = "", minMM = min(p$trunkGapIn[1], p$trunkGapIn[2]) * INCH)
    }
  }
  for (p in MULCH_PUBLISHERS) {
    if (!is.null(p$ringRadiusByTreeFt)) {
      for (r in p$ringRadiusByTreeFt) {
        radii[[length(radii) + 1]] <- list(id = p$id, publisher = p$name, size = r$size, minMM = r$ft * FOOT)
      }
      break
    }
  }
  list(gaps = gaps, radii = radii)
}

#' @export
mulch_check_ring <- function(r, gap, guidance = mulch_new_ring_guidance()) {
  list(
    gaps = lapply(guidance$gaps, function(g) list(minimum = g, ok = gap >= g$minMM - EPS)),
    radii = lapply(guidance$radii, function(g) list(minimum = g, ok = r >= g$minMM - EPS))
  )
}

MULCH_INPUT_DEFAULTS <- list(texture = "coarse", bagSize = 0, bagUnit = "cuFt", bagPrice = 0, bulkPrice = 0,
                             delivery = 0, increment = 0, extra = 0, bedVolume = 0, wheelbarrow = 0)

mulch_warning <- function(kind, area = "", maxMM = 0.0, existing = 0.0, target = 0.0, surplusCuFt = 0.0) {
  list(kind = kind, area = area, maxMM = maxMM, existing = existing, target = target, surplusCuFt = surplusCuFt)
}

#' @export
mulch_new_plan <- function(input, rules = mulch_new_rules()) {
  x <- with_defaults(input, MULCH_INPUT_DEFAULTS)
  if (length(x$areas) == 0 || length(x$areas) > 8) input_error("Tick one to eight areas.", "areas")
  if (x$bagUnit == "cuFt") {
    bag <- list(lo = 0.05, hi = 10.0, name = "cu ft")
  } else if (x$bagUnit == "liters") {
    bag <- list(lo = 1.0, hi = 300.0, name = "liters")
  } else {
    input_error("Choose a bag unit.", "bag-unit")
  }
  if (x$bagSize != 0) {
    check_range(x$bagSize, bag$lo, bag$hi, paste0("Enter a bag size from ", js_num(bag$lo), " to ", js_num(bag$hi), " ", bag$name, ", or 0."), "bag")
  }
  check_range(x$bagPrice, 0.0, 100000.0, "Enter a bag price from 0 to 100,000 USD.", "bag-price")
  check_range(x$bulkPrice, 0.0, 100000.0, "Enter a bulk price from 0 to 100,000 USD.", "bulk-price")
  check_range(x$delivery, 0.0, 10000.0, "Enter a delivery charge from 0 to 10,000 USD.", "delivery")
  if (x$increment != 0) check_range(x$increment, 0.1, 10.0, "Enter a sale increment from 0.1 to 10 cu yd, or 0.", "increment")
  check_range(x$extra, 0.0, 100.0, "Enter an extra from 0 to 100 %.", "extra")
  if (x$bedVolume != 0) check_range(x$bedVolume, 1.0, 200.0, "Enter a bed volume from 1 to 200 cu ft, or 0.", "bed-volume")
  if (x$wheelbarrow != 0) check_range(x$wheelbarrow, 1.0, 20.0, "Enter a wheelbarrow volume from 1 to 20 cu ft, or 0.", "wheelbarrow")
  per_yd <- rules$cuFtPerCuYd
  p <- rules$cpsc
  max_mm <- if (x$texture == "fine") rules$maxDepth$fine else rules$maxDepth$coarse
  warnings <- list()
  areas <- list()
  for (a in x$areas) {
    a <- with_defaults(a, list(target = 0, existing = 0))
    f <- function(k) paste0(a$id, "-", k)
    len <- function(v, k, label) check_range(v, LEN_MIN, LEN_MAX, paste0("Enter ", label, LEN_MSG), f(k))
    copies <- function(n) {
      if (!is_whole(n) || !(n >= 1.0 && n <= 100.0)) input_error("Enter a whole number of copies from 1 to 100.", f("count"))
    }
    # Play area: maintained depth by height (6 in under 4 ft, 9 in up to 8 ft, beyond that
    # outside the home handbook); initial fill = maintained / (1 - compression).
    cpsc_depth <- function(height) {
      check_range(height, LEN_MIN, LEN_MAX, paste0("Enter a height", LEN_MSG), f("height"))
      if (height > p$maxEquipmentMM + EPS) {
        input_error(paste0("Enter a height up to ", locale(p$maxEquipmentMM / FOOT, 1), " ft (", locale(p$maxEquipmentMM, 1),
                           " mm): taller equipment is outside the home handbook for wood mulch."), f("height"))
      }
      maintained <- if (height < p$lowEquipmentMM - EPS) p$lowMaintainedMM else p$maintainedMM
      list(maintained = maintained, initial = maintained / (1.0 - p$compression))
    }
    k <- a$kind
    type <- nz(k$type, "")
    garden <- FALSE
    plan <- list(id = a$id, count = 1.0, target = a$target, existing = a$existing, areaMM2 = 0.0,
                 innerMM = NULL, maintainedMM = NULL, initialMM = NULL, extentL = NULL, extentW = NULL, frontMM = NULL)
    if (type == "bed") {
      garden <- TRUE
      plan$areaMM2 <- soil_area_of(a$id, list(type = "rect", l = k$l, w = k$w))
      copies(k$count)
      plan$count <- k$count
    } else if (type == "knownArea") {
      garden <- TRUE
      plan$areaMM2 <- soil_area_of(a$id, list(type = "knownArea", area = k$area))
    } else if (type == "ring") {
      garden <- TRUE
      # Trunk and gap at 0: the ring becomes a plain round bed.
      len(k$r, "r", "a ring radius")
      check_range(k$trunk, 0.0, LEN_MAX, "Enter a trunk diameter from 0 to 60 m (0 to 196 ft).", f("trunk"))
      check_range(k$gap, 0.0, LEN_MAX, "Enter a bare gap from 0 to 60 m (0 to 196 ft).", f("gap"))
      inner <- k$trunk / 2.0 + k$gap
      if (inner >= k$r - EPS) input_error("The trunk and its bare gap must fit inside the ring radius.", f("r"))
      plan$areaMM2 <- pi * (k$r * k$r - inner * inner)
      copies(k$count)
      plan$count <- k$count
      plan$innerMM <- inner
    } else if (type == "play") {
      # CPSC surface: the footprint plus 6 ft on every side.
      d <- cpsc_depth(k$height)
      len(k$l, "l", "a length")
      extent_l <- k$l + 2.0 * p$allDirectionsMM
      len(k$w, "w", "a width")
      extent_w <- k$w + 2.0 * p$allDirectionsMM
      plan$areaMM2 <- extent_l * extent_w
      plan$target <- d$initial
      plan$maintainedMM <- d$maintained
      plan$initialMM <- d$initial
      plan$extentL <- extent_l
      plan$extentW <- extent_w
    } else if (type == "swing") {
      # Swing: twice the top bar height in front and behind, never under 6 ft all round.
      d <- cpsc_depth(k$height)
      len(k$beam, "beam", "a top bar length")
      extent_l <- k$beam + 2.0 * p$allDirectionsMM
      front <- max(p$swingMultiple * k$height, p$allDirectionsMM)
      extent_w <- 2.0 * front
      plan$areaMM2 <- extent_l * extent_w
      plan$target <- d$initial
      plan$maintainedMM <- d$maintained
      plan$initialMM <- d$initial
      plan$extentL <- extent_l
      plan$extentW <- extent_w
      plan$frontMM <- front
    } else {
      input_error("Choose a kind of area.", f("kind"))
    }
    if (garden) check_range(a$target, MULCH_DEPTH_MIN, MULCH_DEPTH_MAX, MULCH_DEPTH_MSG, f("target"))
    check_range(a$existing, 0.0, MULCH_DEPTH_MAX, MULCH_EXISTING_MSG, f("existing"))
    target <- plan$target
    plan$addedDepth <- max(target - a$existing, 0.0)
    plan$volume <- plan$areaMM2 * plan$addedDepth * plan$count
    if (garden && target > max_mm + EPS) {
      warnings[[length(warnings) + 1]] <- mulch_warning("over-max", area = a$id, maxMM = max_mm, target = target)
    }
    if (a$existing >= target - EPS) {
      warnings[[length(warnings) + 1]] <- mulch_warning("already-deep", area = a$id, existing = a$existing, target = target)
    }
    if (garden && a$existing > target + EPS) {
      warnings[[length(warnings) + 1]] <- mulch_warning("deep-refill", area = a$id, existing = a$existing, target = target)
    }
    plan$sqFt <- plan$areaMM2 / SOIL_SQFT
    plan$cuFt <- plan$volume / SOIL_CUFT
    plan$cuYd <- plan$volume / SOIL_CUFT / per_yd
    areas[[length(areas) + 1]] <- plan
  }
  volume <- 0.0
  for (a in areas) volume <- volume + a$volume
  cuft <- volume / SOIL_CUFT
  cuyd <- cuft / per_yd
  ordered_cuft <- cuft * (1.0 + x$extra / 100.0)
  ordered_cuyd <- ordered_cuft / per_yd
  # Bags, bulk, break-even and hauling: the soil formulas, by volume only.
  bc <- NULL
  bags <- NULL
  bag_cost <- NULL
  if (x$bagSize != 0) {
    bc <- soil_bag_cu_ft(x$bagSize, x$bagUnit, NaN)
    bags <- ceil_rel(ordered_cuft / bc)
    if (x$bagPrice != 0) bag_cost <- bags * x$bagPrice
  }
  bulk_cuyd <- ordered_cuyd
  if (x$increment != 0) bulk_cuyd <- ceil_rel(ordered_cuyd / x$increment) * x$increment
  surplus <- (bulk_cuyd - ordered_cuyd) * per_yd
  bulk_cost <- if (x$bulkPrice != 0) bulk_cuyd * x$bulkPrice + x$delivery else NULL
  cheaper <- NULL
  if (!is.null(bag_cost) && !is.null(bulk_cost)) cheaper <- if (bag_cost <= bulk_cost) "bags" else "bulk"
  bag_per <- NULL
  bulk_per <- NULL
  break_even <- NULL
  if (!is.null(bc) && bc != 0 && x$bagPrice != 0) bag_per <- x$bagPrice / bc
  if (x$bulkPrice != 0) bulk_per <- x$bulkPrice / per_yd
  if (!is.null(bag_per) && !is.null(bulk_per) && bag_per > bulk_per) break_even <- x$delivery / (bag_per - bulk_per)
  trips <- if (x$bedVolume != 0) ceil_rel(ordered_cuft / x$bedVolume) else NULL
  loads <- if (x$wheelbarrow != 0) ceil_rel(ordered_cuft / x$wheelbarrow) else NULL
  if (x$increment != 0 && surplus > EPS) {
    warnings[[length(warnings) + 1]] <- mulch_warning("increment", surplusCuFt = surplus)
  }
  list(
    areas = areas,
    totals = list(volume = volume, cuFt = cuft, cuYd = cuyd, orderedCuFt = ordered_cuft, orderedCuYd = ordered_cuyd,
                  orderedVolume = ordered_cuft * SOIL_CUFT, bulkCuYd = bulk_cuyd, bulkVolume = bulk_cuyd * per_yd * SOIL_CUFT),
    buy = list(bagCuFt = bc, bags = bags, bagCost = bag_cost, bulkCuYd = bulk_cuyd, bulkSurplusCuFt = surplus,
               bulkCost = bulk_cost, cheaper = cheaper, bagPerCuFt = bag_per, bulkPerCuFt = bulk_per, breakEvenCuFt = break_even),
    trips = trips, wheelbarrowLoads = loads, warnings = warnings
  )
}

#' @export
mulch_coverage <- function(bag_cu_fts, depths_in, rules = mulch_new_rules()) {
  in_per_ft <- FOOT / INCH
  depths <- num(depths_in)
  lapply(num(bag_cu_fts), function(cuft) {
    list(cuFt = cuft, sqFt = cuft * in_per_ft / depths, bagsPerCuYd = rules$cuFtPerCuYd / cuft)
  })
}
