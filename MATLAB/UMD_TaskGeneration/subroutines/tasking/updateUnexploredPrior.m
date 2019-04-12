function [V,U,O] = updateUnexploredPrior(cellStateMat, xx, yy, krigingSigma, numNodesExploredGraph, probAbsent, V, U, O)

% compute adaptive prior for an unexplored cell based on node density
% this becomes the floor
%[nodeDensityEstimate] = exploredAreaNodeDensity(cellStateMat);
%voidDensityEstimate = 1 - nodeDensityEstimate;

% interpolate cellStateMat to predict new nodes
xcp = xx(1,:);
ycp = yy(:,1)';
numBinsX = length(xcp);
numBinsY = length(ycp);

% determine which cells have been found to contain nodes
k = 1;
measurements = [];
for i = 1:1:numBinsY
    for j = 1:1:numBinsX
        if ( cellStateMat(i,j) ~= 2 ) % cellStateMat(j,i) == 1 )
            measurements(k,1) = xcp(j);
            measurements(k,2) = ycp(i);
            measurements(k,3) = V(i,j);
            k = k + 1;
        end
    end
end

% % debug: plot measurements
% figure; plot(measurements(:,3) ,'ko-')
% hold on;
% plot([1 length(measurements)],[1 1]*voidDensityEstimate, 'r--');

if ( ~isempty(measurements) )
    

    forecast = ordinaryKrig(xx,yy,measurements,krigingSigma);
    forecast(forecast > 1) = 1;
    forecast(forecast < 0) = 0;

%     % deviation from mean
%     %vals(:,3) = vals(:,3) - voidDensityEstimate;
%     
%     % performance a linear interpolation
%     predictedVoidMat = krigInterp(xx,yy,vals,krigingSigma);
%     
%     % scale
%     % predictedVoidMat = normalizeMatrix(predictedVoidMat, min( vals(:,3) ), max( vals(:,3) ) ) + voidDensityEstimate;
%     predictedVoidMat = normalizeMatrix(predictedVoidMat, min( vals(:,3) ), max( vals(:,3) ) );
%     
    % determine unexplored area    
    [rows, cols] = find(cellStateMat == 2);
    
    % used for prior of target
    numUnexploredCells = numBinsX*numBinsY - numNodesExploredGraph;
    factor = (1 - probAbsent)/numUnexploredCells;
    
    % assign prior
    for i = 1:1:length(rows)
        r = rows(i);
        c = cols(i);
        V(r,c) = forecast(r,c);
        % error check
        if ( V(r,c) < 0 || V(r,c) > 1)
            error('V(r,c) is not a valid probability');
        end
        O(r,c) = (1 - V(r,c))*factor;
        U(r,c) = 1 - O(r,c) - V(r,c);
    end    
end

end