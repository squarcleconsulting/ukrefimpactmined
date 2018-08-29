#!/usr/bin/env Rscript

#######################################################
#
# Another wongas' hack 10/05/2018.   
# Topic Model fitting of UK Impact Case Studies with stm and tidy packages
# data source: http://impact.ref.ac.uk/CaseStudies/
# Licence: MIT Licence 
#
#######################################################

#######################################################
#
# clear all objects in working directory 
#
#######################################################

rm(list=ls())
print('Removed all objects')

#######################################################
#
# load stmBase-nostem.RData and all required packages
#
#######################################################

load("../stmBase-nostem/outputs/stmBase-nostem.RData")
loadpkgs()
print('Base data and packages loaded')

#######################################################
#
# find 50-80 topics (increment by 5) and pick "best".  
# Bewarned: long run time
#
#######################################################

ImpactManyTop <- manyTopics(documents = out$documents, 
	vocab = out$vocab, K = c(50, 55, 60, 65, 70, 75, 80), max.em.its = 100, 
	data = out$meta, init.type = "Spectral", seed=12345, runs=50)

#######################################################
#
# plot
#
#######################################################

nameX = c("50", "55", "60", "65", "70", "75", "80")

# identify data relevant topics
dtopics <- list()
for(i in 1:length(nameX)){
	dtopics[[i]] <- findTopic(ImpactManyTop$out[[i]], n = 15, c("data"))
}

# Plot Topic Summaries
for(i in 1:length(nameX)) {
	pdf(file = paste0("plots/SummaryMT", nameX[i], ".pdf"), width = 12, height = 8)
	plot(ImpactManyTop$out[[i]], xlim = c(0,0.1), text.cex = 0.5, n = 15, 
		main = paste0(nameX[i], " ", "Topics"))
	dev.off()
}

# make TC01 TC05, Topic Correlation Networks list
TC01 <- list()
TC05 <- list()

for(i in 1:length(nameX)) {
 TC01[[i]] <- topicCorr(ImpactManyTop$out[[i]], method = "simple", cutoff = 0.01)		
 TC05[[i]] <- topicCorr(ImpactManyTop$out[[i]], method = "simple", cutoff = 0.05)
}

# make igraph igTCO1 igTC05 list for plotting
igTC01 <-list()
igTC05 <-list()

for(i in 1:length(nameX)) {
	igTC01[[i]] <- graph_from_adjacency_matrix(TC01[[i]]$poscor, mode = "undirected", 
	weighted = TRUE, diag = FALSE)

	igTC05[[i]] <- graph_from_adjacency_matrix(TC05[[i]]$poscor, mode = "undirected", 
	weighted = TRUE, diag = FALSE)

	# set edge width
	E(igTC01[[i]])$width <- E(igTC01[[i]])$weight*50
	E(igTC05[[i]])$width <- E(igTC05[[i]])$weight*50
	
	# side by side plot of networks and export as pdf	
	pdf(file = paste0("plots/TC0105", nameX[i], "fr.pdf"), width = 12, height = 8)
	par(mfrow = c(1,2))	
	plot(igTC01[[i]], layout = layout_with_fr, 
		vertex.size = degree(igTC01[[i]], mode = "all")*0.5, 
		main = paste0(nameX[i], " ", "Topics Correlation Network (cutoff = 0.01)")
		)
	plot(igTC05[[i]], layout = layout_with_fr, 
		vertex.size = degree(igTC05[[i]], mode = "all")*1.5, 
		main = paste0(nameX[i], " ", "Topics Correlation Network (cutoff = 0.05)")
		)
	dev.off()		

	# reset edge width for 4 up plot
	E(igTC01[[i]])$width <- E(igTC01[[i]])$weight*10
	E(igTC05[[i]])$width <- E(igTC05[[i]])$weight*10

	# 4 up community detection (using NG and GO) plot and export as pdf	
	pdf(file = paste0("plots/TCCD0105", nameX[i], "fr.pdf"), width = 12, height = 8)
	par(mfrow = c(2,2))	
	# plot community detection using NG cutoff = 0.01
	plot(cluster_edge_betweenness(igTC01[[i]]), igTC01[[i]], 
		vertex.size = degree(igTC01[[i]], mode = "all")*0.5, 
		main = paste0(nameX[i], " ", "Topics Community Detection (Newman-Girvan, cutoff = 0.01)"))

	# plot community detection using NG cutoff = 0.05
	plot(cluster_edge_betweenness(igTC05[[i]]), igTC05[[i]], 
		vertex.size = degree(igTC05[[i]], mode = "all")*1.5, 
		main = paste0(nameX[i], " ", "Topics Community Detection (Newman-Girvan, cutoff = 0.05)"))

	# plot community detection using GO cutoff = 0.01
	plot(cluster_fast_greedy(as.undirected(igTC01[[i]])), as.undirected(igTC01[[i]]), 
		vertex.size = degree(igTC01[[i]], mode = "all")*0.5, 
		main = paste0(nameX[i], " ", "Topics Community Detection (Greedy-Optimisation, cutoff = 0.01)"))

	# plot community detection using GO cutoff = 0.05
	plot(cluster_fast_greedy(as.undirected(igTC05[[i]])), as.undirected(igTC05[[i]]), 
		vertex.size = degree(igTC05[[i]], mode = "all")*1.5, 
		main = paste0(nameX[i], " ", "Topics Community Detection (Greedy-Optimisation, cutoff = 0.05)"))
	dev.off()
}

save.image("outputs/stmManyTop50-80-tmp.RData")
print('Saved to stmManyTop50-80-tmp.RData')

#######################################################
#
# topic-term and document-topic mapping
#
#######################################################

# convert back to tidy format
id_topic <- tidy(ImpactManyTop$out[[4]], matrix = "beta")

# add topicID column by prefixing topic with "t"
id_topic <- transform(id_topic, topicID = sprintf('t%d', topic))

# pick top 15 word from id_topic based on beta values
id_topic_top15 <- id_topic %>%
  group_by(topic) %>%
  top_n(15, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

# create document-topic mapping in tidy
id_documents_topics <- tidy(ImpactManyTop$out[[4]], matrix = "gamma")

# add topicID column by prefixing topic with "t"
id_documents_topics <- transform(id_documents_topics, topicID = sprintf('t%d', topic))

# rename column document as row  
names(id_documents_topics)[1] <- "row"

# add topic id and datRank columns
id_documents_topics <- left_join(id_documents_topics, idRow)
id_documents_topics <- left_join(id_documents_topics, rankTerms)

# pick top 5 topics for each document from id_documents_topics based on gamma value
id_documents_topics_top5 <- id_documents_topics %>%
 group_by(ID) %>%
 top_n(5, gamma) %>%
 mutate(rank = min_rank(desc(gamma))) %>%
 ungroup() %>%
 arrange(ID, -gamma)

write.csv(id_topic_top15, "outputs/id_topic_top15.csv")  
write.csv(id_documents_topics_top5, "outputs/id_documents_topics_top5.csv")  

save.image("outputs/stmManyTop50-80.RData")
print('Saved to stmManyTop50-80.RData')

#######################################################
#
# Goodbye
#
#######################################################

sayGoodbye <- function(){
   print('Goodbye')
}
sayGoodbye()
