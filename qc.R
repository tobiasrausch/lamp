library(ggplot2)
library(scales)

args = commandArgs(trailingOnly=TRUE)
x = read.table(args[1], header=T)
x = x[x$group %in% c("pc", "saliva", "Knopp"),]
x$failed = factor((x$ic < 0.3 & x$group == "saliva"))
print(nrow(x[x$group=="saliva",]))

threshold=0.3

png("qc.png", width=800, height=800)
p = ggplot(data=x, aes(x=covid, y=ic))
p = p + geom_point(aes(color=group, fill=group, shape=failed), size=3)
p = p + xlab("COVID") + ylab("IC")
p = p + scale_shape_manual(values=c(21,25))
p = p + geom_hline(yintercept=threshold, linetype="dashed")
p = p + geom_vline(xintercept=threshold, linetype="dashed")
p
dev.off()
