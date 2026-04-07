# Convenience functions for length unit conversion

Functions to convert between US customary units and SI units for
measurements of length used with tree data.

## Usage

``` r
ft_to_m(x)

m_to_ft(x)

in_to_cm(x)

cm_to_in(x)
```

## Arguments

- x:

  Numeric vector of values to convert.

## Value

A numeric vector of the converted values.

## Details

`ft_to_m(x)` converts feet to meters.

`m_to_ft(x)` converts meters to feet.

`in_to_cm(x)` converts inches to centimeters.

`cm_to_in(x)` converts centimeters to inches.

## Examples

``` r
ft_to_m(1)
#> [1] 0.3048

m_to_ft(1)
#> [1] 3.28084

in_to_cm(1)
#> [1] 2.54

cm_to_in(1)
#> [1] 0.393701
```
