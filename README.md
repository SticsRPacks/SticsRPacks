
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SticsRPacks <a href='https://sticsrpacks.github.io/SticsRPacks/'><img src='man/figures/logo.png' align="right" height="138.5" /></a>

<!-- badges: start -->

[![R build
status](https://github.com/SticsRPacks/SticsRPacks/workflows/R-CMD-check/badge.svg)](https://github.com/SticsRPacks/SticsRPacks/actions)
<!-- badges: end -->

## Overview

SticsRPacks is a set of packages that work in harmony because they share
common data representations and API design. The **SticsRPacks** package
is designed to make it easy to install and load core packages from
SticsRPacks in a single command.

If you’d like to learn how to use the SticsRPacks packages, the best
place to start are the vignettes that come along the packages, and also
available from each websites (Article sections).

> This package is heavily inspired from the tidyverse
> [package](https://github.com/tidyverse/tidyverse).

## Installation

``` r
# # Install from CRAN
# install.packages("SticsRPacks")

# Or the development version from GitHub
# install.packages("devtools")
devtools::install_github("SticsRPacks/SticsRPacks")
```

It this does not work, follow the instructions given
[here](https://github.com/SticsRPacks/SticsRPacks/issues/1#event-2864068985).

## Usage

`library(SticsRPacks)` will load the core SticsRPacks packages:

  - [SticsRFiles](https://github.com/SticsRPacks/SticsRFiles), for files
    manipulation.  
  - [SticsOnR](https://github.com/SticsRPacks/SticsOnR), for STICS
    simulation management.  
  - [CroPlotR](https://github.com/SticsRPacks/CroPlotR), for plotting
    and statistics.  
  - [CroptimizR](https://github.com/SticsRPacks/CroptimizR), for
    parameter optimization.

You also get a condensed summary of conflicts with other packages you
have loaded:

``` r
library(SticsRPacks)
#> -- Attaching packages -------------------------------- SticsRPacks 0.0.1.9000 --
#> v SticsRFiles 0.1.0.9004     v SticsOnR    0.1.0.9005
#> v CroptimizR  0.2.0.9000     v CroPlotR    0.5.0
#> 
```

You can see conflicts created later with `SticsRPacks_conflicts()`:

``` r
library(MASS)
SticsRPacks_conflicts()
```

And you can check that all SticsRPacks packages are up-to-date with
`SticsRPacks_update()`:

``` r
SticsRPacks_update()
#> The following packages are out of date:
#>  * SticsRFiles (0.4.0 -> 0.4.1)
#>  * CroptimizR (0.4.1 -> 0.5)
#> Update now?
#> 
#> 1: Yes
#> 2: No
```

## Code of Conduct

Please note that the SticsRPacks project is released with a [Contributor
Code of
Conduct](https://github.com/SticsRPacks/.github/blob/master/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.
