# ukrefimpactmined
R scripts for text mining UK Impact Case Studies.  This is the R code for an [OSF project](https://osf.io/cnrgu/?view_only=7850d79c32d3411a81198ff173f7bfa1).  This project is partially funded by the [Australian Research Data Commons](https://ardc.edu.au/).

Copyright (c) 2018 Paul Wong

This file is licenced under [CC-BY 4.0 International](https://creativecommons.org/licenses/by/4.0/)

---------------------------------------------------
# Usage

These codes were tested on OSX 10.13.6 and Ubuntu 16.04.5 LTS.  They had not been tested on Windoze machine but you may be able to run them with cygwin installed.

master.sh is the master shell script for running sequentially, (1) refimpact/refimpact.R, (2) stmBase-nostem/stmBase-nostem.R, and (3) stmManyTop/stmManyTop.R.  Because of licencing restriction on the use of the [UK Impact Case Studies](http://impact.ref.ac.uk/CaseStudies/Terms.aspx), we cannot redistribute these case studies.  Bewarned that (3) will take approximately 5 days to complete.  Also note that there are dependencies on (1), (2) and (3).

### Download the Whole Collection
By default, refimpact.R assumes that the user has manually downloaded the entire collection and saved the file in ukrefimpact/inputs/ImpactOnly.csv.  Do the following to download the collection:

- Go to [UK Impact Case Studies](http://impact.ref.ac.uk/CaseStudies/Terms.aspx) and click “See all case studies”
- Scroll down and click “None selected”
- Check “Details of impact” and proceed to click “download”
- When download is completed, open CaseStudies.xlsx in Excel
- Rename columns: “Case Study Id” with “ID”, “Unit of Assessment” with “FoR” and “Details of the impact” with “impact”
- Use TRIM(CLEAN(SUBSTITUTE(cell, CHAR(160), “ “))) in Excel to remove all non-printable characters (including line breaks) and extra white spaces in “impact” column 
- Remove column “Institution” and “Title”
- Save CaseStudies.xlsx as a tab delimited text file with the name “ImpactOnly.csv”
- Put ImpactOnly.csv in refimpact/inputs

### Included Input Files
#### ukrefimpact/inputs
* 0-GPA.csv - GPA is calculated based on Paul Ginsparg's suggestion in Nature 518, 150–151 (12 February 2015) doi:10.1038/518150a using [UK REF assessment result](http://results.ref.ac.uk/DownloadFile/AllResults/xlsx)
* CaseStudyID.csv - the IDs of all 6638 case studies from [UK Impact Case Studies](http://impact.ref.ac.uk/CaseStudies/Terms.aspx)
* impactid-ukprn.csv - mapping table of IDs of case studies and UKPRN (A UKPRN is a unique number allocated to a provider on successful registration on the UKRLP.  This is an 8 digit number starting with 1, e.g. 10000346, 10010014).
* UoA.csv - Unit of Assessment, code and text description

#### stmBase-nostem/inputs
* hifreq.csv - high frequency terms to be removed.
* SearchTerms.csv - search terms to be used to investigate their contribution to research impact







