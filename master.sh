#!/bin/bash
#
# Version 0
# Paul Wong

# Another wongas hack 17/06/2018.
# master script to get UK Impact Case Studies and preprocess cases


#######################################################
#
# fetch UK Impact Case Studies Corpus using refimpact package 
#
#######################################################

echo "Get UK Impact Case Studies"
cd refimpact

echo "Start time"
date

./refimpact.R > log.csv

echo "End time"
date

echo ""
echo "Completed Case Studies download"
echo ""

#######################################################
#
# preprocess impact cases with stm package 
#
#######################################################

cd ../stmBase-nostem

echo "Start preprocessing Case Studies"
echo "Start time"
date

./stmBase-nostem.R > log.csv

echo "End time"
date

echo ""
echo "Completed preprocessing Case Studies"
echo ""

#######################################################
#
# fitting topics models using stm package using stmManyTop 
#
#######################################################

cd ../stmManyTop

echo "Start fitting topic models to Case Studies"
echo "Start time"
date

./stmManyTop.R > log.csv

echo "End time"
date

echo ""
echo "Completed fitting topic models to Case Studies"
echo ""
