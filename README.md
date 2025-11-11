
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
linked to a Google account. Functions in the package read your key from
the environment variable `PURPLE_AIR_API_KEY`. To check your key, use:

``` r
check_api_key()
#> ✔ Using valid 'READ' key with version V1.2.0-1.1.45 of the PurpleAir API on 1762872892
```

Set `PURPLE_AIR_API_KEY` in your `.Renviron` or via
`Sys.setenv(PURPLE_AIR_API_KEY = "your-key")` before making requests.

Get the latest data from a single PurpleAir sensor, defined by its
[sensor
key](https://community.purpleair.com/t/sensor-indexes-and-read-keys/4000):

``` r
get_sensor_data(sensor_index = 175413,
                fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> $last_seen
#> [1] "2025-11-11 09:53:13 EST"
#> 
#> $name
#> [1] "JN-Clifton,OH"
#> 
#> $pm2.5_atm
#> [1] 2.8
#> 
#> $pm2.5_cf_1
#> [1] 2.8
```

Get the latest data from many PurpleAir sensors, defined by their sensor
keys,

``` r
get_sensors_data(x = c(175257, 175413),
                 fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> # A tibble: 2 × 5
#>   sensor_index last_seen           name          pm2.5_atm pm2.5_cf_1
#>          <int> <dttm>              <chr>             <dbl>      <dbl>
#> 1       175257 2025-11-11 09:53:25 Lillard             4.2        4.2
#> 2       175413 2025-11-11 09:53:13 JN-Clifton,OH       2.8        2.8
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
#> # A tibble: 63 × 2
#>    sensor_index name                            
#>           <int> <chr>                           
#>  1       273763 Boone Block                     
#>  2       280360 Pricely Gardens                 
#>  3       282656 Cincinnati State                
#>  4       283458 Wyoming                         
#>  5       284772 Cincy Air Watch- Zoo            
#>  6       284822 Cincy Air Watch- Citylink Center
#>  7       285186 Cincy Air Watch - Seven Hills   
#>  8       285242 Cincy Air Watch- Wayne Park     
#>  9        23621 Kenridge Lake                   
#> 10        35225 Mt. Washington                  
#> # ℹ 53 more rows
```

or a date from which sensors must have been modified since.

``` r
get_sensors_data(as.POSIXct(Sys.time()) - 60, fields = "name")
#> # A tibble: 11,512 × 2
#>    sensor_index name                          
#>           <int> <chr>                         
#>  1       262151 CleanAire NC Deck             
#>  2       262161 Living Room                   
#>  3           53 Lakeshore                     
#>  4       262253 Outrider Rd - Rolling Hills CA
#>  5       262261 B L Zen                       
#>  6       262257 Woodbury Preschool Village    
#>  7       262259 PurpleAir91107                
#>  8       262265 Highlands Ranch               
#>  9       262291 Cedar Street                  
#> 10       262302 Cirencester Rd                
#> # ℹ 11,502 more rows
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
#>  1 2024-07-04 06:50:00      2504.     1670.     1671.      2505.
#>  2 2024-07-04 09:40:00      2504.     1671.     1672.      2505.
#>  3 2024-07-04 11:30:00      2504.     1671.     1673.      2506.
#>  4 2024-07-03 22:20:00      2504.     1671.     1673.      2506.
#>  5 2024-07-04 13:00:00      2505.     1672.     1675.      2508.
#>  6 2024-07-04 10:50:00      2505.     1671.     1672.      2506.
#>  7 2024-07-04 07:00:00      2504.     1670.     1671.      2504.
#>  8 2024-07-04 02:40:00      2503.     1670.     1670.      2504.
#>  9 2024-07-04 14:10:00      2504.     1671.     1672.      2506.
#> 10 2024-07-04 08:30:00      2504.     1670.     1672.      2505.
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
