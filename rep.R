library(ggplot2)
library(scales)
library(reshape2)

args = commandArgs(trailingOnly=TRUE)
x = read.table(args[1], header=T)

threshold = 0.3

# Replicates on same plate?
if (length(unique(x$plate)) == 1) {
  # Assign P1 and P2 arbitrarily between replicates
  x = x[order(x$id),]
  x$plate = "P1"
  x[(1:nrow(x) %% 2 == 1),]$plate = "P2"
}

# Scatter
for (msvar in c("covid", "ic")) {
  a = x[x$plate=="P1",]
  b = x[x$plate=="P2",]
  a = a[,c("id", msvar)]
  colnames(a) = c("id", "xval")
  b = b[,c("id", msvar)]
  colnames(b) = c("id", "yval")
  df = merge(a, b)
  if (msvar == "covid") {
    df[df$xval<0 & df$yval<0,]$id = NA
  } else {
    df[df$xval>0 & df$yval>0,]$id = NA
  }
  pcorval = cor(df$xval, df$yval, method="pearson")
  scorval = cor(df$xval, df$yval, method="spearman")
  p = ggplot(data=df, aes(x=xval, y=yval))
  p = p + geom_point()
  p = p + xlab("Plate1 delta value") + ylab("Plate2 delta value")
  p = p + geom_vline(xintercept=threshold, linetype="dashed")
  p = p + geom_hline(yintercept=threshold, linetype="dashed")
  p = p + ggtitle(paste0(msvar, ", pearson=",round(pcorval, digits=4), ", spearman=", round(scorval, digits=4)))
  p = p + geom_text(aes(label=id), vjust=1)
  ggsave(p, file=paste0("rep.", msvar, ".scatter.png"), width=12, height=12)
}


# All replicates
df = melt(x, id.vars=c("id", "group", "plate"))
png("rep.png", width=800, height=800)
p = ggplot(data=df, aes(x=value, y=id))
p = p + geom_point(aes(color=plate, fill=plate), size=1)
p = p + stat_summary(fun.data="mean_cl_boot", geom="errorbar", width=0.05, color="black")
p = p + ylab("Sample Barcode") + xlab("Delta value")
p = p + scale_shape_manual(values=c(21,25))
p = p + geom_vline(xintercept=threshold, linetype="dashed")
p = p + facet_wrap(~variable)
p = p + scale_y_discrete(guide = guide_axis(n.dodge=3))
p
dev.off()

# IC threshold
df = df[df$variable=="ic",]
maxval = length(unique(df$id))
outdf = data.frame()
for (th in 1:65) { 
    uval = length(unique(df[df$value < th/100,]$id))
    sdf = data.frame(ic=th/100, fail=maxval-uval)
    sdf$fraction = sdf$fail / maxval
    if (nrow(outdf)) {
      outdf=rbind(outdf, sdf)
    } else {
      outdf=sdf
    }
}

print(outdf[outdf$ic == 0.5,])

png("ic_threshold.png", width=800, height=800)
p = ggplot(data=outdf, aes(x=ic, y=fail))
p = p + geom_line()
p = p + ylab("#Samples with no failed replicate") + xlab("IC threshold")
p
dev.off()

