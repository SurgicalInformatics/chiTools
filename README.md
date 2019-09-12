[![TravisCRAN_Status_Badge](https://travis-ci.com/SurgicalInformatics/chiTools.svg?branch=master)](https://travis-ci.com/SurgicalInformatics/chiTools)

# chiTools

Tools Extracting Information From the Scottish Community Health Index Number (CHI)

The Community Health Index (CHI) is a population register, which is used in Scotland for health care purposes. 
The CHI number uniquely identifies a person on the index.


## Installation

You can install `chiTools` from GitHub:

``` r
devtools::install_github("SurgicalInformatics/chiTools")
```

## `chi_dob()` - Extract date of birth from CHI

Note `cutoff_2000`. 
As CHI has only a two digit year, need to decide whether year is 1900s or 2000s. 
Cut-off specifies a two digit year below which is considered 2000s.
i.e. at cutoff_2000 = 20, "18" is considered 2018, rather than 1918. 

``` r
library(dplyr)
chi = c("1009701234", "1811431232", "1304496368")
# These CHIs are not real. 
# The first is invalid, two and three are valid. 

chi_dob(chi)
#> [1] "1970-09-10" "1943-11-18" "1949-04-13"

# From tibble
tibble(chi = chi) %>% 
  mutate(
    dob = chi_dob(chi)
  )
  
#> # A tibble: 3 x 2
#>   chi        dob       
#>   <chr>      <date>    
#> 1 1009701234 1970-09-10
#> 2 1811431232 1943-11-18
#> 3 1304496368 1949-04-13
```

## `chi_gender()` - Extract gender from CHI

Ninth digit is odd for men and even for women. 

``` r
chi_gender(chi)
#> [1] "Male"   "Male"   "Female"

# From tibble
tibble(chi = chi) %>% 
  mutate(
    gender = chi_gender(chi)
  )
#> # A tibble: 3 x 2
#>   chi        gender
#>   <chr>      <chr> 
#> 1 1009701234 Male  
#> 2 1811431232 Male  
#> 3 1304496368 Female
```

## `chi_age()` - Extract age from CHI

Works for a single date or a vector of dates.

### Today

``` r
chi_age(chi, Sys.time())
#> [1] 49 75 70
```

### Single date

``` r
library(lubridate)
chi_age(chi, dmy("11/09/2018"))
#> [1] 48 74 69
```

### Vector of dates
``` r
dates = dmy("11/09/2018",
            "09/05/2015",
            "10/03/2014")
chi_age(chi, dates)
#> [1] 48 71 64

# From tibble
tibble(chi = chi) %>% 
  mutate(
    age = chi_age(chi, Sys.time())
  )
#> # A tibble: 3 x 2
#>   chi          age
#>   <chr>      <dbl>
#> 1 1009701234    49
#> 2 1811431232    75
#> 3 1304496368    70
```

### `chi_valid()` - Logical test for valid CHI

The final digit of the CHI can be used to test that the number is correct via the modulus 11 algorithm. 

``` r
chi_valid(chi)
#> [1] FALSE  TRUE  TRUE

# From tibble
tibble(chi = chi) %>% 
  mutate(
    chi_valid = chi_valid(chi)
  )
#> # A tibble: 3 x 2
#>   chi        chi_valid
#>   <chr>      <lgl>    
#> 1 1009701234 FALSE    
#> 2 1811431232 TRUE     
#> 3 1304496368 TRUE 
```
