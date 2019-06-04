function swarmWorld = trackMaintenance(swarmWorld)


    % trackMaintenance   
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
    
    
end