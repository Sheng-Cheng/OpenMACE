function [log_likelihood, tss_probPresent, tss_probAbsent, env_probPresent, log_likelihood_env] = normalizeLogLikelihood(log_likelihood, Mc)

% recover bayesian probabilities (unscaled)
likelihood = exp(log_likelihood);
likelihood_sum = sum( likelihood );
tss_probPresent = likelihood / (1 + likelihood_sum);
tss_probAbsent = 1 / (1 + likelihood_sum);
totalProb_sum = sum(tss_probPresent)  +  tss_probAbsent;

% normalize
tss_probPresent = tss_probPresent / totalProb_sum;
tss_probAbsent = tss_probAbsent / totalProb_sum;

% recompute log likelihood
log_likelihood = log( tss_probPresent / tss_probAbsent );

% also project likelihood    
env_probPresent = projectLikelihood( tss_probPresent , Mc );
log_likelihood_env = log(projectLikelihood( exp(log_likelihood) , Mc ));
    

end