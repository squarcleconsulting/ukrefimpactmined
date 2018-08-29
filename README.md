# ukrefimpactmined
R scripts for text mining UK Impact Case Studies

Copyright (c) 2018 Paul Wong

This file is licenced under CC-BY 4.0 International.

---------------------------------------------------
# Usage

These codes were tested on OSX 10.13.6 and Ubuntu 16.04.5 LTS.  They had not been tested on Windoze machine but you may be able to run them with cygwin installed.

master.sh is the master shell script for running sequentially, (1) refimpact/refimpact.R, (2) stmBase-nostem/stmBase-nostem.R, and (3) stmManyTop/stmManyTop.R.  Because of licencing restriction on the use of the UK Impact Case Studies (see http://impact.ref.ac.uk/CaseStudies/Terms.aspx), we cannot redistribute these case studies.  Bewarned that (3) will take approximately 5 days to complete.  Also note that there are dependencies on (1), (2) and (3).

By default, refimpact.R assumes that the user has manually downloaded the entire collection and saved the file as ukrefimpact/ImpactOnly.csv.  Follow the instruction in https://github.com/squarcleconsulting/ukrefimpactmined/blob/master/download_instruction.pdf to download the collection. 


