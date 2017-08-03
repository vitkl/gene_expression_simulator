# Hi, I am a gene expression simulator! 

I simulate gene expression   
- in 2 sample groups,   
- of 2 gene modules,   
- and can include batch effect    

I show you a heatmap plot that groups genes and samples by distance silimarity. You can download simulated data (list) as .RData file.  

Option details:  
...coming soon...  

To use this R shiny app, first, you need to install shiny R package:  
```r
install.packages("shiny")
```
Next, you need to save this repository (either clone or download zip file) to your computer. If you download zip file, unzip it.  
Next, you can set R working directory to a folder containing shiny app (server.R, ui.R, gene_expression_simulation.R) and run this command:  
```r
shiny::runApp()
```

In you are using RStudio you can open gene_expression_simulation.Rproj, and run the same command:  
```r
shiny::runApp()
```

If you want to use both R console and the app you can type this into Terminal:  
```SHELL
R -e "shiny::runApp('~/_path_to_app_/gene_expression_simulation/')"
```