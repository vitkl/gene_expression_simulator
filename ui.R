library(shiny)

# Define UI for application that simulates gene expression and plots heatmap
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("gene expression simulator: 2 sample groups, 2 gene modules, batch effect"),

  # Sidebar with a slider input for number of observations
  sidebarPanel(
    sliderInput("average_difference",
                "mean difference in expression of gene modules between sample groups",
                min = -10, max = 10, step = 0.5,
                value = 1),
    sliderInput("noise_difference",
                "variability in differential expression of genes within modules (sd)",
                min = 0.01, max = 10, step = 0.5,
                value = 1),
    sliderInput("noise",
                "background variability in expression (sd)",
                min = 0.01, max = 10, step = 0.5,
                value = 1),
    sliderInput("module1_size",
                "number of genes within module 1",
                min = 1, max = 300,
                value = 40),
    sliderInput("module2_size",
                "number of genes within module 2",
                min = 1, max = 300,
                value = 45),

    sliderInput("seed",
                "set.seed(): reproducible random number generation",
                min = 1, max = 100,
                value = 0.5, step = 1)
  ),

  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("heatmap", height = "auto"),

    fluidRow(
      column(width = 2, offset = 0.2,
             radioButtons(inputId = "batch", label = "Model batch effects?",
                          choices = list(yes = TRUE, no = FALSE), selected = FALSE),
             radioButtons("to_return", "Download data as RData file?",
                          choices = list(yes = TRUE, no = FALSE), selected = FALSE),
             conditionalPanel(condition = "input.to_return == \"TRUE\"",
                              downloadButton("downloadData", "download"))),
      column(width = 2, offset = 0.2,
             numericInput(inputId = "group1_size",
                          label = "size of the sample group 1",
                          value = 15),
             numericInput(inputId = "group2_size",
                          label = "size of the sample group 1",
                          value = 15),
             numericInput(inputId = "genes",
                          label = "number of genes",
                          value = 300)),
      column(width = 5, offset = 0.2,
             conditionalPanel(condition = "input.batch == \"TRUE\"",

                              sliderInput(inputId = "batch_size",
                                          label = "batch size",
                                          min = 1, max = 30, step = 1,
                                          value = 10, width = "100%"),
                              sliderInput("batch_average_difference",
                                          "batch effect (mean difference)",
                                          min = -10, max = 10, step = 0.5,
                                          value = 1, width = "100%"),
                              sliderInput("group1_in_batch",
                                          "fraction of samples in group 1 in batch",
                                          min = 0, max = 1,
                                          value = 0.5, width = "100%"))
      )
    )

  )
))
