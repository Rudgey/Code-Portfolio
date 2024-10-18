# Programming-CV
The purpose of this repository is to showcase some of code developed for my PhD project   
**Predicting Psoriatic Arthritis (PREDIPSA) - Dynamic modelling of primary care health-records for earlier diagnosis of psoriatic arthritis.**  

We developed a dynamic prediction model using a landmarking approach. At each landmark, we predict the 1-year risk of psoriatic arthritis using a Bayesian network. Bayesian networks are not typically used for survival data, and so we use inverse probability of censoring weights (IPCW) to account for right-censored observations. UK primary care electronic health records (EHRs) from the Clinical Practice Research Datalink (CPRD) were used to develop the models.  
  
# R Scripts
function-create-landmark-data.R - a function that takes data and turns it into a landmarking format. Data inputted is in a form where each row is a dated observation containing the current values for all variables. A row only exists when one of these variables changes.  

ipcw_weights_landmark - takes landmark survival data and calculates IPCW weights (relative to the landmark).  

function-bn-fit-weighted.R - parameter learning for a Bayesian network using IPCW weights to account for censoring. Application of theory from Bandyopadhyay et al. (2014) doi:10.1007/s10618-014-0386-6   

fit-landmark-beta-calibration.R - Calibrating model predictions using a beta calibration model. An extension of Kull et al. (2017) (https://proceedings.mlr.press/v54/kull17a.html) for right-censored, landmarking data.  
  
sim-landmark-predict-data.R - Simulation of data that resembles the predictions produced by a landmarking model predicting 1-year risk of PsA at each landmark. Simulated data can be used to run fit-landmark-beta-calibration.R.

