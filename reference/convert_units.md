# Convenience functions for common unit conversions

Functions to convert between US customary units and SI units for
measurements of length and area commonly used with tree data.

## Usage

``` r
ft_to_m(x)

m_to_ft(x)

in_to_cm(x)

cm_to_in(x)

ac_to_ha(x)

ha_to_ac(x)
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

`ac_to_ha()` converts acres to hectares.

`ha_to_ac()` converts hectares to acres.

## Note

The hectare (ha) is technically a non-SI unit of area that is [accepted
for use with
SI](https://en.wikipedia.org/wiki/International_System_of_Units#Non-SI_units_accepted_for_use_with_SI).

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

ac_to_ha(1)
#> [1] 0.4046856

ha_to_ac(1)
#> [1] 2.471054
```
