# Programming-CV
The purpose of this repository is to showcase some of code developed for my PhD project   
**Predicting Psoriatic Arthritis (PREDIPSA) - Dynamic modelling of primary care health-records for earlier diagnosis of psoriatic arthritis.**  

We developed a dynamic prediction model using a landmarking approach. At each landmark, we predict the 1-year risk of psoriatic arthritis using a Bayesian network. Bayesian networks are not typically used for survival data, and so we use inverse probability of censoring weights (IPCW) to account for right-censored observations.  

UK primary care electronic health records (EHRs) from the Clinical Practice Research Datalink (CPRD) were used to develop the models.  
function-create-landmark-data.R - a function that takes data where each row is a single observation from the EHR and turns it into a form suitable to landmarking.  

ipcw_weights_landmark - takes landmark survival data and calculates IPCW weights (relative to the landmark).  

function-bn-fit-weighted.R - 


