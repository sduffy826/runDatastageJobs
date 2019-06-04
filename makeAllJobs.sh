#!/bin/bash

# Will create a script with all the jobs in it, the order is the order of the scheduled jobs (mostly: the sap
#   jobs are intertwined with others, but an running all here).
# Note: the organization jobs are not included... run that manually

./makeJob.sh scheduling_vars
./makeJob.sh sap_vars append
./makeJob.sh geocoding_vars append
./makeJob.sh claim_vars append
./makeJob.sh billing_vars append
./makeJob.sh sbliw_vars append
./makeJob.sh asset_vars append
./makeJob.sh views_vars append
