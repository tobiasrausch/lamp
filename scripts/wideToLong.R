library(reshape2)

args = commandArgs(trailingOnly=TRUE)
x = read.table(args[1], header=F)
colnames(x)=c("r",1:(ncol(x)-1))

df=melt(x, id.vars=c("r"))
df$pos = paste0(df$r, df$variable)
df = df[,c("value","pos")]
write.table(df, file=paste0(args[1], ".out"), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
print(warnings())
