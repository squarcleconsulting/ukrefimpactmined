#!/usr/bin/env Rscript

#######################################################
#
# Another wongas' hack 10/05/2018.   
# Preprocessing of UK Impact Case Studies with stm and tidy packages
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
# load refimpact.RData and all required packages
#
#######################################################

load("../refimpact/outputs/refimpact.RData")
loadpkgs()
print('refimpact.RData and packages loaded')

#######################################################
#
# add y percentile rank column to x and output as PRankOut 
# x: a data frame
# col: the name or index of column to determine PRank, x$c 
# pcut: a vector of the RRank cut values e.g. 0:4/4 
#		evaluates to c(0, 0.25, 0.50, 0.75, 1)
# inc_low: Boolean, TRUE or FALSE
#
#######################################################

PRank <- function(x, y, pcut = 0:4/4, inc_low = TRUE){
		x <- within(x, quartile <- as.integer(cut(y, 
		quantile(y, probs = pcut), include.lowest = inc_low)))
		assign('PRankOut', x, envir = .GlobalEnv)
}

#######################################################
#
# topic-term and document-topic mapping
#
#######################################################

# function to convert stm fitted model back to tidy format

stmsm2tidy <- function(x, n = 10){

id_topic <<- list()
id_topic_15 <<- list()
id_document_topic <<- list()
id_document_topic_5 <<- list()
tdis <<- list()

	for(i in 1:n){	
	# create topics to terms map in tidy
	id_topic[[i]] <<- tidy(x[[i]], matrix = "beta")
	id_topic[[i]] <<- transform(id_topic[[i]], topicID = sprintf('t%d', topic))		
	id_topic_15[[i]] <<- id_topic[[i]] %>%
	  group_by(topic) %>%
	  top_n(15, beta) %>%
	  ungroup() %>%
	  arrange(topic, -beta)
	
	# create document to topic map in tidy
	id_document_topic[[i]] <<- tidy(x[[i]], matrix = "gamma")
	id_document_topic[[i]] <<- transform(id_document_topic[[i]], topicID = sprintf('t%d', topic))
	names(id_document_topic[[i]])[1] <<- "row"
	id_document_topic[[i]] <<- left_join(id_document_topic[[i]], idRow)
	id_document_topic[[i]] <<- left_join(id_document_topic[[i]], rankTerms)	
	
	# create top 5 topics for each document	
	id_document_topic_5[[i]] <<- id_document_topic[[i]] %>%
		group_by(ID) %>%
		top_n(5, gamma) %>%
		mutate(rank = min_rank(desc(gamma))) %>%
		ungroup() %>%
		arrange(ID, -gamma)

	tdis[[i]] <<- id_topic_15[[i]] %>%
	group_by(term) %>%
	summarise(count = n())

	tdis[[i]] <<- tdis[[i]][order(-tdis[[i]]$count),]
	}
}

#######################################################
#
# Plot Topic Summaries for selectModel
#
#######################################################

# plot summary of all stm fitted models from selectModels
stmsumplot <- function(x, m, n = 10){
	Nseq <- seq(1:n)
	for(i in 1:n){
	pdf(file = paste0("SummarySM", m, "-", Nseq[i], ".pdf"), width = 12, height = 8)
	plot(x[[i]], xlim = c(0,0.1), text.cex = 0.5, n = 15, 
		main = paste0("A Fitted STM Topic Model with ", m, " Topics (no covariate), Model #", Nseq[i]))
	dev.off()
	}
}

# plotModels
stmsmodplot <- function(x, m){
	pdf(file = paste0("ECSM", m, ".pdf"), width = 12, height = 8)
	plotModels(x, legend.position="bottomright", 
		main = paste0("Exclusivity vs Semantic Coherence: STM Topic Models with ", m, " Topics (no covariate)"))
	dev.off()
}

#######################################################
#
# load stop word lists
#
#######################################################

# load SMART stop words from tidy and clean up to combine with high frequency word list
data(stop_words)
stop_words <- data.frame(stop_words[1])
names(stop_words)[1] <- "term"

# import high frequency words
hifreq <- data.frame(read_delim("inputs/hifreq.csv", "\t", escape_double = FALSE, trim_ws = TRUE))

# mystopwords are combination of SMART list and high frequency words
mystopwords <- rbind(hifreq, stop_words)

#######################################################
#
# Code as outlined on page 8 of stmVignette with modification to input file. 
# This is the first pass to process impact case to prepare extraction of tfidf values.
# Note: no stemming, lower.thresh = 20, customstopwords = as.vector(mystopwords$term)
#
#######################################################

# note that customstopwords use hifreq to filter out high frequency words, e.g. "research", "impact", etc.
processed <- textProcessor(ImpactCase$impact, metadata = ImpactCase, 
	lowercase = TRUE, removestopwords = TRUE, removenumbers = TRUE, removepunctuation = TRUE,
	stem = FALSE, wordLengths = c(3, Inf), customstopwords = as.vector(mystopwords$term),
	onlycharacter = TRUE, striphtml = TRUE
	)

# note that lower.thresh is set to 20, i.e. a term must occur in at least 21 document to be included.	
out <- prepDocuments(processed$documents, processed$vocab, processed$meta, lower.thresh = 20)
docs <- out$documents
vocab <- out$vocab
meta <-out$meta

#######################################################
#
# convert from stm format to slam format then to tidy format 
#
#######################################################

print('Convert and process in tidy format')

# slam to dtm to tidy format and rename first column to "row"
docsTidyTf <- tidy(as.DocumentTermMatrix(
				convertCorpus(docs, vocab, type = c("slam")), 
				weighting = weightTf)
			)
names(docsTidyTf)[1] <- "row"

# create id to row mapping and then rename column names
idRow <- data.frame(ImpactCase$ID, seq(1:6637))
names(idRow)[1] <- "ID"
names(idRow)[2] <- "row"

# use dplyr left_join to add id to docsTidyTf, then reorder and rename columns
docsTidyTf <- left_join(docsTidyTf, idRow)
docsTidyTf <- data.frame(docsTidyTf$row, docsTidyTf$ID, docsTidyTf$term, docsTidyTf$count)
names(docsTidyTf)[1] <- "row"
names(docsTidyTf)[2] <- "ID"
names(docsTidyTf)[3] <- "term"
names(docsTidyTf)[4] <- "count"
    
#######################################################
#
# extract tfidf values for each term in each stm processed impact case study
#
#######################################################

# use tidy bind_tf_idf function to extract tf_idf value
docsTidyTfidf <- bind_tf_idf(docsTidyTf, term = term, document = ID, n = count)

# call PRank to extract quartile rank of tf_idf then update docsTidyTfidf with ranking
PRank(docsTidyTfidf, docsTidyTfidf$tf_idf)
docsTidyTfidf <- PRankOut

rm(docsTidyTf)
rm(PRankOut)

#######################################################
#
# extract raw Term Count
#
#######################################################

# create a full list of terms and term count
docsTidyTermCount <- data.frame(docsTidyTfidf$term, docsTidyTfidf$count)

# column renaming
names(docsTidyTermCount)[1] <- "term"
names(docsTidyTermCount)[2] <- "count"

# summing all count of words for the whole corpus
docsTidyTermCount <- docsTidyTermCount %>%
		group_by(term) %>%
		summarise(count = sum(count))

# reorder docsTidyTermCount in descending order and export to csv		
docsTidyTermCount <- docsTidyTermCount[order(-docsTidyTermCount$count),]
write.csv(docsTidyTermCount, "outputs/docsTidyTermCount.csv")

#######################################################
#
# create a *Rank based on quartile rank of tfidf value of
# impact cases with occurences of "*".  Use SearchTerms.csv to 
# specify which term to search in the impact cases. 
#
# search a set of terms in tidy data and create a list 
# with the correponding tidy subset containing the term.
# The tidy subset is further timmed by selecting the row 
# row with max(tf_idf) 
#
#######################################################

SearchTerms <- readLines("inputs/SearchTerms.csv")
docsTidyTfidf_Slist <- list()

# insert the corresponding *Rank into docsTidyTfidf_Slist 
for(i in 1:length(SearchTerms)){
	docsTidyTfidf_Slist[[i]] <- subset(docsTidyTfidf, 
		term %in% grep(paste0("^", SearchTerms[i]), docsTidyTfidf$term, 
		value = TRUE), select = row:quartile)
	docsTidyTfidf_Slist[[i]] <- docsTidyTfidf_Slist[[i]] %>% 
		group_by(ID) %>%
		filter(tf_idf == max(tf_idf))
	docsTidyTfidf_Slist[[i]] <- left_join(ImpactCase, docsTidyTfidf_Slist[[i]])
	docsTidyTfidf_Slist[[i]] <- data.frame(docsTidyTfidf_Slist[[i]][1], docsTidyTfidf_Slist[[i]][10])
	docsTidyTfidf_Slist[[i]][is.na(docsTidyTfidf_Slist[[i]])] <- 0 		
}

# rename rank column as ranki
for(i in 1:length(SearchTerms)){
	names(docsTidyTfidf_Slist[[i]])[2] <- paste0(SearchTerms[i], "-rank")
}

# create rankTerms
rankTerms <- docsTidyTfidf_Slist[[1]]
for(i in 2:length(SearchTerms)){
	rankTerms <- left_join(rankTerms, docsTidyTfidf_Slist[[i]])
}
	
# add all rankI to ImpactCase 
ImpactCase <- left_join(ImpactCase, rankTerms)

# export rankTerms
write.csv(rankTerms, "outputs/rankTerms.csv")
#write.csv(SearchTerms, "outputs/SearchTerms.csv")

#######################################################
#
# Code as outlined on page 8 of stmVignette with modification to input file. 
# This is the second pass to process impact case with datRank added as metadata.
# Note: no stemming, lower.thresh = 20, customstopwords = as.vector(mystopwords$term)
#
#######################################################

print('Second pass in processing Impact Cases in stm.')

# note that customstopwords use hifreq to filter out high frequency words, e.g. "research", "impact", etc.
processed <- textProcessor(ImpactCase$impact, metadata = ImpactCase, 
	lowercase = TRUE, removestopwords = TRUE, removenumbers = TRUE, removepunctuation = TRUE,
	stem = FALSE, wordLengths = c(3, Inf), customstopwords = as.vector(mystopwords$term),
	onlycharacter = TRUE, striphtml = TRUE
	)

# note that lower.thresh is set to 20, i.e. a term must occur in at least 21 document to be included.	
out <- prepDocuments(processed$documents, processed$vocab, processed$meta, lower.thresh = 20)
docs <- out$documents
vocab <- out$vocab
meta <-out$meta

#######################################################
#
# save image
# 
#######################################################

save.image("outputs/stmBase-nostem.RData")
