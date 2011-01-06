library(ggplot2);
png('<%= plot_file %>', width=900, res=132);
d <- read.table('<%= pagerank_data %>', header=FALSE, sep='\t');
p <- ggplot(d, <%= raw_rank %>) + geom_histogram() + xlab("") + ylab("");
p;
