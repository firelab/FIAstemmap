#' Regression coefficients for predicting tree crown width
#'
#' A curated set of linear regression coefficients for predicting crown width
#' from stem diameter of tree species in the conterminous US.
#'
#' @details
#' The regression equation is of the general form:
#'
#' ```
#' CW = b0 + b1 * DIA + b2 * DIA^2
#' ```
#'
#' where `CW` is the predicted tree crown diameter in feet, `DIA` is FIA stem
#' diameter in inches, and `b0`, `b1`, `b2` are the regression coefficients.
#' The quadratic term `b2` was not included in the regression models for some
#' species, and has been assigned `0` in that case for purposes of this lookup
#' table.
#'
#' In cases that species-specific equations were not available in the
#' literature, surrogate species were assigned based on subjectively similar
#' tree physiognomy.
#'
#' @format ## `cw_coef`
#' A data frame with 430 rows and 8 columns:
#' \describe{
#'   \item{\code{symbol}}{\code{\link{character}},
#'     USDA PLANTS Database species symbol}
#'   \item{\code{SPCD}}{\code{\link{integer}},
#'     FIA tree species code or `-1`}
#'   \item{\code{common_name}}{\code{\link{character}},
#'     FIA tree species common name}
#'   \item{\code{surrogate}}{\code{\link{character}},
#'     Common name of surrogate species if applicable}
#'   \item{\code{b0}}{\code{\link{numeric}}, Regression b0 coefficient}
#'   \item{\code{b1}}{\code{\link{numeric}}, Regression b1 coefficient}
#'   \item{\code{b2}}{\code{\link{numeric}}, Regression b2 coefficient}
#'   \item{\code{reference}}{\code{\link{character}},
#'     Literature source of the species coefficients (see References)}
#' }
#' @examples
#' cw_coef[cw_coef$SPCD == 17, ]
#' @source
#' Toney et al. 2009. A stem-map model for predicting tree canopy cover of
#' Forest Inventory and Analysis (FIA) plots.
#' \url{https://research.fs.usda.gov/treesearch/33381}.
#' @references
#' Bechtold, W.A. 2003. Crown-Diameter Prediction Models for 87 Species of
#' Stand-Grown Trees in the Eastern United States. _Southern Journal of Applied
#' Forestry_, 27(4): 269-278.
#'
#' Bechtold, W.A. 2004. Largest-Crown-Width Prediction Models for 53 Species in
#' the Western United States. _Western Journal of Applied Forestry_, 19(4):
#' 245-251.
#'
#' Gill, S.J., G.S. Biging, E.C. Murphy. 2000. Modeling conifer tree crown
#' radius and estimating canopy cover. _Forest Ecology and Management_, 126(3):
#' 405-416.
"cw_coef"


#' Sapling crown width adjustment factors
#'
#' A species-specific lookup table of estimated adjustment factors for crown
#' width (CW) of saplings based on data from Bragg (2001).
#'
#' @details
#' FIA "saplings" are trees less than 5.0 in. (12.7 cm) diameter but greater
#' than or equal to 1.0 in. (2.54 cm) diameter. In general, the data available
#' to fit regression models predicting crown width (e.g., Bechtold 2003, 2004,
#' see [cw_coef]) do not include trees with diameter less than 5.0 in.
#' (12.7 cm). Extrapolating beyond the range of the model fitting data is
#' undesirable, especially since a quadratic term is used in the regression
#' equations for some species.
#'
#' Adjustment is based on the proportion of crown width predicted for 5-in.
#' (12.7 cm) diameter, at each 1-in. (2.54 cm) increment below that.
#' Intermediate values are interpolated in the crown width prediction method.
#' Mean adjustment factors are used if a species-specific adjustment is not
#' available.
#'
#' @format ## `cw_sapling_adj`
#' A data frame with 23 rows and 5 columns:
#' \describe{
#'   \item{\code{SPCD}}{\code{\link{integer}}, FIA tree species code}
#'   \item{\code{adj_1inch}}{\code{\link{numeric}},
#'     CW adjustment factor at 1 in. DIA relative to 5 in. DIA}
#'   \item{\code{adj_2inch}}{\code{\link{numeric}},
#'     CW adjustment factor at 2 in. DIA relative to 5 in. DIA}
#'   \item{\code{adj_3inch}}{\code{\link{numeric}},
#'     CW adjustment factor at 3 in. DIA relative to 5 in. DIA}
#'   \item{\code{adj_4inch}}{\code{\link{numeric}},
#'     CW adjustment factor at 4 in. DIA relative to 5 in. DIA}
#' }
#' @examples
#' cw_coef[cw_coef$SPCD == 261, ]
#'
#' cw_sapling_adj[cw_sapling_adj$SPCD == 261, ]
#' @source
#' Toney et al. 2009. A stem-map model for predicting tree canopy cover of
#' Forest Inventory and Analysis (FIA) plots.
#' \url{https://research.fs.usda.gov/treesearch/33381}.
#' @references
#' Bragg, D.C. 2001. A local basal area adjustment for crown width prediction.
#' _Northern Journal of Applied Forestry_ 18(1):22-28.
"cw_sapling_adj"


#' Tree list for a plot in a loblolly pine plantation
#'
#' An example tree list for an FIA plot in a loblolly pine plantation.
#'
#' @format ## `plantation`
#' A data frame with 91 rows and 14 columns:
#' \describe{
#'   \item{\code{PLT_CN}}{\code{\link{character}}, Plot unique identifier}
#'   \item{\code{SUBP}}{\code{\link{integer}}, Subplot number}
#'   \item{\code{TREE}}{\code{\link{integer}}, Tree number}
#'   \item{\code{AZIMUTH}}{\code{\link{integer}},
#'     Horizontal angle from subplot center to the stem location}
#'   \item{\code{DIST}}{\code{\link{numeric}},
#'     Distance in feet from subplot center to the stem location}
#'   \item{\code{STATUSCD}}{\code{\link{integer}},
#'     Tree status code: 1 = live, 2 = standing dead}
#'   \item{\code{SPCD}}{\code{\link{integer}}, FIA tree species code}
#'   \item{\code{SPGRPCD}}{\code{\link{integer}}, FIA tree species group code}
#'   \item{\code{DIA}}{\code{\link{numeric}},
#'     Tree diameter at breast height in inches}
#'   \item{\code{HT}}{\code{\link{integer}}, Tree height in feet}
#'   \item{\code{ACTUALHT}}{\code{\link{integer}},
#'     Actual height in ft (ACTUALHT < HT indicates a broken top)}
#'   \item{\code{CCLCD}}{\code{\link{integer}}, Tree crown class code}
#'   \item{\code{TPA_UNADJ}}{\code{\link{numeric}},
#'     Trees per acre expansion factor}
#'   \item{\code{CRWIDTH}}{\code{\link{numeric}},
#'     Estimated tree crown width in feet}
#' }
#' @source <https://research.fs.usda.gov/programs/nfi>
"plantation"
