#!/usr/local/bin/Rscript

# Copyright 2019-2020 Polash Ahsan Habib <ahsan.paul@gmail.com>
#  
##
#import necessary library
suppressWarnings(library(argparse))
library(ggplot2)
library(magrittr)
library(ggpubr)
suppressWarnings(library(readxl))
suppressWarnings(library(reshape2))
#library(dplyr)
#library(tidyr, warn.conflicts = FALSE)
suppressPackageStartupMessages(library(tidyr))

#library(gsubfn) #https://stackoverflow.com/a/15140507/9960542

#setwd("~/BoxPlotteR/")
source("boxplotter_backend.R")
#source("~/my_cli_tools/R_melt_columnData.R")

docstring<- "DESCRIPTION \\n\\
 BoxPlotteR\\n\\n\\
Tools for making plot from command line \\n\\
For more color option option visit \\n\\
https://github.com/paulahsan/boxplotteR/blob/master/ggplot2-colour-names.png \\n\\
or https://jaredhuling.org/jcolors/"

getParser <- function (parser){
  parser <- ArgumentParser(description=docstring, 
                           formatter_class= 'argparse.RawTextHelpFormatter')

        data_parser = parser$add_argument_group('Data parser: parse the data file and axis related arguments')
        data_parser$add_argument("--file", type="character", nargs='+',
                                 help="Input file name. Can read csv and excel file. \\n\\
For excel file add sheet name or sheet number after \\n\\
the filename, seperated by space.")
        data_parser$add_argument("--x-ax", type="character", help="x_axis value column name")
        data_parser$add_argument("--y-ax", type="character", help="y_axis value column name")
        # data_parser$add_argument("--cell-order", type="character", nargs='+', 
        #                          help="user given order for the cell line", default=NULL)
        data_parser$add_argument("--reorder", type="character", nargs='+', default=NULL,
                                 help="user given reordering for any factor or column  values\\n\\
put name of the reorder column, followed by the new orders\\n\\
seperated by spaces")
        
        color_parser = parser$add_argument_group('Color parser: parse the color related arguments for boxplot')
        color_parser$add_argument("--color","--border-color", type="character",default="black", 
                                  help="color for outline or border of the boxes, [default is %(default)s]")
        color_parser$add_argument("--fill","--box-color", type="character", 
                                  help="fill the inside of the boxes, [default is %(default)s]",default="white")
        color_parser$add_argument("--alpha", type="character", 
                                  help="alpha or transparency value for the colors, [default is %(default)s]",default=1.0)
        color_parser$add_argument("--palette","--color-theme", type="character", nargs='+', 
                                  help="color theme of the plot, [default is %(default)s]", default="npg" )
        facet_parser = parser$add_argument_group('Grouping parser: parse the Facet/Group related arguments')
        facet_parser$add_argument("--facet", "--group", type="character", default=NULL, help="facet by which column")
        facet_parser$add_argument("--facet-col", type="integer", default=NULL, 
                                  help="How many columns for the faceting ; default is total number\\n\\
of unique items in the facet columns")
        label_parser = parser$add_argument_group('Label parser: parse the axis labels and title arguments')
        label_parser$add_argument("--x-lab", type="character", help="label for x axis, [default is %(default)s]",
                                  default="Cell line and Time after drug exposure")
        label_parser$add_argument("--y-lab", type="character", help="label for y axis, [default is %(default)s]",
                                  default="Number of Foci per nucleus")
        label_parser$add_argument("--title", type="character", help="label for title of the plot, [default is %(default)s]",
                                  default="gH2AX foci")
        
        dotplot_parser = parser$add_argument_group('Dotplot parser: parse the dotplot related arguments to modify appearance')
        dotplot_parser$add_argument("--dot", type="character", help="Add 'jitter' or 'dotplot' to show dotplot",default="none")
        dotplot_parser$add_argument("--dot-color", type="character", help="define outline color of the dotplot, [default is %(default)s]",default="black")
        dotplot_parser$add_argument("--dot-fill", type="character", help="define fill color of the dotplot, [default is %(default)s]",default="black")
        dotplot_parser$add_argument("--dot-alpha", type="character", help="define color of the dotplot, [default is %(default)s]",default=0.2)
        dotplot_parser$add_argument("--dot-size", type="character", help="define size of the dots in the plot, [default is %(default)s]",default=0.4)
        dotplot_parser$add_argument("--dot-val","--dot-amount", type="character", 
                                    help="define amount of dots/jitter in the dotplot, [default is %(default)s]",default=0.06)
        
        save_parser = parser$add_argument_group('Save parser: parse the figure saving arguments')
        save_parser$add_argument("--out", "--save-as", type="character", help="directory and name for saving the plot, [default name %(default)s]", 
                                 default="boxplot.png" )
        save_parser$add_argument("--fig-size", type="integer", help="Figure size width and height respectively, [default W/H are %(default)s]",
                                 nargs=2, default=c(20,12))
        
        stat_parser = parser$add_argument_group('Statistics parser: parse the statistics related arguments')
        stat_parser$add_argument("--show-outliers", action='store_true', help="Outliers will be shown")
        stat_parser$add_argument("--stat", action='store_true', help="statistics summary will be added when '--stat-comp' is declared")
        stat_parser$add_argument("--stat-method", type="character", help="statistical method for testing, [default is %(default)s]", default="t.test")
        stat_parser$add_argument("--stat-comp", type="character", nargs='+', 
                                 help="list for statistical comparisons for testing", default=NULL)
        stat_parser$add_argument("--stat-pos", type="double", nargs='+', 
                                 help="y_axis position of the values for statistical comparisons", default=NULL)
        #stat_parser$add_argument("--stat-signif", type="character", nargs="character", 
        #                         help="NOT FUNCTIONAL statistical significance for testing. Option 'p.signif' or 'p.format'", default="p.signif")
        axis_parser = parser$add_argument_group('Axis parser: parse the axis modifying arguments')
        axis_parser$add_argument("--yscale", type="character", default="none",
                                 help="scale the y_axis by 'none', 'log2', 'log10', 'sqrt' [default is %(default)s]")
        axis_parser$add_argument("--max-y", type="double", default=30,
                                 help="maximum value to show in the y_axis, [default is %(default)s]")
        axis_parser$add_argument("--xtick-angle", type="double", default=90,
                                 help="rotate the tick values on the y_axis, [default is %(default)s]")
        axis_parser$add_argument("--legend", type="character", default="top",
                                 help="position the legend 'none', 'bottom', 'right', 'left' [default is %(default)s]")
        axis_parser$add_argument("--hide-ticks", action='store_false',
                                 help="All the ticks will be removed")


  return(parser)
}


executeMain <- function () {
  parser <- getParser()
  args <- parser$parse_args()
  
  #format and order cellline and time
  #df <- formattedData(args$file, args$cell_order)
  if (length(args$file)==2){ 
    filename <- args$file[1]
    sheetname <- args$file[2]
    meltDf <- dfFromExcel(filename, sheetname)
    df <- reorderData(meltDf, args$reorder)
  } else if (length(args$file)==1){
  df <- formattedData(args$file, args$reorder)
  } else {
    stop("Correct the strings after '--file'")
  }
  #List of Cell lines
  #cellLines <- unique(df$Cell)
  uniqX <- unique(df[[args$x_ax]])
  
  #adjust facet parameters
  #print(paste(">>>>>" , args$facet, args$facet_col, sep = " "))
  returnFacet <- getFacetParam(args$facet, args$facet_col, df)
  facet_argument <- returnFacet[[1]]
  facet_col_number <- returnFacet[[2]]
  
  #outlier decision
  outliers_argument <- ifelse( args$show_outliers != TRUE , NA, 20)
  #http://sape.inf.usi.ch/sites/default/files/ggplot2-shape-identity.png
  #http://sape.inf.usi.ch/quick-reference/ggplot2/shape
 
  
  boxPlot <- makeBoxPlot(df, args$x_ax, args$y_ax, 
                         args$max_y, args$yscale, args$legend,
                         args$color, args$fill, args$alpha, args$palette,
                         args$dot, args$dot_color, args$dot_fill, args$dot_alpha, args$dot_val, args$dot_size,
                         outliers_argument,
                         args$y_lab, args$x_lab, args$title, facet_argument, facet_col_number)

  #figure with no_facet
  if (is.null(args$facet)) {
    if (args$stat != FALSE | !is.null(args$stat_comp)) {
      warning("Statistics '--stat', '--stat-comp' cannot be shown without '--facet', However saving image.")
    }
    finalFigure <- boxPlot
    #figure has facet but no statistics
  } else if (!is.null(args$facet) & args$stat != TRUE){
    finalFigure <- modifyFacet(boxPlot, facet_argument, facet_col_number)
    #figure has both facet and statistics
  } else if (!is.null(args$facet) & args$stat != FALSE){
    if (!is.null(args$stat_comp)){
      facetFigure <- modifyFacet(boxPlot, facet_argument, facet_col_number)
      statFigure <- statisticsOperation(facetFigure, args$stat_method, args$stat_comp, args$stat_pos, uniqX)
      finalFigure <- statFigure
    } else {
      stop("'--stat-comp' must be provided for statistical comparison")
    }
  }
  finalFigure <- ggpar(finalFigure, ticks=args$hide_ticks, tickslab=args$hide_ticks, x.text.angle=args$xtick_angle)
  saveFigure(finalFigure, args$out, args$fig_size[1], args$fig_size[2])
    
}



if(!interactive()) {
  executeMain()
}
