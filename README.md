# MScDissertation
This repository contains the data and scripts for replication of my MScDissertation

0_1_enoe_download
-Downloads all available data from ENOE

0_2_enoe_clean
-Appends and cleans all data from ENOE into a single dataset. It's important to select what variables to keep.
-It deflacts wages and minimum wages
-Generates relevant variables

0_aux_import_inpc
-Auxiliary script to automatically download prices data for deflation.

1_1_enoe_descriptives
-Generates relevant descriptives from data.

2_1_enoe_regressions
-Computes regressions for spillover and unemployment effects of minimum wage.
NOTE: Quantile Regression estimates and bootstrapping of their errors is an extremely **extremely** time consuming task. ETC: 6 days
Advice: Run 2 or more simultaneous windows of Stata calculating paralelly different quantiles to reduce computation time. As a rule of thumb, run one Stata parallel calcullation for each 3 GB of RAM on your computer.

1_aux_wald_baseline
-Auxiliary script that estimates Wald tests for OLS regressions.

1_aux_bootstrapped_ci
-Auxiliary script that estimates confidence intervals, standard errors and Wald tests out of bootstrapped distributions.

IMPORTANT: State proper root directories on scripts before running. Ideally, situate the whole project within a folder, and then define such folder as the global *path* at the beggnining of the scripts.

Questions and advice: Javier Valverde, fv62@sussex.ac.uk


