
sampleGeneExpression2 = function(group1_size = 15, group2_size = 15, genes = 300, noise = 1, average_difference = 1, noise_difference = 1, module1_size = 40, module2_size = 45, batch_size = NULL, batch_average_difference = 1, group1_in_batch = 0.5, seed = NULL, to_return = F, substract_mean = F){
  set.seed(if(is.null(seed)) seed else seed)
  # generate gene expression matrix with random values around mean 0 with standard deviation 1 (detrended gene expression)
  X = matrix(rnorm(genes*(group1_size+group2_size), mean = 0, sd = noise), genes, (group1_size+group2_size))

  # make genes in module 1 differentially expressed in sample group 1
  set.seed(if(is.null(seed)) seed else seed + 1)
  effect1 = rnorm(module1_size, average_difference, noise_difference)
  X[1:module1_size, 1:group1_size] = X[1:module1_size, 1:group1_size] + effect1 # adding effect

  # make genes in module 2 differentially expressed in sample group 2
  set.seed(if(is.null(seed)) seed else seed + 2)
  effect2 = rnorm(module2_size, average_difference, noise_difference)
  X[(module1_size+1):(module1_size+module2_size), (group1_size+1):(group1_size + group2_size)] = X[(module1_size+1):(module1_size+module2_size), (group1_size+1):(group1_size + group2_size)] + effect2 # adding effect
  
  # substract mean if substract_mean is true
  if(substract_mean) X = X - rowMeans(X)
  
  true_effect = c(effect1, effect2, rep(0, genes - module1_size - module2_size))

  # if batch_size is not NULL - add batch effect of batch_average_difference imbalanced towards group 1 by group1_in_batch fraction (the fraction of group1)
  if(!is.null(batch_size)) {
    set.seed(if(is.null(seed)) seed else seed + 3)
    # calculate which samples to add batch effect to
    batch = c(sample(1:group1_size, batch_size * group1_in_batch), sample((group1_size+1):(group1_size + group2_size), batch_size * (1 - group1_in_batch)))
    # add batch effect
    batch_effect = rnorm(nrow(X), batch_average_difference, 1)
    X[, batch] = X[, batch] + batch_effect
  }

  # describe samples and gene modules to use for coloring
  samples = c(rep("#FF8000",group1_size),rep("#35AFA9",group2_size))
  gene_modules = c(rep("#FFB57D", module1_size), rep("#B0E2DF", module2_size), rep("black", genes - module2_size-module1_size))
  
  random_gene_expression = list(input = match.call(), gene_expression = X, samples = samples, gene_modules = gene_modules, true_effect = true_effect, batch = if(!is.null(batch_size)) batch else NULL, batch_effect = if(!is.null(batch_size)) batch_effect else NULL)
  class(random_gene_expression) = "random_gene_expression"
  return(random_gene_expression)
}

plotHeatmap2 = function(random_gene_expression, seed = NULL){
  # generate black and white palette
  cols = colorRampPalette(c("#000000", "#FFFFFF"), space = "Lab")(30)
  # plot heatmap
  set.seed(if(is.null(seed)) seed else seed + 4)
  heatmap = gplots::heatmap.2(random_gene_expression$gene_expression, col = cols,
                              ColSideColors = random_gene_expression$samples,
                              RowSideColors = random_gene_expression$gene_modules,
                              labRow = FALSE, labCol = FALSE,
                              trace = "none")
}

plotBoxplot = function(random_gene_expression) {
  ggplot2::qplot(x = 1:nrow(random_gene_expression$gene_expression), y = random_gene_expression$gene_expression, geom = "boxplot")
  dat <- stack(as.data.frame(random_gene_expression$gene_expression))
  dat = cbind(dat, modules= rep(random_gene_expression$gene_modules, ncol(random_gene_expression$gene_expression)))
  ggplot2::ggplot(dat) + 
    ggplot2::geom_boxplot(ggplot2::aes(x = ind, y = values, color = random_gene_expression$samples)) + ggplot2::facet_grid(modules ~ .) + ggplot2::geom_jitter(ggplot2::aes(x = ind, y = values),size =0.5) + ggplot2::theme_light() + ggplot2::theme(strip.text.y = ggplot2::element_text(angle = 0), legend.position = "none")
}
