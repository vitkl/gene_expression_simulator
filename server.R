library(shiny)

# Define server logic required to simulate gene expression and plot heatmap
shinyServer(function(input, output, session) {
  # identify missing packages
  packages = c("gplots")
  missing_packages = packages[!packages %in% names(installed.packages()[,"Package"])]
  if(length(missing_packages) > 0) stop(paste0("required packages are missing: ", paste(missing_packages, collapse = " ")))
  
  source("gene_expression_simulation.R")
  
  observe({
    updateSliderInput(session, "module1_size", value = input$module1_size,
                      min = 1, max = input$genes - input$module2_size, step = 1)
    updateSliderInput(session, "module2_size", value = input$module2_size,
                      min = 1, max = input$genes - input$module1_size, step = 1)
    updateSliderInput(session, "batch_size", value = input$batch_size,
                      min = 1, max = input$group1_size + input$group2_size, step = 1)
    
    
    big_batch = isolate({input$batch_size > input$group1_size})
    big_batch_fraq = isolate({input$group1_size/input$batch_size})
    big_batch_min = if(big_batch) 1 - big_batch_fraq else 0
    big_batch_max = if(big_batch) big_batch_fraq else 1
    big_batch_step = isolate({(big_batch_max - big_batch_min) / input$batch_size})
    small_batch_step = isolate({1 / input$batch_size})
    
    
    updateSliderInput(session, "group1_in_batch", value = input$group1_in_batch,
                      min = big_batch_min,
                      #min = 0,
                      max = big_batch_max,
                      #max = 1,
                      step = big_batch_step
                      #,step = small_batch_step
                      )
  })
  
  output$heatmap <- renderPlot({
    batch = as.logical(input$batch)
    to_return = as.logical(input$to_return)
    if(batch) batch_size = input$batch_size
    if(!batch) batch_size = NULL
    # generate gene expression data
    random_gene_expression = sampleGeneExpression2(input$group1_size, input$group2_size,
                                                   input$genes, input$noise,
                                                   input$average_difference, input$noise_difference,
                                                   input$module1_size, input$module2_size,
                                                   batch_size, input$batch_average_difference, input$group1_in_batch, input$seed, to_return)
    
    plotHeatmap2(random_gene_expression, seed = input$seed)
    
    output$downloadData <- downloadHandler(
      filename = "random_gene_expression.RData",
      content = function(file) {
        save(random_gene_expression, file = file)
      }
    )
  }, height = function() {
    session$clientData$output_heatmap_width/1.25})
  
})

# R -e "shiny::runApp('~/Desktop/gene_expression_simulator/')" #http://rstudio.github.io/shiny/tutorial/#run-and-debug
