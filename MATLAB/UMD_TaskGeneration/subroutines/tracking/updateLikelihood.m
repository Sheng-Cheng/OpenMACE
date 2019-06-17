function swarmWorld = updateLikelihood(swarmWorld, swarmState, swarmModel, trueWorld, targetState, targetModel)

if ( ~isempty(swarmWorld.log_likelihood) )
    
    % motionUpdate
    swarmWorld = motionUpdate(swarmWorld, swarmModel);
    
    % simulateTargetSensorCellWise
    [signals, V, swarmWorld.numViews] = simulateTargetSensorCellWise( swarmState, swarmModel, swarmWorld, trueWorld, targetState, targetModel );
    
    % measurementUpdate
    swarmWorld = measurementUpdate(swarmWorld, swarmModel, signals, V);
    
    % normalizeLogLikelihood
    [swarmWorld.log_likelihood, swarmWorld.tss_probPresent, swarmWorld.tss_probAbsent, swarmWorld.env_probPresent, swarmWorld.log_likelihood_env] = normalizeLogLikelihood(swarmWorld.log_likelihood, swarmWorld.Mc);    
    % also for all trackers
    for p = 1:1:length(swarmWorld.activeTrackerInd)
       ind = swarmWorld.activeTrackerInd(p);
       [swarmWorld.tracker{ind}.log_likelihood, swarmWorld.tracker{ind}.tss_probPresent, swarmWorld.tracker{ind}.tss_probAbsent, swarmWorld.tracker{ind}.env_probPresent, swarmWorld.tracker{ind}.log_likelihood_env] = normalizeLogLikelihood(swarmWorld.tracker{ind}.log_likelihood, swarmWorld.Mc);
    end
    
    % error check
    if ( any( isnan(swarmWorld.log_likelihood) ) )
        disp('Error: NaN in log_likelihood');
    end
    
    % callDetections (and spawn trackers)
    swarmWorld = callDetections(swarmWorld, swarmState, swarmModel, targetState, targetModel, trueWorld);
    
    % trackMaintenance
    swarmWorld = trackMaintenance(swarmWorld);
    
    % updatePriors
    swarmWorld = updatePriors(swarmWorld);
    
end


end

