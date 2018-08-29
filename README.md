# ukrefimpactmined
R scripts for text mining UK Impact Case Studies

Copyright (c) 2018 Paul Wong

This file is licenced under CC-BY 4.0 International.

---------------------------------------------------
# Usage

These codes were tested on OSX 10.13.6 and Ubuntu 16.04.5 LTS.  They had not been tested on Windoze machine but you may be able to run them with cygwin installed.

master.sh is the master shell script for running sequentially, (1) refimpact/refimpact.R, (2) stmBase-nostem/stmBase-nostem.R, and (3) stmManyTop/stmManyTop.R.  Because of licencing restriction on the use of the UK Impact Case Studies (see http://impact.ref.ac.uk/CaseStudies/Terms.aspx), we cannot redistribute these case studies.  Bewarned that (3) will take approximately 5 days to complete.  Also note that there are dependencies on (1), (2) and (3).

### Download the Whole Collection
By default, refimpact.R assumes that the user has manually downloaded the entire collection and saved the file as ukrefimpact/ImpactOnly.csv.  Do the following to download the collection:

- Go to http://impact.ref.ac.uk/CaseStudies/ and click “See all case studies”
- Scroll down and click “None selected”
- Check “Details of impact” and proceed to click “download”
- When download is completed, open CaseStudies.xlsx in Excel
- Rename columns: “Case Study Id” with “ID”, “Unit of Assessment” with “FoR” and “Details of the impact” with “impact”
- Use TRIM(CLEAN(SUBSTITUTE(cell, CHAR(160), “ “))) in Excel to remove all non-printable characters (including line breaks) and extra white spaces in “impact” column 
- Remove column “Institution” and “Title”
- Save CaseStudies.xlsx as a tab delimited text file with the name “ImpactOnly.csv”
- Put ImpactOnly.csv in refimpact/inputs





