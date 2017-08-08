
sampleGeneExpression2 = function(group1_size = 15, group2_size = 15, genes = 300, noise = 1, average_difference = 1, noise_difference = 1, module1_size = 40, module2_size = 45, batch_size = NULL, batch_average_difference = 1, group1_in_batch = 0.5, seed = NULL, to_return = F, substract_mean = F, add_group3 = F, group3_size = 15){
  set.seed(if(is.null(seed)) seed else seed)
  # generate gene expression matrix with random values around mean 0 with standard deviation 1 (detrended gene expression)
  # if only 2 groups
  if(!add_group3) X = matrix(rnorm(genes*(group1_size+group2_size), mean = 0, sd = noise), genes, (group1_size+group2_size))
  # if 3rd group that doesn't express both modules is also needed
  if(add_group3) X = matrix(rnorm(genes*(group1_size+group2_size+group3_size), mean = 0, sd = noise), genes, (group1_size+group2_size+group3_size))
  

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
  
  # true effect for group2 ~ group1 contrast
  true_effect = c(effect1, -effect2, rep(0, genes - module1_size - module2_size))

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
  if(!add_group3) samples = c(rep("#FF8000",group1_size),rep("#35AFA9",group2_size))
  if(add_group3) samples = c(rep("#FF8000",group1_size),rep("#35AFA9",group2_size), rep("gray27", group3_size))
  gene_modules = c(rep("#FFB57D", module1_size), rep("#B0E2DF", module2_size), rep("gray27", genes - module2_size-module1_size))
  
  random_gene_expression = list(input = match.call(), gene_expression = X, samples = samples, gene_modules = gene_modules, true_effect = true_effect, batch = if(!is.null(batch_size)) batch else NULL, batch_effect = if(!is.null(batch_size)) batch_effect else NULL)
  class(random_gene_expression) = "random_gene_expression-list"
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

plotBoxplot = function(random_gene_expression, genes_or_samples = F, add_group3 = F, show_only_genes_in_modules = T, module_names = "NA", sample_names = "NA") {
  # extract gene expression matrix
  gene_expression = random_gene_expression$gene_expression
  if(!add_group3) sample_colors = c("#FF8000", "#35AFA9")
  if(add_group3) sample_colors = c("#FF8000", "#35AFA9", "gray27")
  module_fills <- c("#FFB57D","#B0E2DF","gray27")
  
  # melt, add labels
  suppressWarnings({dat = melt(as.data.table(gene_expression))})
  
  dat = cbind(dat, modules = factor(rep(random_gene_expression$gene_modules, times = ncol(gene_expression)),
                                    levels = unique(random_gene_expression$gene_modules)),
              samples = factor(rep(sample_colors, each = nrow(gene_expression)*15), 
                               levels = sample_colors),
              genes = factor(rep(1:nrow(gene_expression), times = ncol(gene_expression)),  
                             levels = 1:nrow(gene_expression)))
  
  if(!(module_names[1] == "NA")){
    module_names[1] = if(1 <= length(module_names)) module_names[1] else "#FFB57D"
    module_names[2] = if(2 <= length(module_names)) module_names[2] else "#B0E2DF"
    module_names[3] = if(3 <= length(module_names)) module_names[3] else "gray27"
    dat[modules == "#FFB57D", modules := module_names[1]]
    dat[modules == "#B0E2DF", modules := module_names[2]]
    dat[modules == "gray27", modules := module_names[3]]
    dat[, modules := factor(modules, levels = module_names)]
  }
  
  if(!(sample_names[1] == "NA")){
    sample_names[1] = if(1 <= length(sample_names)) sample_names[1] else "#FF8000"
    sample_names[2] = if(2 <= length(sample_names)) sample_names[2] else "#35AFA9"
    sample_names[3] = if(3 <= length(sample_names)) sample_names[3] else "gray27"
    dat[samples == "#FF8000", samples := sample_names[1]]
    dat[samples == "#35AFA9", samples := sample_names[2]]
    dat[samples == "gray27", samples := sample_names[3]]
    dat[, samples := factor(samples, levels = sample_names)]
  }
  
  if(!genes_or_samples){
  # generate plot: average across genes (split by modules) per sample
  plot = ggplot(aes(x = variable, y = value, color = samples), data = dat) +
    geom_boxplot(outlier.size =0) +
    facet_grid(modules ~ .) +
    theme_light() + theme(strip.text.y = element_text(angle = 0), legend.position = "none", axis.text.x = element_text(size = 0)) +
    geom_jitter(size =0.2, color = "#666666") +
    scale_color_manual(values=sample_colors) +
    xlab("sample") + ylab("normalized gene expression")
  }
  
  if(genes_or_samples){
  # generate plot: average across samples per gene (labelled by modules
  if(show_only_genes_in_modules) dat = dat[modules != "gray27" | modules != module_names[3],]
  plot = ggplot(aes(x = genes, y = value, color = modules), data = dat) +
    geom_boxplot(outlier.size =0) +
    facet_grid(samples ~ .) +
    theme_light() + theme(strip.text.y = element_text(angle = 0), legend.position = "none", axis.text.x = element_text(size = 0)) +
    geom_jitter(size =0.2, color = "#666666") +
    scale_color_manual(values= module_fills) +
    xlab("gene") + ylab("normalized gene expression")
  
  }
  
  # modify plot to color facets
  # if average across genes in a modules per sample
  if(!genes_or_samples){
    g <- ggplot_gtable(ggplot_build(plot))
    stripr <- which(grepl('strip-r', g$layout$name))
    k <- 1
    for (i in stripr) {
      j <- which(grepl('rect', g$grobs[[i]]$grobs[[1]]$childrenOrder))
      g$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- module_fills[k]
      k <- k+1
    }
  }
  # if average across samples in a module per gene
  if(genes_or_samples){
    g <- ggplot_gtable(ggplot_build(plot))
    stripr <- which(grepl('strip-r', g$layout$name))
    k <- 1
    for (i in stripr) {
      j <- which(grepl('rect', g$grobs[[i]]$grobs[[1]]$childrenOrder))
      g$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- sample_colors[k]
      k <- k+1
    }
  }

  grid::grid.draw(g)
}
