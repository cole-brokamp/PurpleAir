
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PurpleAir

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
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
> service](https://www2.purpleair.com/policies/terms-of-service), [data
> license](https://www2.purpleair.com/pages/license), and [data
> attribution](https://www2.purpleair.com/pages/attribution)
> requirements when using PurpleAir data and this API. Please take a
> moment to review them and note the attribution guide and data license
> agreement. If you have any questions or need more information, we have
> an excellent resource at
> <https://community.purpleair.com/c/data/api/18>.

## Installation

Install PurpleAir from CRAN with:

``` r
install.packages("PurpleAir")
```

Install the latest development version of PurpleAir from GitHub with:

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
environment variable called `PURPLE_AIR_API_KEY`. To check your key,
use:

``` r
check_api_key(Sys.getenv("PURPLE_AIR_API_KEY"))
#> ✔ Using valid 'READ' key with version V1.0.14-0.0.58 of the PurpleAir API on 1728410515
```

Get the latest data from a single PurpleAir sensor, defined by its
[sensor
key](https://community.purpleair.com/t/sensor-indexes-and-read-keys/4000):

``` r
get_sensor_data(sensor_index = 175413,
                fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> $last_seen
#> [1] "2024-10-08 13:59:39 EDT"
#> 
#> $name
#> [1] "JN-Clifton,OH"
#> 
#> $pm2.5_atm
#> [1] 0.9
#> 
#> $pm2.5_cf_1
#> [1] 0.9
```

Get the latest data from many PurpleAir sensors, defined by their sensor
keys,

``` r
get_sensors_data(x = c(175257, 175413),
                 fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> # A tibble: 2 × 5
#>   sensor_index last_seen           name          pm2.5_atm pm2.5_cf_1
#>          <int> <dttm>              <chr>             <dbl>      <dbl>
#> 1       175257 2024-10-08 14:00:02 Lillard             1.4        1.4
#> 2       175413 2024-10-08 14:01:39 JN-Clifton,OH       1          1
```

a geographic [bounding box](http://bboxfinder.com),

``` r
sf::st_bbox(
  c(
    "xmin" = -84.82030,
    "ymin" = 39.02153,
    "xmax" = -84.25633,
    "ymax" = 39.31206
  ),
  crs = 4326
) |>
  get_sensors_data(fields = c("name"))
#> # A tibble: 56 × 2
#>    sensor_index name                
#>           <int> <chr>               
#>  1        35225 Mt. Washington      
#>  2       102568 SR32                
#>  3       103282 Carolina pines      
#>  4       111898 Bridgetown Sanctuary
#>  5       120311 Loveland            
#>  6       127885 Meals on Wheels     
#>  7       127915 MSD 6               
#>  8       127921 Groundwork          
#>  9       130719 NKU KY DAQ          
#> 10       156117 Tshs 1              
#> # ℹ 46 more rows
```

or a date from which sensors must have been modified since.

``` r
get_sensors_data(as.POSIXct(Sys.time()) - 60, fields = "name")
#> # A tibble: 568 × 2
#>    sensor_index name                                           
#>           <int> <chr>                                          
#>  1          978 Hillerød f989                                  
#>  2         1294 Roberts Creek                                  
#>  3         1638 Moab                                           
#>  4         2372 SCSB_22                                        
#>  5         2574 Berkeley Park and Coventry, Kensington, CA, USA
#>  6         3088 Howe Neighborhood                              
#>  7         3277 Shop                                           
#>  8         3497 Olive                                          
#>  9         5538 Hood River Weather                             
#> 10         6408 Amberwood                                      
#> # ℹ 558 more rows
```

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
#>  1 2024-07-03 23:40:00    2503.     1670.      1671.      2505. 
#>  2 2024-07-04 06:50:00    2504.     1670.      1671.      2505. 
#>  3 2024-07-03 22:10:00    2505.     1672.      1673.      2507. 
#>  4 2024-07-04 07:10:00    2503.     1670.      1671.      2504. 
#>  5 2024-07-04 09:40:00    2504.     1671.      1672.      2505. 
#>  6 2024-07-04 11:30:00    2504.     1671.      1673.      2506. 
#>  7 2024-07-04 03:40:00    2501.     1668.      1669.      2502. 
#>  8 2024-07-03 22:20:00    2504.     1671.      1673.      2506. 
#>  9 2024-07-04 03:00:00    2502.     1669.      1669.      2503. 
#> 10 2024-07-04 18:50:00       8.32      8.32      10.1       10.1
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

By default, the PurpleAir R package retries failed API requests related
to an underlying HTTP error (e.g., network is down) or a transient API
error (i.e., 429, 503). Before retrying each failed request, it waits
about 2 seconds. Successive failed requests result in exponentially
longer waiting times (`httr2::req_retry()`). Specify the maximum number
of seconds to wait (by default 45) with the environment variable
`PURPLE_AIR_API_RETRY_MAX_TIME`.
