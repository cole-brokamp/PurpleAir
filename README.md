
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
#> ✔ Using valid 'READ' key with version V1.0.14-0.0.57 of the PurpleAir API on 2024-07-07 19:17:31
```

Get the latest data from a single PurpleAir sensor, defined by its
[sensor key](https://community.purpleair.com/t/sensor-index/4000):

``` r
get_sensor_data(sensor_index = 175413,
                fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> $last_seen
#> [1] "2024-07-07 19:16:12 EDT"
#> 
#> $name
#> [1] "JN-Clifton,OH"
#> 
#> $pm2.5_atm
#> [1] 19.1
#> 
#> $pm2.5_cf_1
#> [1] 19.1
```

Get the latest data from many PurpleAir sensors, defined by their sensor
keys,

``` r
get_sensors_data(x = as.integer(c(175257, 175413)),
                 fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> # A tibble: 2 × 5
#>   sensor_index last_seen           name          pm2.5_atm pm2.5_cf_1
#>          <int> <dttm>              <chr>             <dbl>      <dbl>
#> 1       175257 2024-07-07 19:16:30 Lillard            10.1       10.1
#> 2       175413 2024-07-07 19:16:12 JN-Clifton,OH      19.1       19.1
```

a geographic bounding box,

``` r
cincy::tract_tigris_2020 |>
  sf::st_transform(4326) |>
  sf::st_bbox() |>
  get_sensors_data(fields = c("name"))
#> # A tibble: 45 × 2
#>    sensor_index name              
#>           <int> <chr>             
#>  1        30303 아가페_실내       
#>  2        30561 lineblock_outside2
#>  3        30571 amlok_inside      
#>  4        36325 807d3a616167      
#>  5        36681 68c63a8e59a       
#>  6        42623 KMI_041           
#>  7        49191 BCDDC264D0B1      
#>  8        49193 ECFABCB88583      
#>  9        49199 ECFABC59A4F4      
#> 10        49213 807D3A615D1E      
#> # ℹ 35 more rows
```

or a date from which sensors must have been modified since.

``` r
get_sensors_data(as.POSIXct(Sys.time()) - 60, fields = "name")
#> # A tibble: 8,870 × 2
#>    sensor_index name                               
#>           <int> <chr>                              
#>  1          334 "Moody Ave"                        
#>  2          387 "Monmouth Drive P1"                
#>  3          443 "Weber-Morgan Health Department P1"
#>  4          453 "LRAPA-Oakridge City Hall"         
#>  5          469 "Sunnyside (interieur)"            
#>  6          473 "Sunnyside 93727"                  
#>  7          547 "AQMD_RTI_1"                       
#>  8          749 "Agia"                             
#>  9          820 "Granite Basement"                 
#> 10          828 "Acacia Street N Parksville,BC "   
#> # ℹ 8,860 more rows
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
