# Tree list for a western redcedar forest

An example tree list for an FIA plot in a western redcedar forest.

## Usage

``` r
western_redcedar
```

## Format

### `western_redcedar`

A data frame with 33 rows and 12 columns:

- `PLT_CN`:

  [`character`](https://rdrr.io/r/base/character.html), Plot unique
  identifier

- `SUBP`:

  [`integer`](https://rdrr.io/r/base/integer.html), Subplot number

- `TREE`:

  [`integer`](https://rdrr.io/r/base/integer.html), Tree number

- `AZIMUTH`:

  [`integer`](https://rdrr.io/r/base/integer.html), Horizontal angle
  from subplot center to the stem location

- `DIST`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Distance in feet
  from subplot center to the stem location

- `STATUSCD`:

  [`integer`](https://rdrr.io/r/base/integer.html), Tree status code: 1
  = live, 2 = standing dead

- `SPCD`:

  [`integer`](https://rdrr.io/r/base/integer.html), FIA tree species
  code

- `DIA`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Tree diameter at
  breast height in inches

- `HT`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Tree height in feet

- `ACTUALHT`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Actual height in ft
  (ACTUALHT \< HT indicates a broken top)

- `CCLCD`:

  [`integer`](https://rdrr.io/r/base/integer.html), Tree crown class
  code

- `TPA_UNADJ`:

  [`numeric`](https://rdrr.io/r/base/numeric.html), Trees per acre
  expansion factor

## Source

<https://research.fs.usda.gov/programs/nfi>

## Note

A synthetic plot unique identifier is used in example tree list
datasets.

## Examples

``` r
plot_crowns(western_redcedar, main = "western redcedar plot")
```
