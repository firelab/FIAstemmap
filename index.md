# FIAstemmap

**NOTE: this is an implementation update *currently under development***

The Forest Inventory and Analysis Program
([FIA](https://research.fs.usda.gov/programs/nfi)) of USDA Forest
Service provide tree-level measurements from a systematic grid of field
plots across all forest ownerships and land uses in the US.

**FIAstemmap** is an R package for mapping tree stem locations on FIA
plots, modeling individual crown dimensions, and generating plot-level
estimates of fractional tree canopy cover. Several stand height metrics
can also be calculated. Spatial analysis of tree point pattern is
facilitated for the standard FIA four-point cluster plot design.
Efficient data processing is intended to support national applications.
The package provides an updated implementation of the software
originally described by Toney et al. 2009 [\[1\]](#references). The
original implementation for predicting canopy cover from individual tree
measurements has supported several applications of FIA data, including:

- LANDFIRE vegetation classification and tree canopy cover mapping [\[2,
  3, 4, 5\]](#references)
- National Land Cover Database (NLCD) Tree Canopy Cover science and
  development [\[6, 7\]](#references)
- wildlife habitat analysis [\[8, 9, 10\]](#references)
- mapping erosion risk [\[11\]](#references)
- assessment of tree canopy cover estimation methods [\[12,
  13\]](#references)

Computations based on tree spatial pattern within a plot require input
data with coordinates of the individual stems given as azimuth and
distance from the sample center point. Note that FIA no longer provide
the `AZIMUTH` and `DIST` attributes in the publicly available `TREE`
table. The FIADB User Guide states that these attributes are now
available by request from [FIA Spatial Data
Services](https://research.fs.usda.gov/programs/fia/sds)
[\[14\]](#references). Tree data lacking stem locations can be used with
**FIAstemmap** for certain functionality, which includes predicting
individual tree crown width and computing several stand structure
metrics.

## Installation

You can install the development version of **FIAstemmap** with:

``` r
# install.packages("pak")
pak::pak("firelab/FIAstemmap")
```

## Examples

### Predict tree crown width

The data frame `cw_coef` contains a curated set of linear regression
coefficients for predicting crown width from stem diameter of tree
species in the conterminous US (see
[`?cw_coef`](https://firelab.github.io/FIAstemmap/reference/cw_coef.md)).
The method for crown width prediction attempts to avoid extrapolation
beyond the range of the model fitting data by providing reasonable fall
backs for the obvious cases. Details are given in the documentation for
[`calc_crwidth()`](https://firelab.github.io/FIAstemmap/reference/calc_crwidth.md).
The input is a data frame of tree records which must have columns `SPCD`
(FIA integer species code), `STATUSCD` (FIA integer tree status code,
`1` = live) and `DIA` (FIA tree diameter in inches). The `plantation`
dataset used here is an example tree list included in the package.

``` r
library(FIAstemmap)

# included regression coefficients for estimating tree crown width from diameter
# see `?cw_coef`
head(cw_coef)
#>   symbol SPCD        common_name surrogate   b0   b1    b2          reference
#> 1   ABAM   11 Pacific silver fir      <NA> 7.30 0.59  0.00    Bechtold (2004)
#> 2   ABCO   15          white fir      <NA> 4.49 0.92 -0.01    Bechtold (2004)
#> 3   ABGR   17          grand fir      <NA> 5.75 1.11 -0.01    Bechtold (2004)
#> 4  ABLAA   18       corkbark fir      <NA> 6.07 0.37  0.00    Bechtold (2004)
#> 5   ABLA   19      subalpine fir      <NA> 3.96 0.64  0.00    Bechtold (2004)
#> 6   ABMA   20 California red fir      <NA> 6.67 0.43  0.00 Gill et al. (2000)

# add a column predicted crown widths to the `plantation` tree list
# `within()` is used to modify only a copy of the example dataset
tree_list <- within(plantation, CRWIDTH <- calc_crwidth(plantation))
str(tree_list)
#> 'data.frame':    91 obs. of  13 variables:
#>  $ PLT_CN   : chr  "601960719718" "601960719718" "601960719718" "601960719718" ...
#>  $ SUBP     : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ TREE     : int  4 1 2 3 5 6 10 7 8 9 ...
#>  $ AZIMUTH  : int  21 282 185 4 24 48 93 60 90 92 ...
#>  $ DIST     : num  22.7 9.1 10.1 22 11.7 14.9 22.4 19.5 9.5 16.3 ...
#>  $ STATUSCD : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ SPCD     : int  131 131 131 131 131 131 131 131 131 131 ...
#>  $ DIA      : num  6.8 7.6 6 9.6 8.1 6 5.5 5.2 9.2 8.2 ...
#>  $ HT       : num  42 44 41 50 45 45 40 43 47 49 ...
#>  $ ACTUALHT : num  42 44 41 50 45 45 40 43 47 49 ...
#>  $ CCLCD    : int  3 3 3 3 3 3 3 3 3 3 ...
#>  $ TPA_UNADJ: num  6.02 6.02 6.02 6.02 6.02 ...
#>  $ CRWIDTH  : num  11.9 13 10.8 15.8 13.7 10.8 10.2 9.7 15.3 13.9 ...
```

### Exploratory analysis

Plot-level visualization and other exploratory analyses require input
data with individual stem locations given in columns named `AZIMUTH`
(horizontal angle from subplot/microplot center, `0:359`) and `DIST`
(distance from subplot/microplot center).

``` r
# display modeled tree crowns projected vertically on the FIA plot boundary
plot_crowns(tree_list, main = "Loblolly pine plantation")
```

![](reference/figures/README-plot-crowns-1.png)

``` r

# individual subplot
plot_crowns(tree_list, subplot = 4,
            main = "Loblolly pine plantation subplot 4")
```

![](reference/figures/README-plot-crowns-2.png)

``` r

# or microplot
plot_crowns(tree_list, subplot = 4, microplot = TRUE,
            main = "Loblolly pine plantation microplot 4")
```

![](reference/figures/README-plot-crowns-3.png)

Helper functions facilitate the analysis of FIA tree lists as Spatial
Point Patterns using the **spatstat** library.
[`create_fia_ppp()`](https://firelab.github.io/FIAstemmap/reference/spatstat_helpers.md)
returns an object of class `"ppp"` representing the point pattern of an
FIA tree list in the 2-D plane. This object can be used with functions
of **spatstat.explore** which provide additional plotting capabilities,
computation of descriptive spatial statistics, and other exploratory
data analysis.

``` r
# point pattern object for the plantation tree list
X <- create_fia_ppp(plantation)
summary(X)
#> Planar point pattern:  89 points
#> Average intensity 0.01229542 points per square foot
#> 
#> Coordinates are given to 16 decimal places
#> 
#> Window: polygonal boundary
#> 4 separate polygons (no holes)
#>            vertices    area relative.area
#> polygon 1       360 1809.62          0.25
#> polygon 2       360 1809.62          0.25
#> polygon 3       360 1809.62          0.25
#> polygon 4       360 1809.62          0.25
#> enclosing rectangle: [-127.921, 127.921] x [-84.001, 144.001] feet
#>                      (255.8 x 228 feet)
#> Window area = 7238.47 square feet
#> Unit of length: 1 foot
#> Fraction of frame area: 0.124

plot(X, pch = 16, background = "#EEE9DF", main = "plantation point pattern")
```

![](reference/figures/README-spatstat-explore-1.png)

``` r

# compute Ripley's K-function applying isotropic edge correction
K <- spatstat.explore::Kest(X, rmax = 12, correction = "isotropic")

# plot estimated K(r) along with theoretical values for a completely random
# point process, suggesting spatial regularity in this case
plot(K, main = "Ripley's K for the plantation trees")
```

![](reference/figures/README-spatstat-explore-2.png)

### Compute stand structure metrics

``` r
## compute fractional tree canopy cover of a specific sampled area by overlaying
## modeled crowns

# subplot 1 of the `plantation` plot (contains only live trees)
tree_list[tree_list$SUBP == 1 & tree_list$DIA >= 5, ] |>
  calc_crown_overlay(sample_radius = 24)
#> [1] 86.8

## calculate stand height metrics, which are also included by default in the
## output of `calc_tcc_metrics()` (see below)

# calc_ht_metrics(plantation)

## predict plot-level canopy cover from individual tree measurements

# by default, TCC predicted with the "stem-map" model and full output returned
calc_tcc_metrics(plantation)
#> $model_tcc
#> [1] 88.4
#> 
#> $subp1_crown_overlay
#> [1] 86.8
#> 
#> $subp2_crown_overlay
#> [1] 91.7
#> 
#> $subp3_crown_overlay
#> [1] 80.2
#> 
#> $subp4_crown_overlay
#> [1] 87.2
#> 
#> $subp_overlay_mean
#> [1] 86.475
#> 
#> $micr1_crown_overlay
#> [1] 0
#> 
#> $micr2_crown_overlay
#> [1] 0
#> 
#> $micr3_crown_overlay
#> [1] 20.2
#> 
#> $micr4_crown_overlay
#> [1] 22.5
#> 
#> $micr_overlay_mean
#> [1] 10.675
#> 
#> $L_6ft
#> [1] 3.868305
#> 
#> $L_8ft
#> [1] 6.627377
#> 
#> $L_10ft
#> [1] 7.300455
#> 
#> $L_12ft
#> [1] 11.35045
#> 
#> $numTrees
#> [1] 89
#> 
#> $meanTreeHt
#> [1] 44.8
#> 
#> $meanTreeHtBAW
#> [1] 45.3
#> 
#> $meanTreeHtDom
#> [1] 44.8
#> 
#> $meanTreeHtDomBAW
#> [1] 45.3
#> 
#> $maxTreeHt
#> [1] 51
#> 
#> $predomTreeHt
#> [1] 50.7
#> 
#> $numSaplings
#> [1] 2
#> 
#> $meanSapHt
#> [1] 34.5
#> 
#> $maxSapHt
#> [1] 43

# return only the predicted TCC value (`$model_tcc`)
calc_tcc_metrics(plantation, full_output = FALSE)
#> [1] 88.4

# using the "FVS method", which assumes that trees are randomly located
calc_tcc_metrics(plantation, stem_map = FALSE, full_output = FALSE)
#> [1] 81.4
```

### Data processing

``` r
## load tree data from a file or database connection
f <- system.file("extdata/mt_lnf_2022_1cond_tree.csv", package="FIAstemmap")
tree <- load_tree_data(f)
#> ! The data source does not have DIST and/or AZIMUTH
#> ℹ Fetching tree data...
#> ✔ Fetching tree data... [15ms]
#> 
#> ℹ 910 tree records returned

head(tree)
#>            PLT_CN SUBP TREE STATUSCD SPCD DIA HT ACTUALHT CCLCD TPA_UNADJ
#> 1 670951075126144    1    1        2  108  NA NA       NA    NA        NA
#> 2 670951075126144    1    2        1  108   1  9        9     3  74.96528
#> 3 670951075126144    2    1        2  108  NA NA       NA    NA        NA
#> 4 670951075126144    2    2        2  108  NA NA       NA    NA        NA
#> 5 670951075126144    2    3        2  108  NA NA       NA    NA        NA
#> 6 670951075126144    2    4        2  108  NA NA       NA    NA        NA

## process tree data

# TODO...
```

## References

\[1\] Toney, Chris; Shaw, John D.; Nelson, Mark D. 2009. A stem-map
model for predicting tree canopy cover of Forest Inventory and Analysis
(FIA) plots. In: McWilliams, Will; Moisen, Gretchen; Czaplewski, Ray,
comps. *Forest Inventory and Analysis (FIA) Symposium 2008*; October
21-23, 2008; Park City, UT. Proc. RMRS-P-56CD. Fort Collins, CO: U.S.
Department of Agriculture, Forest Service, Rocky Mountain Research
Station. 19 p. Available:
<https://research.fs.usda.gov/treesearch/33381>.

\[2\] LANDFIRE: LANDFIRE Existing Vegetation Cover layer. (LF2024
version released 2025 - last update). U.S. Department of Interior,
Geological Survey, and U.S. Department of Agriculture. \[Online\].
Available: <https://landfire.gov/vegetation/evc> \[accessed 2026, Feb
24\].

\[3\] Moore, Annabelle; La Puma, Inga; Dillon, Greg; Smail, Tobin;
Schleeweis, Karen; Toney, Chris; Menakis, Jim; Bastian, Henry; Picotte,
Josh; Dockter, Daryn; Tolk, Brian. 2024. Twenty years of science and
management with LANDFIRE. Connected Science, October 2024. Fort Collins,
CO: U.S. Department of Agriculture, Forest Service, Rocky Mountain
Research Station. 2 p. Available:
<https://research.fs.usda.gov/treesearch/68397>.

\[4\] Vogelmann, Jim & Kost, Jay & Tolk, Brian & Howard, Stephen &
Short, Karen & Chen, Xuexia & Huang, Chengquan & Pabst, Kari & Rollins,
Matthew. (2011). Monitoring Landscape Change for LANDFIRE Using
Multi-Temporal Satellite Imagery and Ancillary Data. *Selected Topics in
Applied Earth Observations and Remote Sensing, IEEE Journal of*. 4.
252-264. 10. <https://doi.org/10.1109/JSTARS.2010.2044478>.

\[5\] Nelson, K.J., Connot, J., Peterson, B. et al. 2013. The LANDFIRE
Refresh Strategy: Updating the National Dataset. *Fire Ecology*, 9,
80-101, <https://doi.org/10.4996/fireecology.0902080>.

\[6\] Toney, Chris; Liknes, Greg; Lister, Andy; Meneguzzo, Dacia. 2012.
Assessing alternative measures of tree canopy cover: Photo-interpreted
NAIP and ground-based estimates. In: McWilliams, Will; Roesch, Francis
A. eds. 2012. *Monitoring Across Borders: 2010 Joint Meeting of the
Forest Inventory and Analysis (FIA) Symposium and the Southern
Mensurationists*. e-Gen. Tech. Rep. SRS-157. Asheville, NC: U.S.
Department of Agriculture, Forest Service, Southern Research Station.
209-215. Available: <https://research.fs.usda.gov/treesearch/41009>.

\[7\] Derwin, J.M., Thomas, V.A., Wynne, R.H., Coulston, J.W., Liknes,
G.C., Bender, S., Blinn, C.E., Brooks, E.B., Ruefenacht, B., Benton, R.
and Finco, M.V., 2020. Estimating tree canopy cover using harmonic
regression coefficients derived from multitemporal Landsat data.
*International Journal of Applied Earth Observation and Geoinformation*,
86, 101985, <https://doi.org/10.1016/j.jag.2019.101985>.

\[8\] Tavernia, B., Nelson, M., Goerndt, M., Walters, B., & Toney, C.
(2013). Changes in forest habitat classes under alternative climate and
land-use change scenarios in the northeast and midwest, USA.
*Mathematical and Computational Forestry & Natural-Resource Sciences*
(MCFNS), 5:2, 135-150. Retrieved from
<https://www.mcfns.com/index.php/Journal/article/view/MCFNS_165>.

\[9\] Rowland, M.M.; Vojta, C.D.; tech. eds. 2013. A technical guide for
monitoring wildlife habitat. Gen. Tech. Rep. WO-89. Washington, DC: U.S.
Department of Agriculture, Forest Service: 400 p. Available:
<https://doi.org/10.2737/WO-GTR-89>.

\[10\] Michael C. McGrann, Bradley Wagner, Matthew Klauer, Kasia Kaphan,
Erik Meyer, Brett J. Furnas. 2022. Using an acoustic complexity index to
help monitor climate change effects on avian diversity. *Ecological
Indicators*, Volume 142, 109271,
<https://doi.org/10.1016/j.ecolind.2022.109271>.

\[11\] McGwire KC, Weltz MA, Nouwakpo S, Spaeth K, Founds M, Cadaret E.
2020. Mapping erosion risk for saline rangelands of the Mancos Shale
using the rangeland hydrology erosion model. *Land Degradation &
Development*. 31: 2552-2564, <https://doi.org/10.1002/ldr.3620>.

\[12\] Riemann, R., Liknes, G., O’Neil-Dunne, J., Toney, C., Lister, T.
(2016). Comparative assessment of methods for estimating tree canopy
cover across a rural-to-urban gradient in the mid-Atlantic region of the
USA. *Environmental Monitoring and Assessment*, 188, 297,
<https://doi.org/10.1007/s10661-016-5281-8>.

\[13\] Andrew N. Gray, Anne C.S. McIntosh, Steven L. Garman, Michael A.
Shettles. 2021. Predicting canopy cover of diverse forest types from
individual tree measurements. *Forest Ecology and Management*, Volume
501, 119682, ISSN 0378-1127,
<https://doi.org/10.1016/j.foreco.2021.119682>.

\[14\] Burrill, Elizabeth A.; DiTommaso, Andrea M.; Turner, Jeffery A.;
Pugh, Scott A.; Christensen, Glenn; Kralicek, Karin M.; Perry, Carol J.;
Lepine, Lucie C.; Walker, David M.; Conkling, Barbara L. 2024. The
Forest Inventory and Analysis Database, FIADB user guides, volume:
database description (version 9.4), nationwide forest inventory (NFI).
U.S. Department of Agriculture, Forest Service. 1016 p. \[Online\].
Available at:
<https://research.fs.usda.gov/understory/forest-inventory-and-analysis-database-user-guide-nfi>.
