function swarmWorld = motionUpdate(swarmWorld, swarmModel)

% perform the motion update first for the LRDT
swarmWorld.log_likelihood = propagateLogLikelihood(swarmWorld.log_likelihood, swarmWorld.Q , swarmModel.q_s_n , swarmModel.q_n_s, swarmModel.q_n_n );

    %     % and then for each existing tracker
    %     for i  = swarmWorld.trackerInd
    %         swarmWorld.tracker{i}.log_likelihood = motionUpdate( swarmWorld.tracker{i}.log_likelihood , swarmWorld.Q , swarmModel.q_s_n, swarmModel.q_n_n );
    %     end

end