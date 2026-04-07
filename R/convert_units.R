#' Convenience functions for common unit conversions
#'
#' Functions to convert between US customary units and SI units for
#' measurements of length and area commonly used with tree data.
#'
#' @name convert_units
#' @details
#' `ft_to_m(x)` converts feet to meters.
#'
#' `m_to_ft(x)` converts meters to feet.
#'
#' `in_to_cm(x)` converts inches to centimeters.
#'
#' `cm_to_in(x)` converts centimeters to inches.
#'
#' `ac_to_ha()` converts acres to hectares.
#'
#' `ha_to_ac()` converts hectares to acres.
#'
#' @param x Numeric vector of values to convert.
#' @return
#' A numeric vector of the converted values.
#'
#' @note
#' The hectare (ha) is technically a non-SI unit of area that is [accepted for
#' use with SI](https://en.wikipedia.org/wiki/International_System_of_Units#Non-SI_units_accepted_for_use_with_SI).
#'
#' @examples
#' ft_to_m(1)
#'
#' m_to_ft(1)
#'
#' in_to_cm(1)
#'
#' cm_to_in(1)
#'
#' ac_to_ha(1)
#'
#' ha_to_ac(1)
#' @export
ft_to_m <- function(x) {
    if (!is.numeric(x)) {
        stop(cli::format_error(c(
            "{.var x} must be a numeric vector",
        "x" = "Invalid input type: {.cls {class(x)}}")))
    }

    x * 0.3048
}

#' @name convert_units
#' @export
m_to_ft <- function(x) {
    if (!is.numeric(x)) {
        stop(cli::format_error(c(
            "{.var x} must be a numeric vector",
        "x" = "Invalid input type: {.cls {class(x)}}")))
    }

    x * 3.28084
}

#' @name convert_units
#' @export
in_to_cm <- function(x) {
    if (!is.numeric(x)) {
        stop(cli::format_error(c(
            "{.var x} must be a numeric vector",
        "x" = "Invalid input type: {.cls {class(x)}}")))
    }

    x * 2.54
}

#' @name convert_units
#' @export
cm_to_in <- function(x) {
    if (!is.numeric(x)) {
        stop(cli::format_error(c(
            "{.var x} must be a numeric vector",
        "x" = "Invalid input type: {.cls {class(x)}}")))
    }

    x * 0.393701
}

#' @name convert_units
#' @export
ac_to_ha <- function(x) {
    if (!is.numeric(x)) {
        stop(cli::format_error(c(
            "{.var x} must be a numeric vector",
        "x" = "Invalid input type: {.cls {class(x)}}")))
    }

    x * 4046.8564224 / 10000
}

#' @name convert_units
#' @export
ha_to_ac <- function(x) {
    if (!is.numeric(x)) {
        stop(cli::format_error(c(
            "{.var x} must be a numeric vector",
        "x" = "Invalid input type: {.cls {class(x)}}")))
    }

    x * 10000 / 4046.8564224
}
