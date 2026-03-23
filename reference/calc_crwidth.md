# Predict tree crown widths using species-specific equations

`calc_crwidth()` computes tree crown width using species-specific
regression equations from the literature.

## Usage

``` r
calc_crwidth(tree_list, digits = 1)
```

## Arguments

- tree_list:

  A data frame containing tree records. Must have columns `SPCD` (FIA
  integer species code), `STATUSCD` (FIA integer tree status code, 1 =
  live) and `DIA` (FIA tree diameter in inches).

- digits:

  Optional integer indicating the number of digits to keep in the return
  values (defaults to `1`).

## Value

A numeric vector of length `nrow(tree_list)` with predicted crown width
in feet for live trees. `NA` is returned for trees with `STATUSCD != 1`.

## Details

Crown width is predicted from tree diameter using coefficients provided
in the lookup table
[cw_coef](https://ctoney.github.io/FIAstemmap/reference/cw_coef.md) (see
[`?cw_coef`](https://ctoney.github.io/FIAstemmap/reference/cw_coef.md))
The method also incorporates adjustment factors used to derive crown
width estimates for FIA "saplings", i.e., trees less than 5.0 in. (12.7
cm) diameter but greater than or equal to 1.0 in. (2.54 cm) diameter.
Details are described in the documentation for the lookup table
[cw_sapling_adj](https://ctoney.github.io/FIAstemmap/reference/cw_sapling_adj.md).

Large diameter trees in the temperate rain forests of the Pacific
Northwest region can far exceed the range of diameters in the broadly
applicable datasets that have been used to develop crown width
prediction equations (Bechold 2003, 2004). To avoid extrapolation beyond
the range of the model fitting data in those cases, `calc_crwidth()`
makes use of the "old growth" equation presented by Gill et al. (2000)
to estimate crown width for nine tree species when their diameter is
greater than 50 in. (127 cm).

## References

Bechtold, W.A. 2003. Crown-Diameter Prediction Models for 87 Species of
Stand-Grown Trees in the Eastern United States. *Southern Journal of
Applied Forestry*, 27(4): 269-278.

Bechtold, W.A. 2004. Largest-Crown-Width Prediction Models for 53
Species in the Western United States. *Western Journal of Applied
Forestry*, 19(4): 245-251.

Gill, S.J., G.S. Biging, E.C. Murphy. 2000. Modeling conifer tree crown
radius and estimating canopy cover. *Forest Ecology and Management*,
126(3): 405-416.

## See also

[cw_coef](https://ctoney.github.io/FIAstemmap/reference/cw_coef.md),
[cw_sapling_adj](https://ctoney.github.io/FIAstemmap/reference/cw_sapling_adj.md)

## Examples

``` r
calc_crwidth(plantation)
#>  [1] 11.8 13.2 11.0 15.7 13.9 10.7 10.3  9.6 15.4 13.7 12.4 12.1 12.9  9.6 14.3
#> [16] 14.6 12.1 11.0 12.6 12.9 10.6 15.3 10.0 12.6 12.1 13.2 10.4 14.0 11.8 14.7
#> [31] 11.1 14.0 11.9 12.2 11.9 14.3 10.7 10.0 14.2 11.9 11.3 14.2 13.6 11.4 13.9
#> [46] 15.7 10.8 11.7 10.3 14.7 14.4 13.7 11.1 13.2 11.5 10.4 14.2 11.1 13.9 13.2
#> [61] 13.0 13.6 11.8 11.7  9.9 13.0  7.6 13.7 11.3 10.7 12.8 14.8 12.8 11.5 12.6
#> [76]  9.9 14.7 11.4 10.4 11.1 12.1 14.0 11.5 12.1 12.8 10.7 13.2 12.8 11.4  9.6
#> [91]  8.5
```
