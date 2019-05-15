#!/usr/local/bin/Rscript

# Copyright 2019-2020 Polash Ahsan Habib <ahsan.paul@gmail.com>
#  
# Necessary functions
###########################################
#               Format Data               #
###########################################
# formattedData <- function (data_arg, cell_order){
#   data <- read.csv(data_arg)
#   
#   #convert Times into factor
#   data$Time <-factor(data$Time)
#   #List of unique Cell lines
#   cellLines <- unique(data$Cell)
#   misSpelledCellName <- misSpell(cell_order, cellLines)
#   if (!is.null(cell_order)) {
#      if (misSpelledCellName == 0){
#        if (length(cell_order) > length(cellLines)) {
#         stop("'--cell-order' contains more cell line names than the actual data")
#         } else if (length(cell_order) < length(cellLines)) {
#               stop("'--cell-order' contains less cell line names than the actual data")
#         } else if (length(cell_order) == length(cellLines)) {
#           data$Cell <- factor(data$Cell, levels = cell_order)
#         } else {
#           warning("'--cell-order' has mismatch issue with actual data, please check.
#                   However, executing codes")
#       }
#   } else {
#       stop("'--cell-order' is given with mispelled Cell-line name/s
#             or Cell name that does not exist in this dataset. ")
# }
# }
#   return(data)
# }

###########################################
#               Format Data               #
###########################################
formattedData <- function (data_arg, reorder){
  data <- read.csv(data_arg)
  
  #convert Times into factor
  data$Time <-factor(data$Time)

  if (!is.null(reorder)) {
    #List of unique Cell lines
    columnName <- reorder[1]
    newOrders <- reorder[2:length(reorder)]
    uniq_reordering_column <- unique(get(columnName, data))
    misSpelledCellName <- misSpell(newOrders, uniq_reordering_column)
    if (misSpelledCellName == 0){
      if (length(newOrders) > length(uniq_reordering_column)) {
        stop("'--reorder' for %(columnName) contains more cell line names than the actual data")
      } else if (length(newOrders) < length(uniq_reordering_column)) {
        stop("'--reorder' for %(columnName) contains less cell line names than the actual data")
      } else if (length(newOrders) == length(uniq_reordering_column)) {
         data[[columnName]] <- factor(data[[columnName]], levels = newOrders)
        #print(newOrders)
      } else {
        warning("'--reorder' for %(columnName) has mismatch issue with actual data, please check.
                However, executing codes")
      }
      } else {
        stop("'--reorder' for [%(columnName)s] is given with mispelled Cell-line name/s
             or Cell name that does not exist in this dataset. ")
    }
      }
   return(data)
}

###########################################
#         df from EXCEL reader  UBC13       #
###########################################
dfFromExcel <- function (filename, sheetname){
  
  #this allows sheetname both as int and str.
  sheetname <- ifelse (suppressWarnings(!is.na(as.numeric(sheetname)))==FALSE,
                       sheetname, as.numeric(sheetname))
  
  df <- read_excel(filename, sheet=sheetname)
  df <- melt(df, variable.name = "Cell", value.name = "Foci")
  
  df <- df %>%  separate(Cell, c("Cell", "Drug", "Time"), "_")
  #head(df)
  df$Drug2 <- ifelse(df$Time == 0 , "-", "+")
  df$Drug <- paste(df$Drug, df$Drug2)
  df$Drug2 <- NULL
  head(df)
  return(df)
}

###########################################
#         misSpelled Cgaracters           #
###########################################
misSpell <- function(inputString, trueString){
  
  invalidString <- length(inputString[is.na(match(inputString,trueString))])
  return(invalidString)
}

###########################################
#        adjust facet parameters          #
###########################################

getFacetParam <- function (facet_by, facet_col_num, dataFrame) {
  
  if (!is.null(facet_by) & is.null(facet_col_num)) {
    facet_argument <- facet_by
    facet_col_number <- length(unique(get(facet_by, dataFrame)))
    
  } else if (!is.null(facet_by) & !is.null(facet_col_num)) {
    facet_argument <- facet_by
    facet_col_number <- facet_col_num
  } else {
    facet_argument <- facet_by
    facet_col_number <- facet_col_num
  }
  #print(paste(  facet_argument, facet_col_number, sep = " "))
  return (list(facet_argument, facet_col_number))
}


###########################################
#        add and Modify Facet             #
###########################################
modifyFacet <- function(initPlot, facet_argument, facet_col_number){
  initPlot <- initPlot + facet_wrap(facets = facet_argument, 
                                    ncol= facet_col_number,
                                    strip.position="bottom")

  img <- removeFacetBorder(initPlot)
  return(img)
} 

###########################################
#           removeFacetBorder             #
###########################################
removeFacetBorder <- function(img) {
  
  remove_facet <- theme(axis.text.x = element_text( color="black", size=10, angle=90), 
                        panel.spacing.x=unit(-0.1, "line")) 
  
  #>>>>>>>the following lines are for facet in TOP>>>>>>>>>>>>>>>>>>>>>>>>>
  #theme(panel.border = element_rect(colour = "white") , 
  #      strip.background= element_rect(),
  #      panel.spacing.x=unit(-0.1, "line")) +
  #theme(axis.line.x = element_line(), 
  #      axis.line.y = element_line())
  img <- img + remove_facet
  return(img)
}
###########################################
#        get statisticParameters          #
###########################################
getStatParam <- function(stat_param, uniqX) {
  comp_vect <- stat_param
  cellName <- uniqX
  #misSpelledParam <- length(comp_vect[is.na(match(comp_vect,cellName))])
  misSpelledParam <- misSpell(comp_vect, cellName)
  #add one condition if given items are correct
  if(misSpelledParam != 0) {
    stop("'--stat-comp' has been given with mispelled item name
            or item name that does not exist in this dataset.")
  } else {
    if (length(comp_vect) %% 2 != 0) {
      stop("'--stat-comp' provided with odd number of values.
              The provided item names should be even")
    } else { 
      sub_vect_compare <- split(comp_vect, ceiling(seq_along(comp_vect)/2))
      comparison <- sub_vect_compare
      
    }
  }  
  return(comparison) 
}

###########################################
#   perform statisticsOperation
###########################################
statisticsOperation <- function(img, statMethod, stat_param, uniqX) {
  my_comparison <- getStatParam(stat_param, uniqX)
  stat <- stat_compare_means(comparisons = my_comparison, method = statMethod,
                             label.y = c (28,28,28), label.x = 2.5,
                             aes(label = paste0("p = ", ..p.signif..)))
  img <- img + stat
  return(img)
}

###########################################
#              make the plot              #
###########################################
#print(paste(args$x_ax, args$fill,args$color,sep = ","))
#print(paste(args))
makeBoxPlot <- function(df, x_ax, y_ax, color, fill, alpha, palette,
                        dot, dot_color, dot_fill, dot_alpha, dot_val, dot_size,
                        outliers_argument,
                        y_lab, x_lab, title, facet_argument, facet_col_number) {

    boxPlot <- ggboxplot(df,
                    x = x_ax , y = y_ax,
                    color = color, fill = fill, alpha=alpha, palette = palette,
                    #facet.by = facet_argument, short.panel.labs = TRUE, ncol = facet_col_number,
                    #add = "dotplot", add.params = list(dotsize= 0.4,binwidth=0.1, alpha=0.2),
                    add=dot, 
                    add.params=list(color=dot_color, fill=dot_fill, alpha=dot_alpha, 
                                    binwidth=as.numeric(dot_val), dotsize=as.numeric(dot_size),
                                    size= as.numeric(dot_size), jitter = as.numeric(dot_val)), 
                    #facet.by = facet_argument, short.panel.labs = TRUE, #ncol = length(unique(df$facet_option)),
                    ylim = c(0,31), outlier.shape = outliers_argument,
                    ylab = y_lab, #label of the y axis
                    xlab = x_lab,  #label of the y axis
                    title = title) 
#if (!is.null(facet_argument)){
#  boxPlot <- addFacet(boxPlot, facet_argument, facet_col_number)
#}
  return(boxPlot)
  #ggsave("cli_plot.png", plot = boxPlot, path = NULL,
  #     scale = 1, width = 20, height = 10, units = "cm", dpi=420)

}

###########################################
#               save figure               #
###########################################
saveFigure <- function(img, filename, width, height){
  saveFile <- filename
  figWidth <- width
  figHeight <- height
  # #(figWidth, figHeight) <- args$fig_size
  ggsave(filename=saveFile, plot=img, width=figWidth, height=figHeight, units = "cm", dpi=420)
  cat(paste(">>>>>>>>Image saved as", saveFile, "<<<<<<<<\n"))
}
