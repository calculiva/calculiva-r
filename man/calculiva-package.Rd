\name{calculiva-package}
\alias{calculiva-package}
\alias{calculiva}
\docType{package}
\title{Calculiva home improvement estimators}
\description{
Planning quantities for mulch, topsoil and fill, and sod: volume, bags, bulk,
pallets, pieces, weight and trips. A port of the Go module
\code{github.com/calculiva/calculiva-go} (same version, same test vectors),
itself a port of the engine of the calculators on \url{https://calculiva.com/}.
The method is described at \url{https://calculiva.com/how-we-calculate/}.

All lengths are millimetres (see \code{\link{calculiva_units}}). Inputs and
results are named lists whose names follow the Go module's fields in lower
camel case (\code{areaMM2}, \code{cuFt}, \code{bagCuFt}); a \code{NULL} value
means that the input it depends on was not entered. Invalid input signals a
condition of class \code{calculiva_input_error} whose \code{field} names the
offending field and whose \code{input_message} is the message alone.

Every constant carries, in the source code, its data sheet, the public source
it was read on and the date it was verified. Material weights, bag and
wheelbarrow sizes and sod allowances are not shipped: they are inputs of the
user. The results are planning quantities: the product label, the supplier's
quote, the local code and the installer on site govern.
}
\seealso{
\code{\link{mulch_new_plan}}, \code{\link{soil_new_plan}}, \code{\link{sod_new_plan}}.
}
\examples{
ft <- calculiva_units()$foot
inch <- calculiva_units()$inch
# Two 40 x 3 ft beds topped up from 1 in to 3 in, bought in 2 cu ft bags.
bed <- list(id = "front-bed", kind = list(type = "bed", l = 40 * ft, w = 3 * ft, count = 2),
            target = 3 * inch, existing = 1 * inch)
plan <- mulch_new_plan(list(areas = list(bed), bagSize = 2))
plan$totals$cuFt
plan$buy$bags
}
\keyword{package}
