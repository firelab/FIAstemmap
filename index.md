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

Note that analysis or computation based on tree spatial pattern within a
plot require input data with coordinates of individual stems given as
aziumuth and distance from the sample center point. FIA no longer
provide `AZIMUTH` and `DIST` attributes in the publicly available FIADB
`TREE` table. The FIADB User Guide states that these attributes are now
available by request from [FIA Spatial Data
Services](https://research.fs.usda.gov/programs/fia/sds)
[\[14\]](#references). Tree data without stem locations can be used in
**FIAstemmap** with reduced functionality which includes predicting
individual tree crown width and computing several stand structure
metrics.

## Installation

You can install the development version of **FIAstemmap** with:

``` r
# install.packages("pak")
pak::pak("ctoney/FIAstemmap")
```

## Examples

### Predict crown width

The data frame `cw_coef` provides a curated set of linear regression
coefficients for predicting crown width from stem diameter of tree
species in the conterminous US. The crown width prediction method also
addresses potential issues in cases of extrapolation beyond the range of
the model fitting data. Details are given in the documentation for
[`calc_crwidth()`](https://ctoney.github.io/FIAstemmap/reference/calc_crwidth.md).
Input is a data frame of tree records which must have columns `SPCD`
(FIA integer species code), `STATUSCD` (FIA integer tree status code,
`1` = live) and `DIA` (FIA tree diameter in inches), here using the
`plantation` example tree list.

``` r
library(FIAstemmap)

# structure of the cw_coef dataset
str(cw_coef)
#> 'data.frame':    430 obs. of  8 variables:
#>  $ symbol     : chr  "ABAM" "ABCO" "ABGR" "ABLAA" ...
#>  $ SPCD       : num  11 15 17 18 19 20 21 22 41 62 ...
#>  $ common_name: chr  "Pacific silver fir" "white fir" "grand fir" "corkbark fir" ...
#>  $ surrogate  : chr  NA NA NA NA ...
#>  $ b0         : num  7.3 4.49 5.75 6.07 3.96 6.67 6.67 6.32 2.36 -2.12 ...
#>  $ b1         : num  0.59 0.92 1.11 0.37 0.64 0.43 0.43 0.65 0.99 1.73 ...
#>  $ b2         : num  0 -0.01 -0.01 0 0 0 0 0 0 -0.02 ...
#>  $ reference  : chr  "Bechtold (2004)" "Bechtold (2004)" "Bechtold (2004)" "Bechtold (2004)" ...

# add a column of predicted crown width to the plantation tree list
# `within()` is used to modify only a copy of the example dataset
tree_list <- within(plantation, CRWIDTH <- calc_crwidth(plantation))
str(tree_list)
#> 'data.frame':    91 obs. of  13 variables:
#>  $ PLT_CN   : chr  "61265063010478" "61265063010478" "61265063010478" "61265063010478" ...
#>  $ SUBP     : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ TREE     : int  4 1 2 3 5 6 10 7 8 9 ...
#>  $ AZIMUTH  : int  21 282 185 4 24 48 93 60 90 92 ...
#>  $ DIST     : num  22.7 9.1 10.1 22 11.7 14.9 22.4 19.5 9.5 16.3 ...
#>  $ STATUSCD : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ SPCD     : int  131 131 131 131 131 131 131 131 131 131 ...
#>  $ DIA      : num  6.7 7.7 6.1 9.5 8.2 5.9 5.6 5.1 9.3 8.1 ...
#>  $ HT       : int  41 45 42 50 46 44 41 42 48 48 ...
#>  $ ACTUALHT : int  41 45 42 50 46 44 41 42 48 48 ...
#>  $ CCLCD    : int  3 3 3 3 3 3 3 3 3 3 ...
#>  $ TPA_UNADJ: num  6.02 6.02 6.02 6.02 6.02 ...
#>  $ CRWIDTH  : num  11.8 13.2 11 15.7 13.9 10.7 10.3 9.6 15.4 13.7 ...
```

### Exploratory analysis

Plot-level visualization and other exploratory analyses require input
data with stem locations provided in columns `AZIMUTH` (horizontal angle
from subplot/microplot center to the stem location, in range `0:359`)
and `DIST` (stem distance from subplot/microplot center).

``` r
# display modeled tree crowns projected vertically on boundaries of the FIA
# four-subplot cluster design
plot_crowns(tree_list, main = "plantation plot")
```

![](reference/figures/README-plot-crowns-1.png)

``` r

# individual subplot
plot_crowns(tree_list, subplot = 4, main = "plantation subplot 4")
```

![](reference/figures/README-plot-crowns-2.png)

``` r

# or microplot
plot_crowns(tree_list, subplot = 4, microplot = TRUE,
            main = "plantation microplot 4")
```

![](reference/figures/README-plot-crowns-3.png)

Helper functions are provided to facilitate analyzing FIA tree lists as
Spatial Point Patterns using the **spatstat** library.
[`create_fia_ppp()`](https://ctoney.github.io/FIAstemmap/reference/spatstat_helpers.md)
returns an object of class `"ppp"` representing the point pattern of an
FIA tree list in the 2-D plane. This object can be used with functions
of package **spatstat.explore** for additional plotting capabilty,
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

plot(X, pch = 16, main = "Loblolly pine plantation")
```

![](reference/figures/README-spatstat-explore-1.png)

``` r

# compute Ripley's K-function applying isotropic edge correction
K <- spatstat.explore::Kest(X, rmax = 12, correction = "isotropic")

# plot estimated values of K(r) along with theoretical values for a completely
# random (Poisson) point process, suggestng spatial regularity in this case
plot(K, main = "Ripley's K for the plantation trees")
```

![](reference/figures/README-spatstat-explore-2.png)

### Compute stand structure metrics

### Data processing

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
