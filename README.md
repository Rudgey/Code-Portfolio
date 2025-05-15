# Code Portfolio
The purpose of this repository is to showcase code developed as part of my PhD project   
**Predicting Psoriatic Arthritis (PREDIPSA) - Dynamic modelling of primary care health-records for earlier diagnosis of psoriatic arthritis.** 

To summarise the research, we developed a dynamic prediction model using a landmarking approach, estimating the one-year risk of developing psoriatic arthritis at each landmark. Bayesian networks were the primary model of choice, where we used inverse probability of censoring weights (IPCW) to account for right-censored observations. Models were developed using UK primary care electronic health records (EHRs) from the Clinical Practice Research Datalink (CPRD).  
  
# R Scripts
function-create-landmark-data.R - a function that takes data and turns it into a landmarking format. Data inputted is in a form where each row is a dated observation containing the current values for all variables. A row only exists when one of these variables changes.  

ipcw_weights_landmark - takes landmark survival data and calculates IPCW weights (relative to the landmark).  

function-bn-fit-weighted.R - parameter learning for a Bayesian network using IPCW weights to account for censoring. Application of theory from Bandyopadhyay et al. (2014) doi:10.1007/s10618-014-0386-6   

fit-landmark-beta-calibration.R - Calibrating model predictions using a beta calibration model. An extension of Kull et al. (2017) (https://proceedings.mlr.press/v54/kull17a.html) for right-censored, landmarking data.  
  
sim-landmark-predict-data.R - Simulation of data that resembles the predictions produced by a landmarking model predicting 1-year risk of PsA at each landmark. Simulated data can be used to run fit-landmark-beta-calibration.R.

# Python
We also took a static approach to modelling, as shown in the published manuscript

Rudge A, Tillett W, McHugh NJ, Smith TR. An interpretable machine learning approach for predicting psoriatic arthritis in a UK primary care psoriasis cohort using electronic health records from the Clinical Practice Research Datalink. Annals of the Rheumatic Diseases 2025, doi: https://doi.org/10.1016/j.ard.2025.01.051.

Python was preferred for fitting a Random forest model. 

function-partial-dependence-rf.py - We used partial dependence plots to evaluate the directions of associations between each variable and the binary outcome.

function-pvi-rf.py - We used permutation variable importance to determine the most important model predictors.
