#' Convenience functions for length unit conversion
#'
#' Functions to convert between US customary units and SI units for
#' measurements of length used with tree data.
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
#' @param x Numeric vector of values to convert.
#' @return
#' A numeric vector of the converted values.
#'
#' @examples
#' ft_to_m(1)
#'
#' m_to_ft(1)
#'
#' in_to_cm(1)
#'
#' cm_to_in(1)
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
