# Replays vectors.json, written by `go test` from the published Go module
# (ports/vectors-gen in the Calculiva repository): same inputs, same outputs,
# same error fields and messages, within the tolerance of the file.

load_vectors <- function() {
  jsonlite::fromJSON(test_path("vectors.json"), simplifyVector = FALSE)
}

is_object <- function(x) is.list(x) && !is.null(names(x))

show <- function(x) {
  if (is.null(x)) return("null")
  paste(format(unlist(x), digits = 17), collapse = ",")
}

# Every difference between want (parsed JSON) and got (R result); a missing
# name equals null, an atomic vector equals a JSON array.
compare <- function(want, got, path, rel, abs0) {
  if (is.null(want) || is.null(got)) {
    if (is.null(want) && is.null(got)) return(character())
    return(sprintf("%s: want %s, got %s", path, show(want), show(got)))
  }
  if (is_object(want)) {
    if (!is.list(got)) return(sprintf("%s: want an object, got %s", path, show(got)))
    out <- character()
    for (k in union(names(want), names(got))) {
      out <- c(out, compare(want[[k]], got[[k]], paste0(path, ".", k), rel, abs0))
    }
    return(out)
  }
  if (is.list(want)) {
    if (!is.list(got)) got <- as.list(got)
    if (length(want) != length(got)) {
      return(sprintf("%s: want %d items, got %d", path, length(want), length(got)))
    }
    out <- character()
    for (i in seq_along(want)) {
      out <- c(out, compare(want[[i]], got[[i]], sprintf("%s[%d]", path, i - 1), rel, abs0))
    }
    return(out)
  }
  if (is.list(got) || length(got) != 1) return(sprintf("%s: want %s, got %s", path, show(want), show(got)))
  if (is.numeric(want)) {
    ok <- is.numeric(got) && abs(want - got) <= max(abs0, rel * max(abs(want), abs(got)))
  } else {
    ok <- identical(class(want), class(got)) && want == got
  }
  if (isTRUE(ok)) character() else sprintf("%s: want %s, got %s", path, show(want), show(got))
}

sod_rules_from <- function(r) {
  rules <- sod_new_rules()
  rules$allowance <- r$allowance
  rules$allowanceComplex <- r$allowanceComplex
  rules
}

run_vector <- function(fn, i) {
  switch(fn,
    "units" = calculiva_units(),
    "soil.constants" = soil_constants(),
    "soil.newRules" = soil_new_rules(i$weights),
    "soil.areaOf" = list(areaMM2 = soil_area_of(i$id, i$shape)),
    "soil.bagCuFt" = list(cuFt = soil_bag_cu_ft(i$size, i$unit, i$dryQuartIn3)),
    "soil.newPlan" = soil_new_plan(i$plan, soil_new_rules(i$weights)),
    "soil.coverage" = list(rows = soil_coverage(i$depthsIn, soil_new_rules(i$weights), i$weightId)),
    "mulch.constants" = mulch_constants(),
    "mulch.newRules" = mulch_new_rules(),
    "mulch.newRingGuidance" = mulch_new_ring_guidance(),
    "mulch.checkRing" = mulch_check_ring(i$r, i$gap),
    "mulch.newPlan" = mulch_new_plan(i$plan),
    "mulch.coverage" = list(rows = mulch_coverage(i$bagCuFts, i$depthsIn)),
    "sod.constants" = sod_constants(),
    "sod.newRules" = sod_new_rules(),
    "sod.layRect" = sod_lay_rect(i$l, i$w, i$pieceW, i$pieceL),
    "sod.newInput" = {
      x <- sod_new_input(i$areas, sod_rules_from(i$rules))
      x$areas <- NULL
      x
    },
    "sod.newPlan" = sod_new_plan(i$plan, sod_rules_from(i$rules)),
    "sod.formatTable" = list(rows = sod_format_table(i$soldAs, i$sqft)),
    stop("unknown function ", fn)
  )
}

test_that("the vectors follow the package version", {
  skip_if_not_installed("jsonlite")
  doc <- load_vectors()
  expect_equal(doc$version, paste0("v", as.character(packageVersion("calculiva"))))
})

test_that("every vector of the Go module is reproduced", {
  skip_if_not_installed("jsonlite")
  doc <- load_vectors()
  rel <- doc$tolerance$rel
  abs0 <- doc$tolerance$abs
  expect_gt(length(doc$vectors), 100)
  failures <- character()
  for (v in doc$vectors) {
    res <- tryCatch(
      list(error = NULL, value = run_vector(v$fn, v$input)),
      calculiva_input_error = function(e) list(error = list(field = e$field, message = e$input_message), value = NULL)
    )
    d <- if (!is.null(v$error)) {
      if (is.null(res$error)) "want an error, got a result" else compare(v$error, res$error, "error", rel, abs0)
    } else {
      if (!is.null(res$error)) {
        paste0("unexpected error ", res$error$message, " (", res$error$field, ")")
      } else {
        compare(v$output, res$value, "output", rel, abs0)
      }
    }
    if (length(d) > 0) failures <- c(failures, paste0(v$id, ": ", paste(d[seq_len(min(5, length(d)))], collapse = "; ")))
  }
  expect(length(failures) == 0,
         paste(c(sprintf("%d vector(s) differ from the Go module:", length(failures)), failures[seq_len(min(20, length(failures)))]),
               collapse = "\n"))
})

test_that("the README example holds", {
  ft <- calculiva_units()$foot
  inch <- calculiva_units()$inch
  bed <- list(id = "front-bed", kind = list(type = "bed", l = 40 * ft, w = 3 * ft, count = 2),
              target = 3 * inch, existing = 1 * inch)
  plan <- mulch_new_plan(list(areas = list(bed), bagSize = 2))
  expect_equal(plan$totals$cuFt, 40, tolerance = 1e-9)
  expect_equal(plan$buy$bags, 20)
})

test_that("errors name their field", {
  err <- tryCatch(soil_area_of("a1", list(type = "rect", l = 10, w = 3000)), calculiva_input_error = function(e) e)
  expect_s3_class(err, "calculiva_input_error")
  expect_equal(err$field, "a1-l")
  expect_match(conditionMessage(err), "(a1-l)", fixed = TRUE)
})
