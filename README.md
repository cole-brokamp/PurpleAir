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

```r
install.packages("PurpleAir")
```

Install the latest development version of PurpleAir from GitHub with:

```r
pak::pak("cole-brokamp/PurpleAir")
```

## Usage

```r
library(PurpleAir)
```

Querying data from the PurpleAir API requires a free [PurpleAir
Developer API
key](https://develop.purpleair.com/sign-in?redirectURL=%2Fdashboards%2Fkeys)
linked to a Google account. Functions in the package each take a
`purple_air_api_key` argument or your key can be stored in an
environment variable called `PURPLE_AIR_API_KEY`. To check your key,
use:

```r
check_api_key(Sys.getenv("PURPLE_AIR_API_KEY"))
#> ✔ Using valid 'READ' key with version V1.2.0-1.1.45 of the PurpleAir API on 1758547191
```

Get the latest data from a single PurpleAir sensor, defined by its
[sensor
key](https://community.purpleair.com/t/sensor-indexes-and-read-keys/4000):

```r
get_sensor_data(sensor_index = 175413,
                fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> $last_seen
#> [1] "2025-09-22 09:17:55 EDT"
#>
#> $name
#> [1] "JN-Clifton,OH"
#>
#> $pm2.5_atm
#> [1] 18.4
#>
#> $pm2.5_cf_1
#> [1] 18.4
```

Get the latest data from many PurpleAir sensors, defined by their sensor
keys,

```r
get_sensors_data(x = c(175257, 175413),
                 fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#> # A tibble: 2 × 5
#>   sensor_index last_seen           name          pm2.5_atm pm2.5_cf_1
#>          <int> <dttm>              <chr>             <dbl>      <dbl>
#> 1       175257 2025-09-22 09:18:55 Lillard            18.5       18.5
#> 2       175413 2025-09-22 09:17:55 JN-Clifton,OH      18.4       18.4
```

a geographic [bounding box](http://bboxfinder.com),

```r
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
#>  3       283458 Wyoming
#>  4       284772 Cincy Air Watch- Zoo
#>  5       284822 Cincy Air Watch- Citylink Center
#>  6       285242 Cincy Air Watch- Wayne Park
#>  7        23621 Kenridge Lake
#>  8        35225 Mt. Washington
#>  9        90829 Whetsel &amp; Roe
#> 10       102568 SR32
#> # ℹ 53 more rows
```

or a date from which sensors must have been modified since.

```r
get_sensors_data(as.POSIXct(Sys.time()) - 60, fields = "name")
#> # A tibble: 11,906 × 2
#>    sensor_index name
#>           <int> <chr>
#>  1       262161 Living Room
#>  2       262253 Outrider Rd - Rolling Hills CA
#>  3       262261 B L Zen
#>  4       262309 Carbice Lab
#>  5       262331 DHS Bella
#>  6          275 Pleasanton
#>  7       262427 Cane Island Inside
#>  8       262441 Chandler, AZ
#>  9       262449 Rivas Canyon/Oracle Pl
#> 10          340 Ingram Road
#> # ℹ 11,896 more rows
```

Get historical data from a single PurpleAir sensor:

```r
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
#>  1 2024-07-04 21:10:00     2504.     1671.     1672.      2506.
#>  2 2024-07-04 23:30:00     2510.     1676.     1680       2513.
#>  3 2024-07-04 20:40:00       31.9      25.3      27.9       34.6
#>  4 2024-07-04 20:30:00       16.5      14.2      16.5       18.9
#>  5 2024-07-04 23:50:00     2509.     1675.     1678.      2512.
#>  6 2024-07-04 21:50:00     2513      1678      1683.      2517.
#>  7 2024-07-04 20:50:00      386.      262.      265.       390.
#>  8 2024-07-04 22:00:00     2512.     1678.     1682.      2516
#>  9 2024-07-04 22:40:00     2536.     1690.     1699.      2549.
#> 10 2024-07-04 21:00:00      914.      612.      614        916.
#> # ℹ 422 more rows
```

and plot it:

```r
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
