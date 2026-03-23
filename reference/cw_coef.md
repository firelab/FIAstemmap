# Regression coefficients for predicting tree crown width

A curated set of linear regression coefficients for predicting crown
width from stem diameter of tree species in the conterminous US.

## Usage

``` r
cw_coef
```

## Format

### `cw_coef`

A data frame with 430 rows and 8 columns:

- `symbol`:

  [`character`](https://rdrr.io/r/base/character.html), USDA PLANTS
  Database species symbol

- `SPCD`:

  [`integer`](https://rdrr.io/r/base/integer.html), FIA tree species
  code or `-1`

- `common_name`:

  [`character`](https://rdrr.io/r/base/character.html), FIA tree species
  common name

- `surrogate`:

  [`character`](https://rdrr.io/r/base/character.html), Common name of
  surrogate species if applicable

- `b0`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Regression b0
  coefficient

- `b1`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Regression b1
  coefficient

- `b2`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Regression b2
  coefficient

- `reference`:

  [`character`](https://rdrr.io/r/base/character.html), Literature
  source of the species coefficients (see References)

## Source

Toney et al. 2009. A stem-map model for predicting tree canopy cover of
Forest Inventory and Analysis (FIA) plots.
<https://research.fs.usda.gov/treesearch/33381>.

## Details

The regression equation is of the general form:

    CW = b0 + b1 * DIA + b2 * DIA^2

where `CW` is the predicted tree crown diameter in feet, `DIA` is FIA
stem diameter in inches, and `b0`, `b1`, `b2` are the regression
coefficients. The quadratic term `b2` is not included in the regression
models for some species, and has been assigned `0` in that case for
purposes of this lookup table.

In cases that species-specific equations were not available in the
literature, surrogate species were assigned based on subjectively
similar tree physiognomy.

## References

Bechtold, W.A. 2003. Crown-diameter prediction models for 87 species of
stand-grown trees in the eastern United States. *Southern Journal of
Applied Forestry*, 27(4): 269-278.

Bechtold, W.A. 2004. Largest-crown-width prediction models for 53
species in the western United States. *Western Journal of Applied
Forestry*, 19(4): 245-251.

Gill, S.J., G.S. Biging, E.C. Murphy. 2000. Modeling conifer tree crown
radius and estimating canopy cover. *Forest Ecology and Management*,
126(3): 405-416.

## Examples

``` r
cw_coef[cw_coef$SPCD == 17, ]
#>   symbol SPCD common_name surrogate   b0   b1    b2       reference
#> 3   ABGR   17   grand fir      <NA> 5.75 1.11 -0.01 Bechtold (2004)
```
