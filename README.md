# FRED_GRAPHS: Replicating FRED graphs in R

You will need your own FRED API key that could be obtained at [FRED website](https://fredhelp.stlouisfed.org/fred/account/fred-account-features/register/) after registering for free account. See "FRED Key" section of the code in FRED_GDP_COMPONENTS.R for details.

## FRED_GDP_COMPONENTS.R

This [graph](https://twitter.com/stlouisfed/status/1064176422124756992), posted on [FRED Twitter](https://twitter.com/stlouisfed), prompted my replication exercise. 

## Libraries used

[fredr](https://cran.r-project.org/web/packages/fredr/index.html) - access FRED API

[tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html) - preparing data

[dygraphs](https://cran.r-project.org/web/packages/dygraphs/index.html) - visualization library

[xts](https://cran.r-project.org/web/packages/xts/index.html) - working with time-based data for visualization

[rvest](https://cran.r-project.org/web/packages/rvest/index.html) - web scrapping for Recession data
