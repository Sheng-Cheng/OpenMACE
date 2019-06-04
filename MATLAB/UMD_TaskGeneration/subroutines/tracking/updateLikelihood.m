function swarmWorld = updateLikelihood(swarmWorld, swarmState, swarmModel, trueWorld, targetState, targetModel)

if ( ~isempty(swarmWorld.log_likelihood) )
    
    % motionUpdate
    swarmWorld = motionUpdate(swarmWorld, swarmModel);
    
    % simulateTargetSensorCellWise
    [signals, V, swarmWorld.numViews] = simulateTargetSensorCellWise( swarmState, swarmModel, swarmWorld, trueWorld, targetState, targetModel );
    
    % measurementUpdate
    swarmWorld = measurementUpdate(swarmWorld, swarmModel, signals, V);
    
    % normalizeLogLikelihood
    [swarmWorld.log_likelihood, swarmWorld.tss_probPresent, swarmWorld.tss_probAbsent] = normalizeLogLikelihood(swarmWorld.log_likelihood);
    
    % projectLikelihood (from target state graph onto environment graph)
    swarmWorld.env_probPresent = projectLikelihood( swarmWorld.tss_probPresent , swarmWorld.Mc );
    swarmWorld.log_likelihood_env = log(projectLikelihood( exp(swarmWorld.log_likelihood) , swarmWorld.Mc ));
    
    % error check
    if ( any( isnan(swarmWorld.log_likelihood) ) )
        disp('Error: NaN in log_likelihood');
    end
    
    % callDetections
    swarmWorld = callDetections(swarmWorld, swarmState, swarmModel, targetState, targetModel, trueWorld);
    
    % trackMaintenance
    swarmWorld = trackMaintenance(swarmWorld);
    
    % updatePriors
    swarmWorld = updatePriors(swarmWorld);
    
end


end

