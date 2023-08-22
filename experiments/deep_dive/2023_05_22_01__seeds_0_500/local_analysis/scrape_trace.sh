#!/bin/bash

MAX_LINE=`grep final_org_eval.txt -n -e "\[DOORS\] break" | grep -m 1 -oP "^\d+"`
head -n ${MAX_LINE} final_org_eval.txt| grep -oP -e "IP:\s+\d+" | grep -oP "\d+" > trace.txt
