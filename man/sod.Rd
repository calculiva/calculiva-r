\name{sod_new_plan}
\alias{sod_new_plan}
\alias{sod_new_rules}
\alias{sod_new_input}
\alias{sod_lay_rect}
\alias{sod_format_table}
\title{Sod by area}
\description{
Pieces per area (rectangles laid out piece by piece in staggered rows, with
offcut pairing), pallets, plugs (UF/IFAS LH013 Table 3), soil preparation,
cost and weight.
Calculator page: \url{https://calculiva.com/landscaping/sod-calculator/}.
}
\usage{
sod_new_rules()
sod_new_input(areas = list(), rules = sod_new_rules())
sod_new_plan(input, rules = sod_new_rules())
sod_lay_rect(l, w, piece_w, piece_l)
sod_format_table(sold_as, sqft, rules = sod_new_rules())
}
\arguments{
\item{areas}{one to eight lists with \code{id} and \code{shape}: \code{type}
\code{"rect"} (\code{l}, \code{w}, \code{count}), \code{"circle"} (\code{r},
\code{count}), \code{"triangle"} (\code{b}, \code{h}, \code{count}) or
\code{"knownArea"} (\code{area}, mm2); lengths in mm.}
\item{rules}{the rules from \code{sod_new_rules}; set \code{allowance} and
\code{allowanceComplex} (percent) yourself.}
\item{input}{the list returned by \code{sod_new_input}, with
\code{palletPieces} (or \code{palletMode = "sqFt"} and \code{palletSqFt}),
\code{format} (a format id or \code{"custom"} with \code{pieceW} and
\code{pieceL}), \code{allowance}, \code{spare}, \code{method}
(\code{"solid"} or \code{"plugs"}), \code{species}, \code{spacing},
\code{plugSize}, \code{topsoil}, \code{organic} (\code{"layer"},
\code{"rate"} or \code{"none"}), \code{organicIn}, \code{organicRate},
\code{priceMode} (\code{"perPallet"}, \code{"perPiece"} or \code{"perSqFt"}),
\code{price}, \code{delivery} and \code{payload}.}
\item{l, w}{the rectangle length and width, mm.}
\item{piece_w, piece_l}{the piece width and length, mm.}
\item{sold_as}{pallet coverages, square feet.}
\item{sqft}{the lawn area, square feet.}
}
\value{
\code{sod_new_plan} returns a list with the piece size, \code{areas},
\code{totals}, \code{pallets}, \code{plug}, \code{prep}, \code{cost},
\code{weightLb}, \code{trips} and \code{warnings}; \code{sod_lay_rect} the
placed pieces, rows and counts; \code{sod_format_table} one row per format.
}
\examples{
ft <- calculiva_units()$foot
input <- sod_new_input(list(list(id = "a1", shape = list(type = "rect", l = 10 * ft, w = 8 * ft, count = 1))))
input$palletPieces <- 150
sod_new_plan(input)$totals$pieces
}
