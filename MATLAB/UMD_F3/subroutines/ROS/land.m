function land( ROS_MACE )

for i = 1:1:ROS_MACE.N
    % Setup Land command:
    landRequest = rosmessage(ROS_MACE.landClient);
    landRequest.Timestamp = rostime('now');
    landRequest.VehicleID = ROS_MACE.agentIDs(i);  
    landRequest.CommandID = 4; % TODO: Set command ID enum in MACE
    landResponse = call(ROS_MACE.landClient, landRequest, 'Timeout', 5);
    if ( landResponse.Success )
        fprintf('VehicleID %d Land Command Sent.\n',i);
    else 
        fprintf('VehicleID %d Land Command Failed.\n',i);
    end  
end

disp('Waiting for landing to complete...')
% Wait for each vehicle to achieve takeoff altitude
takeoffAchieved = zeros(1,ROS_MACE.N);
while( ~all(takeoffAchieved) )
%     msg = ROS_MACE.positionSub.LatestMessage;
    msgGeo = ROS_MACE.geopositionSub.LatestMessage;
%     positionCallback( ROS_MACE, msg, msgGeo); 
    positionCallback( ROS_MACE, msgGeo); 
%     if ( ~isempty(msg) && ~isempty(msgGeo) )
    if ( ~isempty(msgGeo) )
        agentIndex = ROS_MACE.agentIDtoIndex( msgGeo.VehicleID );
        if ( takeoffAchieved(agentIndex) == 0 )
            if ( abs(abs(msgGeo.Altitude) ) <= 0.75 )
                takeoffAchieved(agentIndex) = 1;
                fprintf('VehicleID %d Reached Ground  (+/- 0.5 m).\n', msgGeo.VehicleID);
            end
        end
    end
    pause(0.1);
end

disp('Run Complete.')
% killMACE;
% killMACE;
rosshutdown;
end