% Main script for Sheng's test flights at F3 using MATLAB

% This script is adopted from F3CheckoutFlight.m by S. Cheng
% 
% Nov. 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;
rosshutdown; % in case there is a leftover instance

% Assumes
% MACE, ROS_MACE, roscore, running 

% Steps
% 1. Update 'ROS_MACE.ip' address in loadParams_testingF3()
% 2. Update agentID to correspond to the Arducopter sim
% 3. Run this script
% (See README.txt for further details)

% Setup ROS_MACE
[runParams, ROS_MACE] = loadParams_cityblocksAtF3();
ROS_MACE = setupF3FlightTestPlot( runParams, ROS_MACE);

% temporary fix to allow plotting with time on ROS message callback
% will be replaced with MACE timestamp when available
global tStart;
tStart = tic;

% global variable for getting the most updated agent yaw angle
global agentYawAngle 
% This variable stores the most recent 
% yaw angles of all agents. Each row stores the yaw angle of an agent 
% in radian

% global variable for getting the most updated agent position
global agentPosition
% This variable stores the most recent
% position of all agents. 
% First column: x 
% Second column: y
% Third column: z 
% All in F3 coordinates. Each row stores the location for an agent in
% meters.



% % ============= Test 1.5: delay test, Wpt Mission, and Land ==============
ROS_MACE.N = 1;
%ROS_MACE.operationalAlt = [4 8]; % m
%ROS_MACE.agentIDs = [1 2]; % m
ROS_MACE.operationalAlt = [2];% 4]; % m
ROS_MACE.agentIDs = [1];% 2]; % SYSID_THISMAV on each quadrotor

agentYawAngle = nan(ROS_MACE.N,1); 
agentPosition = nan(ROS_MACE.N,3);

ROS_MACE.agentIDtoIndex = zeros(1,max(ROS_MACE.agentIDs));
ROS_MACE.wptCoordinator = 'integrated';

for i = 1:1:ROS_MACE.N
    ROS_MACE.agentIDtoIndex( ROS_MACE.agentIDs(i) ) = i;
end

% evenly distribute N quads between y from 1m to 11m and -11m to -1m
temp = linspace(0,20,ROS_MACE.N+2);
temp = temp(2:end-1);
yLocation = temp(temp<10)-11;
yLocation = [yLocation temp(temp>=10)-9];

wpts = cell(1,ROS_MACE.N);

wpts{1} = [5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;5 -10;10 -10;];


ROS_MACE = launchROS( ROS_MACE );
swarmState = sendDatumAndWaitForGPS( ROS_MACE );
armAndTakeoff( ROS_MACE );
disp('Press any key to launch waypoint mission...')
pause;

% sound profile
amp=10;
fs=20500;  % sampling frequency
duration=0.5;
freq=1000;
values=0:1/fs:duration;
sound_sig=amp*sin(2*pi* freq*values);
ROS_MACE.sound = sound_sig;

captureRadius = 1;% 1.2;
wptManager( ROS_MACE, wpts, captureRadius);

disp('Press any key to land...')
pause;
land( ROS_MACE );
