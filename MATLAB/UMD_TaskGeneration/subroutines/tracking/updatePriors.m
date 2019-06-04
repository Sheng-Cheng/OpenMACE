function swarmWorld = updatePriors(swarmWorld)

    % sumL = sum(exp(swarmWorld.log_likelihood_env));
    % nullStateProb = swarmWorld.U(by,bx) = 1/(1 + sumL); % prob no target
    for i = 1:1:length(swarmWorld.log_likelihood_env)
        bx = swarmWorld.exploredGraph.Nodes.bx(i);
        by = swarmWorld.exploredGraph.Nodes.by(i);
        L = exp(swarmWorld.log_likelihood_env(i));
        swarmWorld.V(by,bx) = 0;
        
        %swarmWorld.O(by,bx) = L/(1 + sumL); % prob occupied
        swarmWorld.O(by,bx) = swarmWorld.env_probPresent(i);
        swarmWorld.U(by,bx) = (1 - swarmWorld.O(by,bx));
    end
    
end