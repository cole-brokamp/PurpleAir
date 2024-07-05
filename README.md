
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
API](https://api.purpleair.com/) to retrieve real-time and historical
data from PurpleAir sensors.

Please note that usage of this package must abide by the requirements of
the PurpleAir API. From their website:

> PurpleAir was founded on principles of openness, sharing, and
> community. It is to strengthen these principles and ensure the success
> of our entire community that we put together updated [terms of
> service](https://www.purpleair.com/terms), [data
> license](https://www.purpleair.com/license), and [data
> attribution](https://www.purpleair.com/attribution) requirements when
> using PurpleAir data and this API. Please take a moment to review them
> and note the attribution guide and data license agreement. If you have
> any questions or need more information, we have an excellent resource
> at <https://community.purpleair.com/c/data/api/>.

## Installation

Install the development version of PurpleAir with:

``` r
pak::pak("cole-brokamp/PurpleAir")
```

## Usage

``` r
library(PurpleAir)
```

Querying data from the PurpleAir API requires a free [PurpleAir
Developer API
key](https://develop.purpleair.com/sign-in?redirectURL=%2Fdashboards%2Fkeys)
linked to a Google account. Functions in the package each take a
`purple_air_api_key` argument or your key can be stored in an
environment variable called `PURPLE_AIR_API_KEY`). To check your key,
use:

``` r
check_api_key(Sys.getenv("PURPLE_AIR_API_KEY"))
#> ✔ Using valid 'READ' key with version V1.0.14-0.0.57 of the PurpleAir API on 2024-07-05 14:44:18
```

Get the latest data from a single PurpleAir sensor, defined by its
[sensor key](https://community.purpleair.com/t/sensor-index/4000):

``` r
get_sensor_data(sensor_index = 175413,
                fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> $last_seen
#> [1] "2024-07-05 14:41:43 EDT"
#> 
#> $name
#> [1] "JN-Clifton,OH"
#> 
#> $pm2.5_atm
#> [1] 4.6
#> 
#> $pm2.5_cf_1
#> [1] 4.6
```

Get the latest data from many PurpleAir sensors, defined by their sensor
keys,

``` r
get_sensors_data(x = as.integer(c(175257, 175413)),
                 fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> # A tibble: 2 × 5
#>   sensor_index last_seen           name          pm2.5_atm pm2.5_cf_1
#>          <int> <dttm>              <chr>             <dbl>      <dbl>
#> 1       175257 2024-07-05 14:42:00 Lillard             3.9        3.9
#> 2       175413 2024-07-05 14:41:43 JN-Clifton,OH       4.6        4.6
```

a geographic bounding box,

or a date from which sensors must have been modified since.
