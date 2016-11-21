---
title: "Tutorial woonuitbreidingsgebieden (WUG)"
author: "Stijn Van Hoey"
output: html_document
---


```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE,
                       fig.height = 8, fig.width = 8)
```

## Introduction

In this document, a short overview of the functions developed to make the WUG Rshiny application are showcased, as they can be used outside the scope of the application as well. For example, when making reports or doing other data analysis.

The different are organised in a package:

```{r loadfun}
library("woonuitbreidingsgebieden")
```

On the one hand, the `get_*` functions are created to extract the data from the data source (excel-file). On the other hand, the `create_*` functions are used to make the graphs. The `support.R` script provide some additional help functions.

The individual functions operate on a single WUG, based on the WUG code. For a given WUG code, the data can be extracted (in a tidy structure) and consecutively, the graphs can be made. The structuring of the data as a tidy format supports easy handling with e.g. `ggplot2`.

In this tutorial, we will use the WUG `11002_08` to illustrate the functions.

```{r }
id_wug <- "11002_08"
xls_file <- "inst/extdata/Afwegingskader_Wug.xlsx"
```

## Landuse plots

### Comparison percentage of area

To create the landuse plot, load the landuse data as percentages:

```{r landuse_load_pt}
lu_data <- get_landuse_data_pt(xls_file, id_wug)
```

and create the graph:
```{r landuse_plot_stack}
create_stacked_bar(lu_data)
```

### Relative loss in the municipality

To create the landuse relative loss plot, load the landuse data as ha:

```{r landuse_load_ha}
lu_data_ha <- get_landuse_data_ha(xls_file, id_wug)
```

and create the graph:
```{r landuse_plot_loss}
create_loss_bar(lu_data_ha)
```

## Ecosystem services radar chart

Similar to the landuse data, loading the data:

```{r esd_load}
esd_data <- get_esd_data(xls_file, id_wug)
```

and create the graph:
```{r esd_plot}
create_radar(esd_data, reference = "gemeente", threshold = 0.5)
```

Within the latter function, the option to chooce a `reference` is included, providing the option to compare the ecosystem services of the individual WUG with the ecosystem services of the following options:

* Gemeente : use `'gemeente'` as reference
* Vlaanderen : use `'vlaanderen'` as reference
* WUG gemeente : use `'wug_gemeente'` as reference
* WUG provincie : use `'wug_provincie'` as reference
* WUG Vlaanderen : use `'wug_vlaanderen'` as reference

As such, to make the comparison with the ESD of all the WUG area in the province, is is done as follows:
```{r esd_plot_province}
create_radar(esd_data, reference = "wug_provincie")
```

The threshold is the comparison value to compare with. The default is 0.5, but this can overwritten.




