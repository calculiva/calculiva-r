\name{mulch_new_plan}
\alias{mulch_new_plan}
\alias{mulch_new_rules}
\alias{mulch_new_ring_guidance}
\alias{mulch_check_ring}
\alias{mulch_coverage}
\title{Mulch by area}
\description{
Volume per bed, tree ring, known area, play structure or swing (CPSC depth and
extent), bags, bulk, break-even, loads and warnings.
Calculator page: \url{https://calculiva.com/landscaping/mulch-calculator/}.
}
\usage{
mulch_new_rules()
mulch_new_ring_guidance()
mulch_check_ring(r, gap, guidance = mulch_new_ring_guidance())
mulch_new_plan(input, rules = mulch_new_rules())
mulch_coverage(bag_cu_fts, depths_in, rules = mulch_new_rules())
}
\arguments{
\item{r}{the ring radius, mm.}
\item{gap}{the bare gap at the trunk, mm.}
\item{guidance}{the published gaps and radii from \code{mulch_new_ring_guidance}.}
\item{input}{a list with \code{areas} (one to eight lists with \code{id},
\code{kind}, \code{target} and \code{existing} depths in mm), \code{texture}
(\code{"coarse"} or \code{"fine"}), \code{bagSize}, \code{bagUnit}
(\code{"cuFt"} or \code{"liters"}), \code{bagPrice}, \code{bulkPrice} (per cu
yd), \code{delivery}, \code{increment} (cu yd), \code{extra} (percent),
\code{bedVolume} and \code{wheelbarrow} (cu ft). A \code{kind} is a list with
\code{type} \code{"bed"} (\code{l}, \code{w}, \code{count}), \code{"ring"}
(\code{r}, \code{trunk}, \code{gap}, \code{count}), \code{"knownArea"}
(\code{area}, mm2), \code{"play"} (\code{l}, \code{w}, \code{height}) or
\code{"swing"} (\code{beam}, \code{height}). Missing fields take the
calculator default.}
\item{rules}{the rules from \code{mulch_new_rules}.}
\item{bag_cu_fts}{bag volumes, cubic feet.}
\item{depths_in}{depths, inches.}
}
\value{
\code{mulch_new_plan} returns a list with \code{areas}, \code{totals},
\code{buy}, \code{trips}, \code{wheelbarrowLoads} and \code{warnings};
\code{mulch_check_ring} the published minimums with \code{ok} for each;
\code{mulch_coverage} the square feet per bag at each depth and the bags per
cubic yard.
}
\examples{
ft <- calculiva_units()$foot
swing <- list(id = "s1", kind = list(type = "swing", beam = 10 * ft, height = 8 * ft))
mulch_new_plan(list(areas = list(swing)))$totals$cuYd
mulch_check_ring(3 * ft, 76.2)$radii[[1]]$ok
}
