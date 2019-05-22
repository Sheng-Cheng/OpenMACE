function gates = gateMsmts(V, swarmWorld)
% gate{i} = -1 ; % means V(i) is not on occupancy graph
% gate{i} = 0; % means V(i) is on LRDT only
% gate{i} = [a b c]; % V(i) is in gates of trackers a, b, c
% gates is cell array of same size as V


thresh = 1;
d = 3;

% for each track:
for i  = 1:1:length(swarmWorld.trackerInd)
    
    % track index
    ind = swarmWorld.trackerInd(i);
    
    % determine peak nodes that surpass threshold
    peakNodes = ( swarmWorld.tracker{ind}.log_likelihood > thresh );
    
    % find nearest nodes, within distance d, of the peak nodes
    gateNodes{i} = peakNodes;
    for n = peakNodes
        gateNodes{i} = [gateNodes{i} nearest(G,n,d)];
    end
    gateNodes{i} = unique(gateNodes{i},'sorted');
    
end

% for each measurement V
for i = 1:1:length(V)
        
    v = V(i); % current msmt node        
    gates{i} = []; % initialize gate
    
    % check if it belongs to a gate
    for j = 1:1:length(swarmWorld.trackerInd)
        if ( ismember(v, gateNodes{j} ) )
           gates{i} = [gates{i}  swarmWorld.trackerInd(j)];
        end
    end
    
    % check if it is on the occupancy graph
    if ( isempty(gates{i}) )
       if ( ismember(v, graphNodes ) )
          gates{i} = 0;
       else
          gates{i} = -1; 
       end
    end
                
end

end