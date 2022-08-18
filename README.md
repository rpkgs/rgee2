
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rgee2

<!-- badges: start -->
<!-- badges: end -->

The goal of rgee2 is to …

## Installation

You can install the development version of rgee2 from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("rpkgs/rgee2")
```


## 网络代理

- **安装gcloud**
```R
# gcloud info --run-diagnostics
# C:/Users/kong/AppData/Roaming/gcloud/configurations/config_default
[proxy]
type = http
address = localhost
port = 1081
```

- **R语言设置**

**The following solution not working. Because we need to set proxy before R start, other than after.**
See <https://github.com/r-spatial/rgee/issues/73#issuecomment-1186549194> for details.

```R
Sys.setenv(https_proxy="http://127.0.0.1:1081")
Sys.setenv(http_proxy="http://127.0.0.1:1081")
```

- ### 1. RStudio uses `R.exe`

```bash
#subl "C:/Program Files/R/R-4.2.1/etc/Rcmd_environ"
http_proxy="http://127.0.0.1:1081"
https_proxy="http://127.0.0.1:1081"
```

- ### 2. VScode uses `radian.exe`

```javascript
// code .vscode/settings.json
{
  "r.rterm.windows": "c:/ProgramData/Miniconda3/envs/gee/Scripts/radian.exe",
  "terminal.integrated.env.windows": {
    // "PATH": "${env:PATH}",
    "http_proxy":"http://127.0.0.1:1081",
    "https_proxy":"http://127.0.0.1:1081",
  },
}
```

```powershell
[Environment]::SetEnvironmentVariable("http_proxy", "http://127.0.0.1:1081", [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("https_proxy", "http://127.0.0.1:1081", [System.EnvironmentVariableTarget]::User)
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(rgee2)
library(rgee)
ee_Initialize(drive = TRUE)
#> -- rgee 1.1.2 --------------------------------------- earthengine-api 0.1.280 -- 
#>  v user: not_defined
#>  v Google Drive credentials: v Google Drive credentials:  FOUND
#>  v Initializing Google Earth Engine: v Initializing Google Earth Engine:  DONE!
#>  v Earth Engine account: users/kongdd 
#> --------------------------------------------------------------------------------
```

### Illustration by EAR5L data

``` r
# bands = c('T', "Tdew", 'Pa', 'Rn', 'ET', 'U2')
year = 2020
month = 1
col <- ee$ImageCollection("ECMWF/ERA5_LAND/HOURLY")$
    filter(ee$filter$Filter$calendarRange(year, year, "year"))$
    filter(ee$filter$Filter$calendarRange(month, month, "month"))$
    select(0:4)
# print(col)

img = col$first()
print(img)
#> bandNames: 
#> dewpoint_temperature_2m, temperature_2m, skin_temperature, soil_temperature_level_1, soil_temperature_level_2
#> Properties: 
#> List of 6
#>  $ system:time_start: int -1
#>  $ hour             : int 0
#>  $ system:footprint :List of 2
#>   ..$ type       : chr "LinearRing"
#>   ..$ coordinates:List of 5
#>   .. ..$ : int [1:2] -180 -90
#>   .. ..$ : int [1:2] 180 -90
#>   .. ..$ : int [1:2] 180 90
#>   .. ..$ : int [1:2] -180 90
#>   .. ..$ : int [1:2] -180 -90
#>  $ system:time_end  : int -1
#>  $ system:asset_size: int 400727784
#>  $ system:index     : chr "20200101T00"
```

``` r
ee_timestart(col) %>% head()
ee_timeend(col) %>% head()

ee_bandNames(col)
ee_bandNames(img)

ee_properties(col)
ee_aggregate_array(col, prop = "system:index")
```
