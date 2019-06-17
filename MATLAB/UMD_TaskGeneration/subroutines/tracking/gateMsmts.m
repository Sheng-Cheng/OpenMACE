function gates = gateMsmts(V, swarmWorld)
% V is a list of occupancy graph nodes
% gate{i} = 0; % means V(i) is on LRDT only
% gate{i} = [a b c]; % V(i) is in gates of trackers a, b, c
% gates is cell array of same size as V

numActiveTrackers = length(swarmWorld.activeTrackerInd);
if ( numActiveTrackers > 0 )
    
    threshPercent = 0.85; % of max
    d = 3;
    
    % for each track:
    for i  = 1:1:length(swarmWorld.activeTrackerInd)

        % track index
        ind = swarmWorld.activeTrackerInd(i);
        
        % adaptive threshold
        minL = min(swarmWorld.tracker{ind}.log_likelihood);
        maxL = max(swarmWorld.tracker{ind}.log_likelihood);    
        thresh = minL + (maxL - minL)*0.85;   
        
        % determine peak nodes that surpass threshold
        tssNodes = [1:1:numnodes(swarmWorld.targetStateSpaceGraph)];
        peakTssNodes = tssNodes( swarmWorld.tracker{ind}.log_likelihood > thresh );
        
        % convert to environment nodes
        envNodes = targNodes2envNodes( swarmWorld.Mc , swarmWorld.Mp , peakTssNodes );
        
        % find nearest nodes, within distance d, of the peak nodes
        gateNodes{i} = envNodes;
        
        for n = envNodes          
            gateNodes{i} = [gateNodes{i} transpose(nearest( swarmWorld.exploredGraph ,n,d))];
        end
        gateNodes{i} = unique(gateNodes{i},'sorted');
        
    end
    
    % for each measurement V
    for i = 1:1:length(V)
        
        v = V(i); % current msmt node
        gates{i} = []; % initialize gate
        
        % check if it belongs to a gate
        for j = 1:1:length(swarmWorld.activeTrackerInd)
            if ( ismember(v, gateNodes{j} ) )
                gates{i} = [gates{i}  swarmWorld.activeTrackerInd(j)];
            end
        end
        
        % otherwise
        if ( isempty(gates{i}) )
                gates{i} = -1;
        end
        
    end
   
else
    gates = [];
end

end