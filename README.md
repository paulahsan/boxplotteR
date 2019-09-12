# boxplotteR
## Overview
This tools prepare boxplot and dotplot from the cell biology experimental data. gamma H2AX foci or any other foci number upon any drug treatment can be visualized by this tool. This is just a command line implementation of [ggpubR package] (https://www.rdocumentation.org/packages/ggpubr/versions/0.2.2), which itself is based on the infamous [ggplot2, by Hadley Wickham,](https://ggplot2.tidyverse.org/).

## Installation and loading
The tool has some library dependancies.
### ggplot2
``` r
# The easiest way to get ggplot2 is to install the whole tidyverse:
install.packages("tidyverse")

# Alternatively, install just ggplot2:
install.packages("ggplot2")

# Or the the development version from GitHub:
# install.packages("devtools")
devtools::install_github("tidyverse/ggplot2")
```
### ggpubR
-   Install from [CRAN](https://cran.r-project.org/package=ggpubr) as follow:

``` r
install.packages("ggpubr")
```

-   Or, install the latest version from [GitHub](https://github.com/kassambara/ggpubr) as follow:

``` r
if(!require(devtools)) install.packages("devtools")
devtools::install_github("kassambara/ggpubr")
```
### argparse
To install the latest version released on CRAN use the following
command:
```r
install.packages("argparse")
```
### tidyR
```r
# The easiest way to get ggplot2 is to install the whole tidyverse:
install.packages("tidyverse")
# Alternatively, install just tidyr:
install.packages("tidyr")
```
### magrittr
```r
# The easiest way to get magrittr is to install the whole tidyverse:
install.packages("tidyverse")

# Alternatively, install just magrittr:
install.packages("magrittr")
```
### reshape2
```r
#Get the released version from cran
install.packages("reshape2")
```
### readxl
The easiest way to install the latest released version from CRAN is to install the whole tidyverse.
```r
install.packages("tidyverse")
```
Alternatively, install just readxl from CRAN:
```
install.packages("readxl")
```
## Help Menu of the tool
```
$   Rscript --vanilla boxplotter_cli.R -h

usage: boxplotter_cli.R [-h] [--file FILE [FILE ...]] [--x-ax X_AX]
                        [--y-ax Y_AX] [--reorder REORDER [REORDER ...]]
                        [--color COLOR] [--fill FILL] [--alpha ALPHA]
                        [--palette PALETTE [PALETTE ...]] [--facet FACET]
                        [--facet-col FACET_COL] [--x-lab X_LAB]
                        [--y-lab Y_LAB] [--title TITLE] [--dot DOT]
                        [--dot-color DOT_COLOR] [--dot-fill DOT_FILL]
                        [--dot-alpha DOT_ALPHA] [--dot-size DOT_SIZE]
                        [--dot-val DOT_VAL] [--out OUT]
                        [--fig-size FIG_SIZE FIG_SIZE] [--show-outliers]
                        [--stat] [--stat-method STAT_METHOD]
                        [--stat-comp STAT_COMP [STAT_COMP ...]]

DESCRIPTION
 BoxPlotteR

Tools for making plot from command line
For more color option option visit
https://github.com/paulahsan/my_cli_tools/raw/master/ggplot2-colour-names.png

optional arguments:
  -h, --help            show this help message and exit

Data parser: parse the data file and axis related arguments:
  --file FILE [FILE ...]
                        Input file name. Can read csv and excel file.
                        For excel file add sheet name or sheet number after
                        the filename, seperated by space.
  --x-ax X_AX           x_axis value column name
  --y-ax Y_AX           y_axis value column name
  --reorder REORDER [REORDER ...]
                        user given reordering for any factor or column  values
                        put name of the reorder column, followed by the new orders
                        seperated by spaces

Color parser: parse the color related arguments for boxplot:
  --color COLOR, --border-color COLOR
                        color for outline or border of the boxes, [default is black]
  --fill FILL, --box-color FILL
                        fill the inside of the boxes, [default is white]
  --alpha ALPHA         alpha or transparency value for the colors, [default is 1]
  --palette PALETTE [PALETTE ...], --color-theme PALETTE [PALETTE ...]
                        color theme of the plot, [default is npg]

Grouping parser: parse the Facet/Group related arguments:
  --facet FACET, --group FACET
                        facet by which column
  --facet-col FACET_COL
                        How many columns for the faceting ; default is total number
                        of unique items in the facet columns

Label parser: parse the axis labels and title arguments:
  --x-lab X_LAB         label for x axis, [default is Cell line and Time after drug exposure]
  --y-lab Y_LAB         label for y axis, [default is Number of Foci per nucleus]
  --title TITLE         label for title of the plot, [default is gH2AX foci]

Dotplot parser: parse the dotplot related arguments to modify appearance:
  --dot DOT             Add 'jitter' or 'dotplot' to show dotplot
  --dot-color DOT_COLOR
                        define outline color of the dotplot, [default is black]
  --dot-fill DOT_FILL   define fill color of the dotplot, [default is black]
  --dot-alpha DOT_ALPHA
                        define color of the dotplot, [default is 0.2]
  --dot-size DOT_SIZE   define size of the dots in the plot, [default is 0.4]
  --dot-val DOT_VAL, --dot-amount DOT_VAL
                        define amount of dots/jitter in the dotplot, [default is 0.06]

Save parser: parse the figure saving arguments:
  --out OUT, --save-as OUT
                        directory and name for saving the plot, [default name boxplot.png]
  --fig-size FIG_SIZE FIG_SIZE
                        Figure size width and height respectively, [default W/H are (20, 12)]

Statistics parser: parse the statistics related arguments:
  --show-outliers       Outliers will be shown
  --stat                statistics summary will be added when '--stat-comp' is declared
  --stat-method STAT_METHOD
                        statistical method for testing, [default is t.test]
  --stat-comp STAT_COMP [STAT_COMP ...]
                        list for statistical comparisons for testing

$   Rscript --vanilla boxplotter_cli.R --file ~/my_cli_tools/MockFigure5C_3rdSheet.csv \
--x-ax Cell --y-ax Foci --facet Time --fill Cell --palette npg \
--dot dotplot --dot-size 0.6 --dot-val 0.6 --dot-alpha 0.2 \
--stat --stat-comp LIG4 MRE11-1
```

## The reader can try the codes below:

#### Show help menu
```
Rscript --vanilla boxplotter_cli.R -h
```

#### Basic boxplot
```
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Time
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell
```

#### Change colors
```
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell --color navy
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell --palette jco
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell --palette red green blue cyan gold gray pink navy
```

#### Make group
```
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time
```

#### Show dotplot
```
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot dotplot
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter --dot-color gold
```

#### Show outliers
```
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter --dot-color gol --show-outliers
```

#### Statistics 
```
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --facet Time --fill Cell --palette npg --dot dotplot --dot-size 0.6 --dot-val 0.6 --dot-alpha 0.2 --stat --stat-comp LIG4 MRE11-1
```

#### import excel files
```
Rscript --vanilla boxplotter_cli.R --file Mock_Figure5C.xlsx 3 --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter --show-outliers --stat --stat-comp LIG4 MRE11-1 --dot-color gold --color steelblue --title "This is title of the plot"
```
