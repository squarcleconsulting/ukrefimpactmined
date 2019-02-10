# ukrefimpactmined
R scripts for text mining UK Impact Case Studies.  This is the R code for an [OSF project](https://osf.io/cnrgu/?view_only=7850d79c32d3411a81198ff173f7bfa1).  This project is partially supported by the [Australian Research Data Commons](https://ardc.edu.au/).

Copyright (c) 2018 Paul Wong

This file is licenced under [CC-BY 4.0 International](https://creativecommons.org/licenses/by/4.0/)

---------------------------------------------------
## Usage

These codes were tested on a 12 core Mac Pro running OSX 10.13.6, and in the [Nectar Cloud](https://nectar.org.au/) under Ubuntu 16.04.5 LTS.  The R version tested was 3.4.4  They had not been tested on Windoze machines but you may be able to run them with cygwin installed.  

master.sh is the master shell script for running (1) refimpact/refimpact.R, (2) stmBase-nostem/stmBase-nostem.R, and (3) stmManyTop/stmManyTop.R sequentially.  Because of [licencing restriction on the UK Impact Case Studies](http://impact.ref.ac.uk/CaseStudies/Terms.aspx), we cannot redistribute the underlying case studies.  Also bewarned that (3) will take approximately 5 days to complete (I'll look into optimise the code in next iteration).  Also note that there are dependencies on (1), (2) and (3) - (3) depends on outputs from (2), and (2) depends on outputs from (1).  Nevertheless, you can run `./ukrefimpact.R` independently of master.sh. 

## Output Files

Successful execution of master.sh should see the outputs below. I would also recommend logging the run with the usual `./master.sh > masterlog.txt`.

### ukrefimpact/outputs/
* refimpact.RData

### stmBase-nostem/outputs/
* docsTidyTermCount.csv
* rankTerms.csv
* stmBase-nostem.RData

### stmManyTop/outputs/
* id_documents_topics_top5.csv
* id_topic_top15.csv
* stmManyTop50-80-tmp.RData
* stmManyTop50-80.RData

### stmManyTop/plots/
* SummaryMT\*\*.pdf
* TC0105\*\*fr.pdf
* TCCD0105\*\*fr.pdf

## Download the Whole Collection
By default, refimpact.R assumes that the user has manually downloaded the entire collection and saved the file in ukrefimpact/inputs/ImpactOnly.csv.  Follow the instruction below to download the whole collection:

- Go to [UK Impact Case Studies](http://impact.ref.ac.uk/CaseStudies/Search1.aspx) and click “See all case studies”
- Scroll down and click “None selected”
- Check “Details of impact” and proceed to click “download”
- When download is completed, open CaseStudies.xlsx in Excel
- Rename columns: “Case Study Id” with “ID”, “Unit of Assessment” with “FoR” and “Details of the impact” with “impact”
- Use `TRIM(CLEAN(SUBSTITUTE(cell, CHAR(160), “ “)))` in Excel to remove all non-printable characters (including line breaks) and extra white spaces in “impact” column 
- Remove column “Institution” and “Title”
- Save CaseStudies.xlsx as a tab delimited text file with the name “ImpactOnly.csv”
- Put ImpactOnly.csv in refimpact/inputs

Alternatively, you can turn on automatic download with the `fetchUKImpact(auto=TRUE)` call.  But by default the function will only download the first five impact cases, you can set the value using `k=...` option.

## Included Input Files
### ukrefimpact/inputs
* 0-GPA.csv - GPA is calculated based on [Paul Ginsparg's](https://en.wikipedia.org/wiki/Paul_Ginsparg) suggestion in [*Nature* 518, 150–151 (12 February 2015)](https://dx.doi.org/10.1038/518150a) using [UK REF assessment result](http://results.ref.ac.uk/DownloadFile/AllResults/xlsx)
* CaseStudyID.csv - the IDs of all 6637 case studies from [UK Impact Case Studies](http://impact.ref.ac.uk/CaseStudies/Terms.aspx)
* impactid-ukprn.csv - mapping table of case studies IDs and UKPRN (a UKPRN is a unique number allocated to a provider on successful registration on the UKRLP.  This is an 8 digit number starting with 1, e.g. 10000346, 10010014).
* UoA.csv - Unit of Assessment, code and text description

### stmBase-nostem/inputs
* hifreq.csv - high frequency terms to be removed.
* SearchTerms.csv - search terms to be used to investigate their contribution to research impact.  The default list is "data", "infrastructure", "model", "software" and "tool".  You can replace this list with any list of interest to you.

## Methodology
For a description of the methodology, please see my [presentation](https://doi.org/10.6084/m9.figshare.6459407.v1) at INORMS Edinburgh 2018.  The overall concept is depicted below, but in short we are trying to understand the contribution of research data in generating *research impact* (social, economic, cultural, environmental etc benefits).
![fittedmodel](/images/fittedmodel.png)

The information retrieval component is straightforward using the standard vector space model and term weighted ranking (e.g. TFIDF).  We have only used unigram (bag of words) in our approach and it would be interesting to extend the work with n-grams.  The (unsupervised) machine learning component is topic modelling using [stm package](http://www.structuraltopicmodel.com/) (specifically Corelated Topic Model, CTM).  We have also experimented with the standard LDA approach.  We have not done any deep comparison between CTM and LDA.  But very superficial examination of the topics generated from CTM and LDA looked very similar.  Indeed, it would be useful to do a more in depth study comparing LDA, CTM, STM and NMF.  We feel that reproducibility is an important consideration, hence it is important for us to use packages that can specify the random seed.  

The use of CTM does provide a way to look at the *correlation of topics* generated as well as applying network analytical techniques over the correlated topic networks.

![corelatedtopics](/images/corelatedtopics.png)
![communitydetection](/images/communitydetection.png)

## Acknowlegement

Julia Silge and David Robinson's book [*Text Mining with R*](https://www.tidytextmining.com/) has been fantastic.  STM package authors, Molly Roberts, Brandon Stewart and Dustin Tingley are also awesome.  *Big Data and Social Science: A Practical Guide to Methods and Tools* ed by Foster *et al* (2017) is also a good source.
