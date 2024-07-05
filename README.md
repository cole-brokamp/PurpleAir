
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PurpleAir

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/PurpleAir)](https://CRAN.R-project.org/package=PurpleAir)
[![R-CMD-check](https://github.com/cole-brokamp/PurpleAir/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cole-brokamp/PurpleAir/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of PurpleAir is to provide read access to the [PurpleAir
API](https://api.purpleair.com/)

## Installation

Install the development version of PurpleAir with:

``` r
pak::pak("cole-brokamp/PurpleAir")
```

Querying data from the PurpleAir API requires a free [PurpleAir
Developer API
key](https://develop.purpleair.com/sign-in?redirectURL=%2Fdashboards%2Fkeys)
linked to a Google account.

## Usage

``` r
library(PurpleAir)
```

Get the latest data from a single PurpleAir sensor, defined by its
[sensor key](https://community.purpleair.com/t/sensor-index/4000):

``` r
get_sensor_data(sensor_index = 175413,
                fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> $last_seen
#> [1] "2024-07-05 14:11:43 EDT"
#> 
#> $name
#> [1] "JN-Clifton,OH"
#> 
#> $pm2.5_atm
#> [1] 3.8
#> 
#> $pm2.5_cf_1
#> [1] 3.8
```

Get the latest data from many PurpleAir sensors, defined by their sensor
keys,

``` r
get_sensors_data(x = as.integer(c(175257, 175413)),
                 fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> # A tibble: 2 × 5
#>   sensor_index last_seen           name          pm2.5_atm pm2.5_cf_1
#>          <int> <dttm>              <chr>             <dbl>      <dbl>
#> 1       175257 2024-07-05 14:12:00 Lillard             3.7        3.7
#> 2       175413 2024-07-05 14:11:43 JN-Clifton,OH       3.8        3.8
```

a geographic bounding box,

or a date from which sensors must have been modified since.
