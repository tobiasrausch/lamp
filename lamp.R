library(ggplot2)
library(reshape2)
library(grid)
library(scales)

args = commandArgs(trailingOnly=TRUE)
df = read.table(args[1], header=T)

png(paste0(args[1], ".png"), width=1600, height=800)
p = ggplot(data=df)
p = p + geom_rect(aes(xmin=0, xmax=1, ymin=0, ymax=1, fill=Value))
p = p + facet_grid(S~ample)
p = p + theme(legend.position="bottom", axis.text = element_blank(), axis.ticks = element_blank(), panel.grid  = element_blank())
p = p + labs(fill="Delta") + xlab("") + ylab("")
p = p + geom_text(aes(x=0.5, y=0.5, label=Value), vjust=-1)
p = p + geom_text(aes(x=0.5, y=0.5, label=Id), vjust=1)
p = p + ggtitle(paste0(args[1], " delta values"))
p = p + scale_fill_gradient2(low=rgb(224/255,80/255,146/255), mid=rgb(244/255, 208/255, 172/255), high="#ffff99", midpoint=0)
p
dev.off()

df$type = c("COVID", "IC")[(df$ample %% 2)+1]
df$type = factor(df$type, levels=c("COVID", "IC"))

png(paste0(args[1], ".bygroup.png"), width=800, height=600)
p = ggplot(data=df, aes(x=Group, y=Value))
p = p + geom_point(aes(color=type))
p = p + geom_boxplot(aes(color=type))
p = p + facet_wrap(~type)
p = p + ylim(-1, 1)
p = p + xlab("Group") + ylab("Delta value")
p = p + geom_hline(yintercept=0.3, linetype="dashed")
p
dev.off()
