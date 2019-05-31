function nodeXY = loadLineNodes(blockLength, L)
    base = [L/2:L:blockLength+L/2]';
    % build E/W street
    nodeXY = [base, zeros(size(base))+L/2 ];
    nodeXY = unique(nodeXY,'rows');
    plot(nodeXY(:,1), nodeXY(:,2),'o')    

end
