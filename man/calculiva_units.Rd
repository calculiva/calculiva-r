\name{calculiva_units}
\alias{calculiva_units}
\alias{soil_constants}
\alias{mulch_constants}
\alias{sod_constants}
\title{Units and sourced constants}
\description{
The length units and the sourced constants of each estimator, as named lists.
}
\usage{
calculiva_units()
soil_constants()
mulch_constants()
sod_constants()
}
\value{
\code{calculiva_units} returns \code{inch} (25.4) and \code{foot} (304.8), in
millimetres. \code{soil_constants} returns the NIST Handbook 130 units (pounds
per short ton, cubic feet per cubic yard, cubic inches per dry quart) and the
square and cubic foot in mm. \code{mulch_constants} returns the CPSC
playground surfacing rules and the mulch depth guidance publisher by
publisher. \code{sod_constants} returns the surveyed sod formats and pallets,
the Penn State and NC State soil preparation figures and UF/IFAS LH013 Table 3.
The source and verification date of each value are given in the package source.
}
\examples{
calculiva_units()$foot
soil_constants()$cubicFeetPerCubicYard
}
