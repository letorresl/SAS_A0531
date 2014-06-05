#library(lattice)
library(ggplot2)
setwd("T:\Aplenc_New\Phenotype\AAML_0531\Analytic_Data")

# data long format, where 1 value (SF, EF, VIR) per line
data<-read.table("AML_PLOT_2.txt",sep="\t",T)
# the total number of patients come from a frequency table by patient id
pid<-read.table("patients.txt",sep="\t",T)

# from first to last patient, make a scatterplot with the values plotted according to date, with the color varying by value type (SF, EF, VIR)
for (i in 1:dim(pid)[1]){ 
	sub <- subset(data, data[1]==pid[i,1]);
	name <- paste("newplot_",pid[i,1],".jpg",sep="");
	jpeg(name, width = 480, height = 480, units = "px", quality = 100, bg = "white");
	print(ggplot(sub, aes(x = DATE, y = VALUE, colour = TYPE, shape=cond)) + geom_point(shape=19, size=4) + scale_shape_manual(values=c(4,4)) + scale_y_continuous(limits=c(10,80)) + ggtitle(paste("patient = ", pid[i,1],sep="")) + theme(axis.title.x = element_text(face="bold", colour="#888888", size=10),   axis.text.x  = element_text(angle=90, vjust=0.5, size=10))
+ theme(axis.title.y = element_text(face="bold", colour="#888888", size=10),   axis.text.y  = element_text(size=10)))
	dev.off();
}


