# Hi, I am a gene expression simulator! 

### I simulate gene expression   
- in 2 sample groups,   
- of 2 gene modules,   
- and can include batch effect    

### I show you a heatmap plot that groups genes and samples by distance silimarity. You can download simulated data as .RData file.  

## Option details:  
...coming soon...  

## How to use 

To use this R shiny app, first, you need to save this repository (either clone or download zip file) to your computer. If you download zip file, unzip it.   

You may need to install shiny R package:  
```r
install.packages("shiny")
```

Next, you can set R working directory to a folder containing shiny app (server.R, ui.R, gene_expression_simulation.R) and run this command:  
```r
shiny::runApp()
```

In you are using RStudio you can open gene_expression_simulation.Rproj, and run the same command:  
```r
shiny::runApp()
```

If you want to use both R console and the app you can type this into the Terminal:  
```SHELL
R -e "shiny::runApp('~/_path_to_app_/gene_expression_simulation/')"
```
and open the link in the output (which may differ from the example) in the internet browser:  
```
> Listening on http://127.0.0.1:7630
```

## Try it now

You can try using the app now by following this link:  
https://vitkl.shinyapps.io/gene_expression_simulator/  
However, there is a limitation: app will work only for 25 hours per month for all users (RStudio free subscription limit). App is also likely to work faster on your machine.   