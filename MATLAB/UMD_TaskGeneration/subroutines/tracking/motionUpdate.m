function log_likelihood = motionUpdate(log_likelihood, Q , q_s_n , q_n_s, q_n_n )

ns = length(log_likelihood);

% likelihood ratio
L = exp(log_likelihood);
sumL = sum(L);
% unpack likelihood intro a probability for each state
ps_prior = L/(1+sumL);
pn_prior = 1/(1+sumL);
ps = Q'*ps_prior + ones(ns,1)*q_s_n*pn_prior/ns;
pn = ones(1,ns)*q_n_s*ps_prior + q_n_n*pn_prior;

% error check
if ( abs(sum(ps) + pn - 1) > 0.001 )
    error('probability is significantly off');
end
log_likelihood = log(ps/pn);

% Previous approach
%likelihood = swarmWorld.Q'*(exp(swarmWorld.log_likelihood));
%likelihood = likelihood ./ (ns*swarmModel.q_s_n*likelihood + 1);

end