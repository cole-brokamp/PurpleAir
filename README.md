
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
#> ✔ Using valid 'READ' key with version V1.0.14-0.0.57 of the PurpleAir API on 2024-07-06 13:18:52
```

Get the latest data from a single PurpleAir sensor, defined by its
[sensor key](https://community.purpleair.com/t/sensor-index/4000):

``` r
get_sensor_data(sensor_index = 175413,
                fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> Waiting 2s for throttling delay ■■■■■■■■■■■■■■■
#> Waiting 2s for throttling delay ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#> $last_seen
#> [1] "2024-07-06 13:17:54 EDT"
#> 
#> $name
#> [1] "JN-Clifton,OH"
#> 
#> $pm2.5_atm
#> [1] 1.6
#> 
#> $pm2.5_cf_1
#> [1] 1.6
```

Get the latest data from many PurpleAir sensors, defined by their sensor
keys,

``` r
get_sensors_data(x = as.integer(c(175257, 175413)),
                 fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> Waiting 2s for throttling delay ■■■■■■■■■■■■■■■
#> Waiting 2s for throttling delay ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
#> # A tibble: 2 × 5
#>   sensor_index last_seen           name          pm2.5_atm pm2.5_cf_1
#>          <int> <dttm>              <chr>             <dbl>      <dbl>
#> 1       175257 2024-07-06 13:16:13 Lillard             1.2        1.2
#> 2       175413 2024-07-06 13:17:54 JN-Clifton,OH       1.6        1.6
```

a geographic bounding box,

or a date from which sensors must have been modified since.

Get the latest data from several PurpleAir sensors:

Get historical data from a single PurpleAir sensor:

``` r
my_history <-
  get_sensor_history(
    sensor_index = 175413,
    fields = c("pm1.0_cf_1", "pm1.0_atm", "pm2.5_cf_1", "pm2.5_atm"),
    start_timestamp = as.POSIXct("2024-07-02"),
    end_timestamp = as.POSIXct("2024-07-05")
  )

my_history
#> # A tibble: 432 × 5
#>    time_stamp          pm1.0_cf_1 pm1.0_atm pm2.5_atm pm2.5_cf_1
#>    <dttm>                   <dbl>     <dbl>     <dbl>      <dbl>
#>  1 2024-07-04 22:00:00     2512.     1678.     1682.      2516. 
#>  2 2024-07-04 21:20:00     2505.     1671.     1672.      2506. 
#>  3 2024-07-04 20:30:00       16.5      14.2      16.5       18.9
#>  4 2024-07-04 21:40:00     2509.     1675.     1679.      2512. 
#>  5 2024-07-04 22:30:00     2522.     1683.     1689.      2530. 
#>  6 2024-07-04 21:10:00     2505.     1671.     1672.      2506. 
#>  7 2024-07-04 20:40:00       31.9      25.3      27.9       34.6
#>  8 2024-07-04 23:30:00     2510.     1676.     1680.      2513. 
#>  9 2024-07-04 23:50:00     2509.     1675.     1678.      2512. 
#> 10 2024-07-04 23:20:00     2514.     1679.     1683.      2518. 
#> # ℹ 422 more rows
```

and plot it:

``` r
my_history |>
  tidyr::pivot_longer(cols = tidyr::starts_with("pm"), names_to = "pollutant", values_to = "concentration") |>
  ggplot2::ggplot(ggplot2::aes(time_stamp, concentration, color = pollutant)) +
  ggplot2::geom_line()
```

<img src="man/figures/README-example_sensor_history_plot-1.png" width="100%" />
