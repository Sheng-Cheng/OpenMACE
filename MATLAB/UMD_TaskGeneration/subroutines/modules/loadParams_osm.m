function [runParams, ROS_MACE, trueWorld, swarmModel, targetModel] = loadParams_osm(mapID,algorithmID,initialFormationID,targetMotionID)

% Simulation
runParams = struct;
runParams.type = 'matlab'; % 'matlab' 'mace' 'f3'
runParams.T = 15; %4*60;% total simulation/mission time
runParams.dt = 0.01; % time-step (even if MACE is running used for prediction)

% F3 Flight Test
ROS_MACE = [];

% Display
runParams.flags.movie = 1;
runParams.movie.useBackgroundImg = 0;
runParams.movie.plotF3Obstacles = 0;

% Swarm
swarmModel = struct;
swarmModel.N = 4; % number of agents
swarmModel.Rsense = 20; % sensing radius % 2 for F3 map % 20 for full map
swarmModel.vmax = 3; % maximum speed % 1 for F3 map % 20 for full map
swarmModel.umax = 2.0; % max acceleration
swarmModel.kp_wpt = 10.0; % agent waypoint control, proportional gain
swarmModel.kd_wpt = 5.0; % derivative gain
swarmModel.Tsamp = 1; % sample time

% Monte carlo
swarmModel.useGeneratedInitialFormation = 0;
swarmModel.useGeneratedTargetMotion = 0; % 0 will use a random target motion
%monteCarloFlag = 0;

% Communication / task allocation
% Options: 'stepwiseHungarian_unique' or 'none'
swarmModel.taskAllocation = 'stepwiseHungarian_unique';
swarmModel.samplesPerTask = 10;
swarmModel.bundleSize = 4;
swarmModel.knnNumber = 10;

% Task Generation
% Options 'mutualInfoWpts' , 'randomWpts' , 'lawnmower'
swarmModel.taskGeneration = 'mutualInfoWpts';
swarmModel.numTasks = 100;
swarmModel.stepSizeGain = 0.2;
swarmModel.percentTol = 0.03;
swarmModel.maxIters = 500;

% Mapping
swarmModel.nG = 25; % number of discrete sensor levels
swarmModel.mG = 3; % sensitivity
swarmModel.mapConfLevel = 0.95;

% Detection / Tracking (LRDT)
swarmModel.LRDTOnTheFlyFlag = 1;
swarmModel.nodeDensityInitGuess = 1/6; % used on first step before kriging takes place
swarmModel.probAbsentPrior = 0.50; % for initialization
swarmModel.decayRate = 0.05; % value from 0 to 1
swarmModel.terminateSimOnDetect = 0;
swarmModel.confLevel = 0.95;
swarmModel.mZ = 3;
swarmModel.nZ = 25;

% Target
targetModel = struct;
% options: 'constantSpeedRandomWalk' or 'generative'
targetModel.type = 'constantSpeedRandomWalk';
targetModel.M = 1; % number of targets
targetModel.probStopping = 0.75;
targetModel.m = 1.0;
targetModel.d = 0.1;
targetModel.inertia = 100; % a value greater than zero

% Environment/Map
% load environment the full map
trueWorld = struct;
trueWorld.type = 'openStreetMap'; % 'cityblocks', %'openStreetMap', 'osmAtF3'
trueWorld.borderOffset = 0; % used for adding padding to the map
trueWorld.folder = './data/'; % folder with map file
trueWorld.binWidth = 5;
trueWorld.boxlength = 300;
trueWorld.boxwidth = 300;
trueWorld.buffer = 0;
trueWorld.mapID = 1; % choose 1, 2, or 3

% override default values if this is a monte-carlo run
nargin
if nargin == 1
    trueWorld.mapID = mapID;
end
if nargin == 4
    swarmModel.useGeneratedTargetMotion = 1;
    swarmModel.algorithmID = algorithmID;
    
    swarmModel.useGeneratedInitialFormation = 1; % 1 will load pre-randomly generated initial formation
    swarmModel.initialFormationID = initialFormationID; % load the ID of the initial formation
    
    swarmModel.useGeneratedTargetMotion = 1; % 1 will load pre-randomly generated target motion
    swarmModel.targetMotionID = targetMotionID; % load the ID of the initial formation
    
    switch algorithmID
        case 1
            swarmModel.taskGeneration = 'mutualInfoWpts';
            swarmModel.taskAllocation = 'stepwiseHungarian_unique';
        case 2
            swarmModel.taskGeneration = 'lawnmower';
            swarmModel.taskAllocation = 'none';
        case 3
            swarmModel.taskGeneration = 'randomWpts';
            swarmModel.taskAllocation = 'none';
    end
    
    if swarmModel.useGeneratedTargetMotion
        load(['./scenes/targetMotion' num2str(swarmModel.targetMotionID) '_map_' num2str(mapID) '.mat']);  % load the generated data to replace the above parameters.
    end
    
    trueWorld.mapID = mapID;
end

switch trueWorld.mapID
    case 1 % Map 1:
        disp('Using Map 1');
        trueWorld.fileName = 'RandallsIsland_Big.osm';
        trueWorld.refX = -300;
        trueWorld.refY = -200;
        trueWorld.removeList = [10,16,29];
        trueWorld.angle = 0*pi/180;
        
    case 2 % Map 2:
        disp('Using Map 2');
        trueWorld.fileName = 'SilverSpring.osm';
        trueWorld.refX = -620;
        trueWorld.refY = 450;
        trueWorld.removeList = [];
        trueWorld.angle = 0*pi/180;
        
    case 3 % Map 3:
        disp('Using Map 3');
        trueWorld.fileName = 'NYC.osm';
        trueWorld.refX = 600;
        trueWorld.refY = -350;
        trueWorld.removeList = [];
        trueWorld.angle = 60*pi/180;
end

% derived
[runParams, ROS_MACE, trueWorld, swarmModel, targetModel] = derivedParams(runParams, ROS_MACE, trueWorld, swarmModel, targetModel);

end