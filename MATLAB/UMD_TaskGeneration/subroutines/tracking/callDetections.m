function swarmWorld = callDetections(swarmWorld, swarmState, swarmModel, targetState, targetModel, trueWorld)

   % cumulative likelihood ratio
    swarmWorld.cumlLR = sum(exp(swarmWorld.log_likelihood));
    
    % Call detections
    if ( swarmWorld.cumlLR >= swarmModel.cumlLRthresh && swarmWorld.targetDetectedFlag==0 )
        swarmWorld.targetDetectedFlag = 1;
        disp('Target Detected!')
        fprintf('Target Detected! cumlLR = %3.1f >= %3.1f \n', swarmWorld.cumlLR , swarmModel.cumlLRthresh);
        
        swarmWorld.timeAtDetection = swarmState.t;
        
        % find node with greatest likelihood
        [maxVal, maxInd] = max(swarmWorld.env_probPresent);
        bx = swarmWorld.exploredGraph.Nodes.bx(maxInd);
        by = swarmWorld.exploredGraph.Nodes.by(maxInd);
        predictedTargXY = [trueWorld.xcp(bx) trueWorld.ycp(by)];
        
        % spawn a tracker
        newTrackInd = length(swarmWorld.tracker) + 1;
        fprintf('Spawning tracker %d based on node %d ! \n', newTrackInd, maxInd);
        
        % carve out likelihood
        d = 10;
        carveoutNodes = nearest(swarmWorld.exploredGraph,maxInd,d);
        carveoutStates = findTargStatesInView(swarmWorld.Mc, carveoutNodes);
        carveoutLikelihood = zeros(size(carveoutStates));
        
        % replace LRDT likelihood with prior
        % Approach 2 : static, initialize base on estimate of state-space size
        numNodesEst = (swarmModel.numNodesEstPercent*(trueWorld.numBinsX*trueWorld.numBinsY).^2) + (trueWorld.numBinsX*trueWorld.numBinsY); %
        log_pNom = log ( (1-swarmModel.probAbsentPrior)/numNodesEst / swarmModel.probAbsentPrior );
        
        
        %         % debug
        %         old_likelihood_tss = swarmWorld.log_likelihood;
        
        % add baseline probability to the new nodes
        for n = carveoutStates
            carveoutLikelihood = swarmWorld.log_likelihood(n);
            swarmWorld.log_likelihood(n) = log_pNom; % reset
        end
        [swarmWorld.log_likelihood, swarmWorld.tss_probPresent, swarmWorld.tss_probAbsent] = normalizeLogLikelihood(swarmWorld.log_likelihood);
        
        %         % debug
        %         figure;
        %         title('Target State Space Likelihood');
        %         plot(old_likelihood_tss,'o-'); hold on;
        %         plot(swarmWorld.log_likelihood,'o-')
        
        % create copy of map with new likelihood
        
        
        % get targets xy
        for i = 1:1:targetModel.M
            if ( strcmp(targetModel.type, 'varyingSpeedRandomWalk') )
                curNode = targetState.x(4*i-3,1);
            elseif( strcmp(targetModel.type, 'constantSpeedRandomWalk') || strcmp(targetModel.type, 'constantSpeedRandomWalkGenerative') )
                curNode = targetState.x(2*i-1,1);
            end
            targNodes(i) = curNode;
        end
        targetsXY = [ trueWorld.nodeX(targNodes) , trueWorld.nodeY(targNodes) ];
        
        % compute distance to each target
        for j = 1:1:targetModel.M
            distToTargs(j) = norm( predictedTargXY - targetsXY(j,:) );
        end
        
        % check if any target is in view
        targsInView = find( distToTargs < swarmModel.Rsense );
        
        % if there is a target in view:
        if ( ~isempty(targsInView) )
            swarmWorld.targetDetectionValid = 1;
            
            disp('Ground Truth: Detection is valid');
        else  % if there is no target in view:
            swarmWorld.targetDetectionValid = 0;
            disp('Ground Truth: Distance to targets');
            distToTargs
            disp('Ground Truth: Target Locations')
            targetsXY
            disp('Ground Truth: Predicted XY')
            predictedTargXY
            disp('Ground Truth: Detection is invalid!');
        end
    end