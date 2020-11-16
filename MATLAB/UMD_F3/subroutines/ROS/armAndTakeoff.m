function armAndTakeoff( ROS_MACE )

global agentPosition

% % set home
% disp('Call set home command');
% 
% % Setup datum command:
% homeRequest = rosmessage(ROS_MACE.sethomeClient);
% 
% for i = 1:1:ROS_MACE.N
%     homeRequest.Timestamp = rostime('now');
%     homeRequest.VehicleID = ROS_MACE.agentIDs(i); % Not necessary for this
%     homeRequest.SetToCurrent = true; % TODO: Set command ID enum in MACE
%     
%     datumResponse = call(ROS_MACE.sethomeClient, homeRequest, 'Timeout', 5);
%     pause(2);
% end
% 
% 
% % Setup Arm vehicle command:
% armRequest = rosmessage(ROS_MACE.armClient);
% armRequest.CommandID = 1; % TODO: Set command ID enum in MACE
% armRequest.ArmCmd = true; % True to ARM throttle, False to DISARM
% 
% for i = 1:1:ROS_MACE.N
%     armResponse = false;    
%     armRequest.Timestamp = rostime('now');    
%     armRequest.VehicleID = ROS_MACE.agentIDs(i); % Vehicle ID
%     armResponse = call(ROS_MACE.armClient, armRequest, 'Timeout', 5);
%     if ( armResponse.Success )
%         fprintf('VehicleID %d Arm Command Sent.\n',ROS_MACE.agentIDs(i));
%         %%%%%% Add Arm lights here %%%%%%%
%         colors("Arm"); % Added, needs recoding: This command changes the color display of ALL quads. But the location of this line only works for quad i.
%     else 
%         fprintf('VehicleID %d Arm Command Failed.\n',ROS_MACE.agentIDs(i));
%         colors("Error"); % Added, needs recoding: This command changes the color display of ALL quads. But the location of this line only works for quad i.
%     end    
% end
% disp('Arm Complete. Begin Takeoff.')
% 
% countdownVerbose(1*ROS_MACE.N);
% 
% 
% % Setup Vehicle takeoff command:
% takeoffRequest = rosmessage(ROS_MACE.takeoffClient);
% takeoffRequest.CommandID = 2; % TODO: Set command ID enum in MACE
% for i = 1:1:ROS_MACE.N    
%     takeoffResponse = false;
%     takeoffRequest.Timestamp = rostime('now');
%     takeoffRequest.VehicleID = ROS_MACE.agentIDs(i);  
%     takeoffRequest.TakeoffAlt = ROS_MACE.operationalAlt(i); % Takeoff altitude
%     % If you don't set lat/lon (or set them to 0.0), it will takeoff in current position
%     % takeoffRequest.LatitudeDeg = 0.0; % If 0.0, takeoff where you currently are
%     % takeoffRequest.LongitudeDeg = 0.0; % If 0.0, takeoff where you currently are
% %     takeoffRequest
%     takeoffResponse = call(ROS_MACE.takeoffClient, takeoffRequest, 'Timeout', 5);
%     if ( takeoffResponse.Success )
%         fprintf('VehicleID %d Takeoff Command Sent.\n',ROS_MACE.agentIDs(i));
%         colors(0, "white", 2); % Added, needs changing to quad i
%     else 
%         fprintf('VehicleID %d Takeoff Command Failed.\n',ROS_MACE.agentIDs(i));
%         colors("Error"); % Added, needs changing to quad i
%     end    
% end
% disp('Waiting for takeoff to complete...');

%% =========== start new arm and takeoff sequence
% set home
disp('Call set home command');

% Setup datum command:
homeRequest = rosmessage(ROS_MACE.sethomeClient);
% Setup Arm vehicle command:
armRequest = rosmessage(ROS_MACE.armClient);
armRequest.CommandID = 1; % TODO: Set command ID enum in MACE
armRequest.ArmCmd = true; % True to ARM throttle, False to DISARM
% Setup Vehicle takeoff command:
takeoffRequest = rosmessage(ROS_MACE.takeoffClient);
takeoffRequest.CommandID = 2; % TODO: Set command ID enum in MACE

for i = 1:1:ROS_MACE.N
    homeRequest.Timestamp = rostime('now');
    homeRequest.VehicleID = ROS_MACE.agentIDs(i); % Not necessary for this
    homeRequest.SetToCurrent = true; % TODO: Set command ID enum in MACE
    
    datumResponse = call(ROS_MACE.sethomeClient, homeRequest, 'Timeout', 5);
    
    for kk = 1:4
        updatePlot(ROS_MACE);
        pause(0.5);
    end
    
    armResponse = false;    
    armRequest.Timestamp = rostime('now');    
    armRequest.VehicleID = ROS_MACE.agentIDs(i); % Vehicle ID
    armResponse = call(ROS_MACE.armClient, armRequest, 'Timeout', 5);
    if ( armResponse.Success )
        fprintf('VehicleID %d Arm Command Sent.\n',ROS_MACE.agentIDs(i));
        %%%%%% Add Arm lights here %%%%%%%
        colors("Arm"); % Added, needs recoding: This command changes the color display of ALL quads. But the location of this line only works for quad i.
    else 
        fprintf('VehicleID %d Arm Command Failed.\n',ROS_MACE.agentIDs(i));
        colors("Error"); % Added, needs recoding: This command changes the color display of ALL quads. But the location of this line only works for quad i.
    end   
    
    for kk = 1:4
        updatePlot(ROS_MACE);
        pause(0.5);
    end
    
    takeoffResponse = false;
    takeoffRequest.Timestamp = rostime('now');
    takeoffRequest.VehicleID = ROS_MACE.agentIDs(i);  
    takeoffRequest.TakeoffAlt = ROS_MACE.operationalAlt(i); % Takeoff altitude
    % If you don't set lat/lon (or set them to 0.0), it will takeoff in current position
    % takeoffRequest.LatitudeDeg = 0.0; % If 0.0, takeoff where you currently are
    % takeoffRequest.LongitudeDeg = 0.0; % If 0.0, takeoff where you currently are
%     takeoffRequest
    takeoffResponse = call(ROS_MACE.takeoffClient, takeoffRequest, 'Timeout', 5);
    if ( takeoffResponse.Success )
        fprintf('VehicleID %d Takeoff Command Sent.\n',ROS_MACE.agentIDs(i));
        colors(0, "white", 2); % Added, needs changing to quad i
    else 
        fprintf('VehicleID %d Takeoff Command Failed.\n',ROS_MACE.agentIDs(i));
        colors("Error"); % Added, needs changing to quad i
    end   
    for kk = 1:1
        updatePlot(ROS_MACE);
        pause(0.5);
    end
end

disp('Waiting for takeoff to complete...');

% ==== end new arm and takeoff sequence


% Wait for each vehicle to achieve takeoff altitude
takeoffAchieved = zeros(1,ROS_MACE.N);
% use the counter to count the number of times when a vehicle sits on the
% gorund
onGroundCounter = zeros(1,ROS_MACE.N);

while( ~all(takeoffAchieved) )

    for k = 1:ROS_MACE.N
        if((abs(agentPosition(k,3)-ROS_MACE.operationalAlt(k)) <= 0.2) && (takeoffAchieved(k)==0 ))
            takeoffAchieved(k) = 1;
            onGroundCounter(k) = 0;
            fprintf('VehicleID %d Reached Takeoff Altitude (+/- 0.20 m).\n', ROS_MACE.agentIDs(k));
            colors(0, "green", 1); % Added
            
        elseif (abs(agentPosition(k,3)-0) <= 0.2 && takeoffAchieved(k) == 0) % when the vehicle is still on the ground
            if onGroundCounter(k) >= 4
                fprintf('VehicleID %d NOT takeoff. \n',ROS_MACE.agentIDs(k));
            end
            onGroundCounter(k) = onGroundCounter(k) + 1;
            if onGroundCounter(k) > 10 % if the accumulated time is beyond 10, then rearm and takeoff the quad
                % arm
                armResponse = false;
                armRequest.Timestamp = rostime('now');
                armRequest.VehicleID = ROS_MACE.agentIDs(k); % Vehicle ID
                armResponse = call(ROS_MACE.armClient, armRequest, 'Timeout', 5);
                if ( armResponse.Success )
                    fprintf('VehicleID %d Arm Command Resent.\n',ROS_MACE.agentIDs(k));
                    %%%%%% Add Arm lights here %%%%%%%
                    colors("Arm"); % Added, needs recoding: This command changes the color display of ALL quads. But the location of this line only works for quad i.
                else
                    fprintf('VehicleID %d Arm Command Resend Failed.\n',ROS_MACE.agentIDs(k));
                    colors("Error"); % Added, needs recoding: This command changes the color display of ALL quads. But the location of this line only works for quad i.
                end
                
                pause(0.5);
                % takeoff
                takeoffResponse = false;
                takeoffRequest.Timestamp = rostime('now');
                takeoffRequest.VehicleID = ROS_MACE.agentIDs(k);
                takeoffRequest.TakeoffAlt = ROS_MACE.operationalAlt(k); % Takeoff altitude
                % If you don't set lat/lon (or set them to 0.0), it will takeoff in current position
                % takeoffRequest.LatitudeDeg = 0.0; % If 0.0, takeoff where you currently are
                % takeoffRequest.LongitudeDeg = 0.0; % If 0.0, takeoff where you currently are
                takeoffRequest
                takeoffResponse = call(ROS_MACE.takeoffClient, takeoffRequest, 'Timeout', 5)
                if ( takeoffResponse.Success )
                    fprintf('VehicleID %d Takeoff Command Resent.\n',ROS_MACE.agentIDs(k));
                    colors(0, "white", 2); % Added, needs changing to quad i
                else
                    fprintf('VehicleID %d Takeoff Command Resend Failed.\n',ROS_MACE.agentIDs(k));
                    colors("Error"); % Added, needs changing to quad i
                end
                
                % clear
                onGroundCounter(k) = 0;
            end
        end
        updatePlot(ROS_MACE);
        pause(0.1);
    end
end

% while( ~all(takeoffAchieved) )
%     msg = ROS_MACE.positionSub.LatestMessage;  
% %     msgGeo = ROS_MACE.geopositionSub.LatestMessage;
% %     positionCallback( ROS_MACE, msg); 
%     updatePlot(ROS_MACE);
%     if ( ~isempty(msg))
%         agentIndex = ROS_MACE.agentIDtoIndex( msg.VehicleID );
%         if ( takeoffAchieved(agentIndex) == 0 )
%             if ( abs(abs(msg.Altitude) - ROS_MACE.operationalAlt(agentIndex)) <= 0.20 )
%                 takeoffAchieved(agentIndex) = 1;
%                 fprintf('VehicleID %d Reached Takeoff Altitude (+/- 0.20 m).\n', msg.VehicleID);
%             end
%         end
%     end
%     pause(0.1);
% end

end