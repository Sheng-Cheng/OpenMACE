function swarmWorld = updateLikelihood(swarmWorld, swarmState, swarmModel, trueWorld, targetState, targetModel)

if ( ~isempty(swarmWorld.log_likelihood) )
    
    % figure(1);
    % subplot(4,1,1);
    % plot(swarmWorld.log_likelihood,'mo-');
    % hold on;
    % ylabel('log LR');
    % xlabel('Target State Index');
    % subplot(4,1,2);
    % plot(exp(swarmWorld.log_likelihood),'mo-');
    % hold on;
    % ylabel('LR');
    % xlabel('Target State Index');
    
    
    % 1. Motion Update
    % -------------------------------------------------------------------------
    
    % perform the motion update first for the LRDT
    swarmWorld.log_likelihood = motionUpdate( swarmWorld.log_likelihood , swarmWorld.Q , swarmModel.q_s_n, swarmModel.q_n_s, swarmModel.q_n_n );
    
%     % and then for each existing tracker
%     for i  = swarmWorld.trackerInd
%         swarmWorld.tracker{i}.log_likelihood = motionUpdate( swarmWorld.tracker{i}.log_likelihood , swarmWorld.Q , swarmModel.q_s_n, swarmModel.q_n_n );
%     end
    
    % 2. Measurement Update
    % -------------------------------------------------------------------------
    
    % % debug
    %fprintf('Cuml LR before msmt update : %3.3f\n', sum(exp(swarmWorld.log_likelihood)) );
    % figure(1);
    % subplot(4,1,1);
    % plot(swarmWorld.log_likelihood,'ko-');
    % hold on;
    % subplot(4,1,2);
    % plot(exp(swarmWorld.log_likelihood),'ko-');
    % hold on;
    
    
    switch swarmModel.sensorType
        case 'discrete_per_cell'
            % a signal is generated for each node in each agent's field of view
            [signals, V, swarmWorld.numViews] = simulateTargetSensorCellWise( swarmState, swarmModel, swarmWorld, trueWorld, targetState, targetModel );
            
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
    end
    
    % %debug
    % subplot(4,1,1);
    % plot(swarmWorld.log_likelihood,'ro-');
    % hold on;
    % legend('Prior','Motion Update','Measurement Update');
    % subplot(4,1,2);
    % plot(exp(swarmWorld.log_likelihood),'ro-');
    % legend('Prior','Motion Update','Measurement Update');
    % subplot(4,1,3);
    % plot(signals,'ro-');
    % hold on;
    % plot(ones(size(signals))*swarmModel.mZ,'k-');
    % ylabel('Signal')
    % xlabel('Index');
    %
    % subplot(4,1,4);
    % plot(logMsmtLikelihood,'bo-');
    % hold on;
    % ylabel('Log-likelihood from msmt')
    % xlabel('Node in View Index');
    
    
    
    
    swarmWorld.signals = signals;
    
    %fprintf('Cuml LR after msmt update : %3.3f\n', sum(exp(swarmWorld.log_likelihood)) );
    
    % 4. Normalize and compute cumulative likelihood ratio
    % -------------------------------------------------------------------------
    
    % recover bayesian probabilities (unscaled)
    likelihood = exp(swarmWorld.log_likelihood);
    likelihood_sum = sum( likelihood );
    swarmWorld.tss_probPresent = likelihood / (1 + likelihood_sum);
    swarmWorld.tss_probAbsent = 1 / (1 + likelihood_sum);
    totalProb_sum = sum(swarmWorld.tss_probPresent)  +  swarmWorld.tss_probAbsent;
    
    % normalize
    swarmWorld.tss_probPresent = swarmWorld.tss_probPresent / totalProb_sum;
    swarmWorld.tss_probAbsent = swarmWorld.tss_probAbsent / totalProb_sum;
    
    swarmWorld.env_probPresent = projectLikelihood( swarmWorld.tss_probPresent , swarmWorld.Mc );
    swarmWorld.log_likelihood = log( swarmWorld.tss_probPresent / swarmWorld.tss_probAbsent );
    
    % 3. Project likelihood
    % -------------------------------------------------------------------------
    % this projection operator sums along the states whose current node is the
    % one of interest
    
    if ( swarmModel.LRDTOnTheFlyFlag )
        swarmWorld.log_likelihood_env = log(projectLikelihood( exp(swarmWorld.log_likelihood) , swarmWorld.Mc ));
    else
        swarmWorld.log_likelihood_env = log(projectLikelihood( exp(trueWorld.log_likelihood) , trueWorld.Mc ));
    end
    
    
    % check
    if ( any( isnan(swarmWorld.log_likelihood) ) )
        disp('Error: NaN in log_likelihood');
    end
    
    % cumulative likelihood ratio
    if ( swarmModel.LRDTOnTheFlyFlag )
        swarmWorld.cumlLR = sum(exp(swarmWorld.log_likelihood));
    else
        swarmWorld.cumlLR = sum(exp(trueWorld.log_likelihood));
    end
    
    % Call detections
    % -------------------------------------------------------------------------
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
        
%         % spawn a tracker        
%         newTrackInd = length(swarmWorld.tracker) + 1;
%         fprintf('Spawning tracker %d based on node %d ! \n', newTrackInd, maxInd);
%         
%         % carve out likelihood
%         d = 10;
%         carveoutNodes = nearest(G,maxInd,d);
                
%         % replace LRDT likelihood with prior
%         for i = 1:1:length(carveoutNodes)
%             
%         end
        
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
    
%     % destroy trackers
%     % -------------------------------------------------------------------------
%     trackersToDestroy = [];
%     thresh = 1;
%     % for each tracker:
%     for i = 1:1:length(swarmWorld.trackerInd)
%         ind = swarmWorld.trackerInd(i);
%         % check if at least one node in track is above detection threshold
%         if ( ~any( swarmWorld.tracker{ind}.log_likelihood >= thresh ) )
%             trackersToDestroy = [trackersToDestroy ind]; 
%             fprintf('Destorying tracker %d ! \n', ind);
%         end        
%     end
    
   % simply removing the tracker from trackerInd is sufficient to destroy
   % swarmWorld.trackerInd = setdiff(swarmWorld.trackerInd, trackersToDestroy);       
    
    % update U, V
    % -------------------------------------------------------------------------
    
    % figure;
    % subplot(2,2,1)
    % imagesc(swarmWorld.V); caxis([0 1])
    % subplot(2,2,2)
    % imagesc(swarmWorld.U); caxis([0 1])
    % subplot(2,2,3)
    % imagesc(swarmWorld.O); caxis([0 1])
    % subplot(2,2,4)
    % imagesc(swarmWorld.O./swarmWorld.U);
    % colorbar;
    % title('Likelihood prior')
    
    sumL = sum(exp(swarmWorld.log_likelihood_env));
    %nullStateProb = swarmWorld.U(by,bx) = 1/(1 + sumL); % prob no target
    for i = 1:1:length(swarmWorld.log_likelihood_env)
        bx = swarmWorld.exploredGraph.Nodes.bx(i);
        by = swarmWorld.exploredGraph.Nodes.by(i);
        L = exp(swarmWorld.log_likelihood_env(i));
        swarmWorld.V(by,bx) = 0;
        
        %swarmWorld.O(by,bx) = L/(1 + sumL); % prob occupied
        swarmWorld.O(by,bx) = swarmWorld.env_probPresent(i);
        swarmWorld.U(by,bx) = (1 - swarmWorld.O(by,bx));
    end
    
    % figure;
    % subplot(2,2,1)
    % imagesc(swarmWorld.V); caxis([0 1])
    % subplot(2,2,2)
    % imagesc(swarmWorld.U); caxis([0 1])
    % subplot(2,2,3)
    % imagesc(swarmWorld.O); caxis([0 1])
    % subplot(2,2,4)
    % imagesc(swarmWorld.O./swarmWorld.U);
    % colorbar;
    % title('Likelihood update')
    
    
    
end


end

