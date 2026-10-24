\name{soil_new_plan}
\alias{soil_new_plan}
\alias{soil_new_rules}
\alias{soil_area_of}
\alias{soil_bag_cu_ft}
\alias{soil_coverage}
\title{Topsoil and fill dirt by area}
\description{
Volume per area, bags, bulk by the yard or the ton, weight, truck trips and
wheelbarrow loads, per material (topsoil first, then fill).
Calculator page: \url{https://calculiva.com/landscaping/soil-calculator/}.
}
\usage{
soil_new_rules(weights = list())
soil_area_of(id, shape)
soil_bag_cu_ft(size, unit, dry_quart_in3)
soil_new_plan(input, rules)
soil_coverage(depths_in, rules, weight_id)
}
\arguments{
\item{weights}{a list of material weights entered by the user, each a list
with \code{id}, \code{label}, \code{loose} and \code{bank} (pounds per cubic
yard) and \code{loadFactor}.}
\item{id}{the area id; it prefixes the field of any error (\code{"a1-l"}).}
\item{shape}{a list with \code{type} \code{"rect"} (\code{l}, \code{w}),
\code{"circle"} (\code{d}), \code{"triangle"} (\code{b}, \code{h}) or
\code{"knownArea"} (\code{area}, mm2); lengths in mm.}
\item{size}{the bag size.}
\item{unit}{\code{"cuFt"}, \code{"dryQuarts"} or \code{"liters"}.}
\item{dry_quart_in3}{cubic inches per dry quart, from the rules.}
\item{input}{a list with \code{areas} (one to eight lists with \code{id},
\code{shape}, \code{depth} in mm, \code{count} and \code{material}
\code{"topsoil"} or \code{"fill"}), \code{topsoil} and \code{fill} (lists with
\code{bagSize}, \code{bagUnit}, \code{bagPrice}, \code{bulkPrice} and the
\code{weight} id), \code{bulkBy} (\code{"yard"} or \code{"ton"}),
\code{delivery}, \code{increment} (cu yd), \code{extra} (percent),
\code{payload} (lb), \code{bedVolume} and \code{wheelbarrow} (cu ft). Missing
fields take the calculator default (0, \code{"yard"}).}
\item{rules}{the rules from \code{soil_new_rules}.}
\item{depths_in}{depths in inches.}
\item{weight_id}{the id of a weight of the rules.}
}
\value{
\code{soil_new_plan} returns a list with \code{areas}, \code{materials},
\code{totals} and \code{warnings}; \code{soil_area_of} an area in mm2;
\code{soil_bag_cu_ft} a volume in cubic feet; \code{soil_coverage} one row per
depth (square feet per cubic yard, per ton and per cubic foot).
}
\examples{
ft <- calculiva_units()$foot
rules <- soil_new_rules(list(list(id = "mine", label = "my supplier's ticket",
                                  loose = 2000, bank = 2500, loadFactor = 0.75)))
area <- list(id = "a1", shape = list(type = "rect", l = 10 * ft, w = 12 * ft),
             depth = 101.6, count = 1, material = "topsoil")
plan <- soil_new_plan(list(areas = list(area), topsoil = list(bagSize = 0.75, weight = "mine")), rules)
plan$materials[[1]]$bags
}
