# Sapling crown width adjustment factors

A species-specific lookup table of estimated crown width (CW) adjustment
factors for saplings based on data from Bragg (2001).

## Usage

``` r
cw_sapling_adj
```

## Format

### `cw_sapling_adj`

A data frame with 23 rows and 5 columns:

- `SPCD`:

  [`integer`](https://rdrr.io/r/base/integer.html), FIA tree species
  code

- `adj_1inch`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), CW adjustment factor
  at 1 in. DIA relative to 5 in. DIA

- `adj_2inch`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), CW adjustment factor
  at 2 in. DIA relative to 5 in. DIA

- `adj_3inch`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), CW adjustment factor
  at 3 in. DIA relative to 5 in. DIA

- `adj_4inch`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), CW adjustment factor
  at 4 in. DIA relative to 5 in. DIA

## Source

Toney et al. 2009. A stem-map model for predicting tree canopy cover of
Forest Inventory and Analysis (FIA) plots.
<https://research.fs.usda.gov/treesearch/33381>.

## Details

FIA "saplings" are trees less than 5.0 in. (12.7 cm) diameter but
greater than or equal to 1.0 in. (2.54 cm) diameter. In general, the
data available to fit regression models predicting crown width (e.g.,
Bechtold 2003, 2004, see
[cw_coef](https://ctoney.github.io/FIAstemmap/reference/cw_coef.md)) do
not include trees with diameter less than 5.0 in. (12.7 cm).
Extrapolating beyond the range of the model fitting data is undesirable,
especially since a quadratic term is used in the regression equations
for some species.

Adjustment is based on the proportion of crown width predicted at 5-in.
(12.7 cm), at each 1-in. (2.54 cm) increment below that. Intermediate
values are interpolated in the crown width prediction method. Mean
adjustment factors are used if a species-specific adjustment is not
available.

## References

Bragg, D.C. 2001. A local basal area adjustment for crown width
prediction. *Northern Journal of Applied Forestry* 18(1):22-28.

## Examples

``` r
# Tsuga canadensis
cw_coef[cw_coef$SPCD == 261, ]
#>     symbol SPCD     common_name surrogate   b0  b1    b2       reference
#> 154   TSCA  261 eastern hemlock      <NA> 5.66 1.5 -0.02 Bechtold (2003)

cw_sapling_adj[cw_sapling_adj$SPCD == 261, ]
#>   SPCD adj_1inch adj_2inch adj_3inch adj_4inch
#> 9  261      0.42      0.61      0.75      0.88
```
