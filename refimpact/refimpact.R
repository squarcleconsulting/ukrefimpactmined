#!/usr/bin/env Rscript

#######################################################
#
# Another wongas' hack 25/08/2018 
# Download UK Impact Case Studies using refimpact package
# data source: http://impact.ref.ac.uk/CaseStudies/
# Licence: MIT licence 
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
# load multiple packages.  If package not found, it'll be installed.
#
#######################################################

loadpkgs <- function(){
for (pkgs in c(
			'dplyr', 
			'easypackages',
			'geometry', 
			'ggplot2', 
			'ggpubr',
			'huge', 
			'igraph', 
			'LDAvis',
			'mallet', 
			'NLP', 
			'readr', 
			'refimpact',
			'rJava', 
			'rsvd', 
			'Rtsne', 
			'stm', 
			#'stmBrowser', # stmBrowser not compatible with R 3.5.1
			'stmCorrViz', 
			'stringr', 
			'textmineR',
			'tidyr', 
			'tidytext', 
			'tm', 
			'topicmodels')
	) {
    if (!require(pkgs, character.only=T, quietly=T)) {
        install.packages(pkgs, repos='http://cran.us.r-project.org')
        library(pkgs, character.only=T)	}
	}
}

loadpkgs()
print('Load or install all required packages')

#######################################################
#
# pauseme() in x sec. e.g. pauseme(5)
#
#######################################################

pauseme <- function(x)
{
    p1 <- proc.time()
    Sys.sleep(x)
    proc.time() - p1 # The cpu usage should be negligible
}

#######################################################
#
# fetchUKImpact(): function to download uk impact case studies using 
# refimpact package.  Some prepared mapping tables are also imported
#
#######################################################

fetchUKImpact <- function(auto=FALSE, k=5){

GPA <<- read_delim("inputs/0-GPA.csv", "\t", escape_double = FALSE, trim_ws = TRUE)
FoR <<- read_delim("inputs/UoA.csv", "\t", escape_double = FALSE, trim_ws = TRUE)
CaseID <<- read_delim("inputs/CaseStudyID.csv", "\t", escape_double = FALSE, trim_ws = TRUE)
cid2ukprn <<- read_delim("inputs/impactid-ukprn.csv", "\t", escape_double = FALSE, trim_ws = TRUE)
org <<- ref_get("ListInstitutions")
cid <<- as.vector(CaseID$CaseStudyID)


# auto=FALSE, manually download impact cases
if (!auto){
	print('Manually download and import UK Impact Cases')
	ImpactCase <<- read_delim("inputs/ImpactOnly.csv", "\t", escape_double = FALSE, trim_ws = TRUE)
}

# auto=TRUE, automatically download impact cases, by default k=5, only five cases are downloaded
else {

# create an empty list to hold downloaded impact cases
cases <<- list() #

# call ref_get() to download all impact cases #
for(i in 1:k){ #
	pauseme(1) #
	cases[[i]] <<- ref_get("SearchCaseStudies", query=list(ID = cid[i])) #
	print(paste0("Completed ", i, " download")) #
} #

# initialize the empty dataframe ImpactCase
ImpactCase <<- data.frame(ID=integer(), FoR=character(), impact=character(), stringsAsFactors=FALSE) #

# fetch detailed impact descriptions from cases to ImpactCase
# clean up carriage return and multiple white spaces
for(i in 1:k){ #
	ImpactCase <<- rbind(ImpactCase, data.frame( # 
		ID = as.numeric(cases[[i]]$CaseStudyId), #
		FoR = cases[[i]]$UOA, #
		impact = trimws( #
		gsub("\\s+"," ", gsub("\r\n", " ", cases[[i]]$ImpactDetails) ) ) #
		) ) #
	print(paste0("Cleansed ", i, " row")) #
		} #
	} #
} #

fetchUKImpact(auto=FALSE)

save.image("outputs/refimpact.RData")