function swarmWorld = measurementUpdate(swarmWorld, swarmModel, signals, V)

% if all agents are in void space then no update is required
if ( ~isempty(signals) )
    logMsmtLikelihood = swarmModel.mZ*(signals - swarmModel.mZ/2); % convert signals to log-likelihood ratio
    
    % error check
    if ( length(signals) ~= length(V) )
        error('Incorrect lengths of signals and nodes v');
    end
    
    % data association is based on naive gating method:
    %gates = gateMsmts(V, swarmWorld);
    
    
    % apply likelihood update to each node
    for j = 1:1:length(V)
        S = findTargStatesInView(swarmWorld.Mc, V(j));
        %if ( gates{j} == 0 ) % update LRDT
        for k = 1:1:length(S)
            swarmWorld.log_likelihood(S(k)) =  swarmWorld.log_likelihood(S(k)) + logMsmtLikelihood(j);
        end
        %                     elseif (gates{j} ~= -1 ) % update trackers
        %                         fprintf('Updating tracker %d ! \n', gates{j});
        %                         for k = 1:1:length(gates{j})
        %                             ind = gates{j}(k);
        %                             for m = 1:1:length(S)
        %                                 swarmWorld.tracker{ind}.log_likelihood(S(m)) =  swarmWorld.log_likelihood(S(m)) + logMsmtLikelihood(j);
        %                             end
        %                         end
        %                     end
        
    end
end
if ( isempty(V) )
    disp('No Nodes in View');
end
swarmWorld.nodesInView = V;
swarmWorld.signals = signals;
%fprintf('Cuml LR after msmt update : %3.3f\n', sum(exp(swarmWorld.log_likelihood)) );

end
