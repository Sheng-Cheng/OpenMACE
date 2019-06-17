function movie_lrdt_1D( swarmWorldHist, swarmStateHist, targetStateHist, trueWorld, runParams, swarmModel, targetModel )
figure;
rows = 6;
cols = 2;
spArray(1) = subplot(rows,cols,[1 2]);
spArray(2) = subplot(rows,cols,[3 4]);
spArray(3) = subplot(rows,cols,[5 6]);
spArray(4) = subplot(rows,cols,[7 8]);
spArray(5) = subplot(rows,cols,9);
spArray(6) = subplot(rows,cols,10);
% options
%   'groundTruth',
%   'likelihoodTargetStateExplored',
%   'frontierWpts',
%   'likelihoodOccupancyGraphExplored',
%   'cellAge',
%   'cellState',
%   'krigingInterp'
% 
spTypes = {'LikelihoodOccupancyGraphExplored','Track1','Track2','Track1','TargetViews','CumlLR'}; %Artur
playMovie(swarmWorldHist, swarmStateHist, targetStateHist, trueWorld, runParams, swarmModel, targetModel,spArray, spTypes);




end