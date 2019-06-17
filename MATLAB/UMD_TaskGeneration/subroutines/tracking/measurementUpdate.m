function swarmWorld = measurementUpdate(swarmWorld, swarmModel, signals, V)

% if all agents are in void space then no update is required
if ( ~isempty(signals) )
    logMsmtLikelihood = swarmModel.mZ*(signals - swarmModel.mZ/2); % convert signals to log-likelihood ratio
    
    % error check
    if ( length(signals) ~= length(V) )
        error('Incorrect lengths of signals and nodes v');
    end
    
    % data association is based on naive gating method:
    gates = gateMsmts(V, swarmWorld);
    
    
    % apply likelihood update to each node
    for j = 1:1:length(V)
        S = findTargStatesInView(swarmWorld.Mc, V(j));
        if ( isempty(gates) )
            % update LRDT only
            for k = 1:1:length(S)
                swarmWorld.log_likelihood(S(k)) =  swarmWorld.log_likelihood(S(k)) + logMsmtLikelihood(j);
            end
        else            
            for k = 1:1:length(S)
                if (gates{j} == 1 )
                    for ind = gates{j};
                    % if node j is in gate, update tracker
                    swarmWorld.tracker{ind}.log_likelihood(S(k)) =  swarmWorld.log_likelihood(S(k)) + logMsmtLikelihood(j);
                    end
                else
                    % otherwise update
                    swarmWorld.log_likelihood(S(k)) =  swarmWorld.log_likelihood(S(k)) + logMsmtLikelihood(j);
                end
            end
        end
    end
end

if ( isempty(V) )
    disp('No Nodes in View');
end
swarmWorld.nodesInView = V;
swarmWorld.signals = signals;
%fprintf('Cuml LR after msmt update : %3.3f\n', sum(exp(swarmWorld.log_likelihood)) );

end
