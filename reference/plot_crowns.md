# Display modeled tree crowns vertically projected on subplot boundaries

`plot_crowns()` draws vertically projected tree crowns as discs overlaid
on subplot or microplot boundaries. The full four-subplot cluster, or
individual subplots, can be displayed with trees `>= 5.0` in. (`12.7`
cm) diameter, or individual microplots can be display with saplings
(i.e., trees `< 5` in. diameter).

## Usage

``` r
plot_crowns(
  tree_list,
  subplot = NULL,
  microplot = FALSE,
  linear_unit = "ft",
  main = ""
)
```

## Arguments

- tree_list:

  A data frame with tree records for one FIA plot. Must have columns
  `SUBP` (FIA subplot number), `STATUSCD` (FIA integer tree status, `1`
  = live), `DIA` (tree diameter), `HT` (tree height), `ACTUALHT` (tree
  actual height, `ACTUALHT < HT` indicating a broken top), `DIST` (stem
  distance from subplot/microplot center), `AZIMUTH` (horizontal angle
  from subplot/microplot center to the stem location, in the range
  `0:359`), and `CRWIDTH` (tree crown width).

- subplot:

  Optional integer subplot number in the range `1:4` indicating a
  specific subplot for display. May be `NULL` or `NA` to display the
  full four-point cluster.

- microplot:

  A logical value, `TRUE` to display the modeled crowns of saplings
  overlaid of the microplot boundary of `subplot = n`. The default is
  `FALSE`. Ignored if `subplot` is not specified.

- linear_unit:

  An optional character string specifying the linear distance unit.
  Defaults to the native FIA unit of `"ft"`, but may be set to `"m"`
  instead (or `"meter"` / `"metre"`), in which case subplot boundaries
  will be display in meters, tree heights and crown widths are assumed
  to be given in meters, and tree diameters are assumed to be given in
  centimeters. **TODO: not currently implemented**

- main:

  Character string giving the main plot title (on top).

## Value

The input, invisibly.

## Examples

``` r
trees <- within(plantation, CRWIDTH <- predict_crwidth(plantation))

plot_crowns(trees, main = "plantation plot")


plot_crowns(trees, subplot = 4, main = "plantation subplot 4")


plot_crowns(trees, subplot = 4, microplot = TRUE,
            main = "plantation microplot 4")
```
