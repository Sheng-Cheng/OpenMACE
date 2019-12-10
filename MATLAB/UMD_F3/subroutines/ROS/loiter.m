% Stop all vechiles at their current location
%
% Sheng Cheng, Nov. 2019
function loiter(ROS_MACE)

for k = 1:ROS_MACE.N
    kinematicLocalCommand(ROS_MACE,ROS_MACE.agentIDs(k),[],[],[],'ENU',0,0,0,'ENU',[],0);
    fprintf('Vehicle %d enters LOITER mode.\n',ROS_MACE.agentIDs(k));
end