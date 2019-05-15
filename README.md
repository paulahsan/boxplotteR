# boxplotteR
The reader can try the codes below:

# Show help menu
Rscript boxplotter_cli.R -h

# Basic boxplot
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Time
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell

# Change colors
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell --color navy
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell --palette jco
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Time --y-ax Foci --fill Cell --palette red green blue cyan gold gray pink navy

# Make group
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time

# Show dotplot
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot dotplot
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter --dot-color gold

# Show outliers
Rscript boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter --dot-color gol --show-outliersd

# Statistics 
Rscript --vanilla boxplotter_cli.R --file MockFigure5C_3rdSheet.csv --x-ax Cell --y-ax Foci --facet Time --fill Cell --palette npg --dot dotplot --dot-size 0.6 --dot-val 0.6 --dot-alpha 0.2 --stat --stat-comp LIG4 MRE11-1

# import excel files
Rscript boxplotter_cli.R --file ~/Downloads/Mock_Figure5C.xlsx 3 --x-ax Cell --y-ax Foci --fill Cell --group Time --dot jitter --show-outliers --stat --stat-comp LIG4 MRE11-1 --dot-color gold --color steelblue --title "This is title of the plot"

