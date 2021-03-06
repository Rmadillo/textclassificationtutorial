############################################################################
### Term Similarity and Correlation                                      ###
######################################                                   ###
### Description:                                                         ###
### This R script contains commands that compute the cosine similarity   ###
### among terms and correlations among document.                         ###
############################################################################

# Similarity among terms using cosine measure
cosine_simil_terms<-cosine(t(projdocterms))

# Terms most similar to sicherstellung
names(which(cosine_simil_terms[,"sicherstellung"]>.5))

# Terms most similar to koordinierung
names(which(cosine_simil_terms[,"koordinierung"]>.5))

# Correlations among terms
term_correlation<-cor(t(projdocterms))

# Correlations among documents
document_correlation<-cor(projdocterms)

# Project the documents to the latent dimensions
projdoc<-t(mytdm_mat_lsa) %*% lsaSpace$tk %*% solve(diag(lsaSpace$sk))
# an alternative is just
# projdoc <- lsaSpace$dk

projdoc<-projdoc[rowSums(projdoc)!=0,]

# See the new number of dimensions
dim(projdoc) # you should see 420 107

labels<-readLines("labels.txt")
indx<-sweep(mydtm_mat,1, as.numeric(labels[as.numeric(rownames(mydtm_mat))]),"*")
grp_var<-apply(indx,2,sum)
grp_var[grp_var>1]<-1
grp_var<-as.factor(grp_var)

scaled_terms<-lsaSpace$tk %*% diag(lsaSpace$sk)
melted<-cbind(grp_var, melt(scaled_terms[,1:6]))
melted_01<-melted[abs(melted$value)>=0.5, ]
melted_01$Var2<-paste("LSA",melted_01$Var2,sep=" ")
melted_01$grp_var<-ifelse(melted_01$grp_var==1, "Task","Not a Task")

barplot <- ggplot(data=melted_01,aes(x=Var1, y=value, fill=grp_var)) +
  geom_bar(stat="identity", position = "identity") +
  facet_wrap(~Var2)
barplot+theme(axis.text.x=element_blank(),axis.ticks=element_blank(),legend.title=element_blank(), legend.text = element_text(size=15)) + 
  geom_text(aes(label=Var1, y=0), size=5, angle=90)+ylab("Term coefficients")+xlab("")

