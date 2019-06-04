function [runParams, ROS_MACE, trueWorld, swarmModel, targetModel] = loadParams_1Dline(algorithmID,initialFormationID,targetMotionID)

% Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runParams = struct;
runParams.type = 'matlab'; % 'matlab' 'mace' 'f3'
runParams.T = 1*60; %4*60;% total simulation/mission time
runParams.dt = 0.01; % time-step (even if MACE is running, Sheng needs this for cost computation)


% F3 Flight Test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROS_MACE = [];

% Display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runParams.flags.movie = 1;
runParams.movie.useBackgroundImg = 0; %
runParams.movie.plotF3Obstacles = 0;

% Swarm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
swarmModel = struct;
swarmModel.N = 2; % number of agents
swarmModel.Rsense = 10; % sensing radius % 2 for F3 map % 20 for full map
swarmModel.vmax = 3; % maximum speed % 1 for F3 map % 20 for full map
swarmModel.umax = 2.0; % max acceleration
swarmModel.kp_wpt = 10.0; % agent waypoint control, proportional gain
swarmModel.kd_wpt = 5.0; % derivative gain
swarmModel.Tsamp = 1; % sample time

% agents follow a double integrator model with xdot = Ax + Bu and
% saturation on the input u. A, and B are defined below.
swarmModel.d = swarmModel.umax/swarmModel.vmax; % agent damping parameter
swarmModel.A = [0 0 1 0; 0 0 0 1; 0 0 -swarmModel.d 0; 0 0 0 -swarmModel.d];
swarmModel.B = [0 0; 0 0; 1 0; 0 1];
runParams.Tsamp = swarmModel.Tsamp; % make a copy


% Monte carlo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
swarmModel.useGeneratedInitialFormation = 0;
swarmModel.useGeneratedTargetMotion = 0; % 0 will use a random target motion
monteCarloFlag = 0;

% Communication / task allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
swarmModel.communicationTopology = 'centralized';   % options are: 'centralized' or 'allToAll'
swarmModel.taskAllocation = 'none'; %'stepwiseHungarian'; % options are: 'none', 'stepwiseHungarian', 'Hungarian' or 'Auctioneer';
switch swarmModel.taskAllocation
    case 'Hungarian'
        swarmModel.samplesPerTask = 5;
    case 'stepwiseHungarian' % original
        swarmModel.samplesPerTask = 10;
        swarmModel.bundleSize = 5;
        swarmModel.neighborMethod = 'knn';  % options are: 'VoronoiGraph' or 'knn'
    case 'stepwiseHungarian_unique' % original
        swarmModel.samplesPerTask = 10;
        swarmModel.bundleSize = 5;
        swarmModel.neighborMethod = 'knn';  
        swarmModel.knnNumber = 10;
    case 'stepwiseHungarian_max' % original
        swarmModel.samplesPerTask = 10;
        swarmModel.bundleSize = 4;
    case 'stepwiseHungarian_2ndOrder' % original
        swarmModel.samplesPerTask = 10;
        swarmModel.bundleSize = 4;
    
    case 'none'
        swarmModel.samplesPerTask = 5;
end

% Task Generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( nargin ~=3 ) % if running a single-run, use this value:
    swarmModel.taskGeneration = 'lawnmower'; % 'randomWpts', or 'frontierWpts', 'lawnmower' 'mutualInfoWpts'
end
switch swarmModel.taskGeneration
    case 'frontierWpts'
        swarmModel.wptChangePeriod = 10; % sec, how often we generate a new random wpt
        swarmModel.mapping.method = 'frontierAndBlob'; % options are: 'frontierOnly' or 'frontierAndBlob'
        swarmModel.mapping.minBlobArea = pi*swarmModel.Rsense^2*2;  % threshold for the minimum area of a blob
        swarmModel.mapping.maxMajorMinorAxisRatio = 10; % threshold for the ratio between majoraxislength and minor axis length of a subblob, give inf if you do not want to apply this filter
        swarmModel.mapping.blobCostScale = 1.4; % scale the cost for reaching a subblob centroid by this amount
    case 'mutualInfoWpts'
        swarmModel.numTasks = 100;
        swarmModel.stepSizeGain = 0.2;
        swarmModel.percentTol = 0.03;
        swarmModel.maxIters = 500;
    case 'likelihoodWpts'
        swarmModel.numTasks = 200;
        swarmModel.stepSizeGain = 0.2;
        swarmModel.percentTol = 0.03;
        swarmModel.maxIters = 500;
end

swarmModel.mapping.krigingSigma = 10; % controls how much kriging interp diffuses
swarmModel.utilityComputation = 'computeInformationGain'; % options are: 'computeEnergyAndPenalty' or 'computeInformationGain'
swarmModel.planningHorizon = swarmModel.samplesPerTask * swarmModel.Tsamp; %runParams.T; %


% Mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
swarmModel.mappingSensorType = 'noisy'; % 'noisy' or 'perfect'
if ( strcmp(swarmModel.mappingSensorType,'noisy') )
    if ( nargin ~=3 )
        swarmModel.mG = 3; % sensitivity
    end
    swarmModel.nG = 100; % number of discrete sensor levels
    swarmModel.mapConfLevel = 0.95;
    swarmModel.nodeLRthresh = swarmModel.mapConfLevel / (1 - swarmModel.mapConfLevel); % initial value
    % derived
    swarmModel.gval = linspace(-3,swarmModel.mG+3,swarmModel.nG);
    for l = 1:1:swarmModel.nG
        swarmModel.g_V(l) = exp(-(swarmModel.gval(l))^2/2);
        swarmModel.g_UO(l) = exp(-(swarmModel.gval(l)-swarmModel.mG)^2/2);
    end
    swarmModel.g_V = swarmModel.g_V ./ sum(swarmModel.g_V);
    swarmModel.g_UO = swarmModel.g_UO ./ sum(swarmModel.g_UO);
end

% Detection / Tracking (LRDT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%swarmModel.Pd = 0.85;
%swarmModel.Pfa = 0.15;
swarmModel.sensorType = 'discrete_per_cell'; % options are : 'continuous_per_fov' or 'discrete_per_cell'
swarmModel.LRDTOnTheFlyFlag = 1;
%swarmModel.maxUnexploredPrior = 0.85;
swarmModel.nodeDensityInitGuess = 1/3; % used on first step before kriging takes place
swarmModel.probAbsentPrior = 0.50; % for initialization
swarmModel.numNodesEstPercent = 1/5; 

swarmModel.decayRate = 0.05; % value from 0 to 1
swarmModel.q_s_n =  swarmModel.decayRate*(1-swarmModel.probAbsentPrior);
swarmModel.q_n_s =  swarmModel.decayRate*swarmModel.probAbsentPrior;

swarmModel.LReqbm = swarmModel.q_s_n / swarmModel.q_n_s; % note LR reaches eqbm value equal to q_s_n/q_n_s
swarmModel.q_n_n = 1 - swarmModel.q_s_n;


%swarmModel.m = zTransform(swarmModel.Pd) - zTransform(swarmModel.Pfa); % for sensor model / msmt likelihood
swarmModel.terminateSimOnDetect = 0;
swarmModel.confLevel = 0.95;
if ( nargin ~=3 )
    swarmModel.mZ = 3;
end
swarmModel.nZ = 100;

% derived
swarmModel.cumlLRthresh = swarmModel.confLevel / (1 - swarmModel.confLevel); % initial value
swarmModel.zval = linspace(-3,swarmModel.mZ+3,swarmModel.nZ);
for q = 1:1:swarmModel.nZ
    swarmModel.z_VU(q) = exp(-(swarmModel.zval(q))^2/2);
    swarmModel.z_O(q) = exp(-(swarmModel.zval(q)-swarmModel.mZ)^2/2);
end
swarmModel.z_VU = swarmModel.z_VU ./ sum(swarmModel.z_VU);
swarmModel.z_O = swarmModel.z_O ./ sum(swarmModel.z_O);

% Target
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
targetModel = struct;
targetModel.M = 3; % number of targets
targetModel.type = 'constantSpeedRandomWalk'; % 'varyingSpeedRandomWalk' or 'constantSpeedRandomWalk'
targetModel.probStopping = 0.75;
targetModel.m = 1.0;
targetModel.d = 0.1;
switch targetModel.type
    case 'varyingSpeedRandomWalk'
        targetModel.maxSpeed = 10;
    case 'constantSpeedRandomWalk'
        targetModel.restPeriod = swarmModel.Tsamp;
        targetModel.inertia = 100; % a value greater than zero
        if (monteCarloFlag)
            if swarmModel.useGeneratedTargetMotion
                load(['./scenes/targetMotion' num2str(swarmModel.targetMotionID) '.mat']);  % load the generated data to replace the above parameters.
            end
        end
end

% Environment/Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load environment cityblocks
trueWorld = struct;
trueWorld.type = 'line'; % 'goxel', 'cityblocks', %'openStreetMap', 'osmAtF3', 'cityBlocksAtF3'
trueWorld.borderOffset = 10; % used for adding padding to the map
trueWorld.binWidth = 5; % distance used to declare two nodes as connected (use 7 for open street map)
trueWorld.folder = './data/'; % folder with map file
trueWorld.fileName = 'line';
trueWorld.blockLength = 500;

% % load environment smaller map at F3
% trueWorld = struct;
% trueWorld.type = 'osmAtF3'; % 'goxel', 'cityblocks', %'openStreetMap', 'osmAtF3'
% trueWorld.borderOffset = 0; % used for adding padding to the map
% trueWorld.folder = './data/'; % folder with map file
% trueWorld.binWidth=1;
% trueWorld.fileName = 'RandallsIsland_Big.osm';
% trueWorld.f3Workspace = 'full'; % 'full', 'right-square'
% trueWorld.refX = -350;
% trueWorld.refY = 80;
% trueWorld.angle = -37*pi/180;
% trueWorld.boxlength = 500;
% trueWorld.buffer = 1;

% load environment the full map
% trueWorld = struct;
% trueWorld.type = 'openStreetMap'; % 'cityblocks', %'openStreetMap', 'osmAtF3'
% trueWorld.borderOffset = 0; % used for adding padding to the map
% %trueWorld.binWidth = 1; % distance used to declare two nodes as connected (use 7 for open street map)
% trueWorld.folder = './data/'; % folder with map file
% trueWorld.fileName = 'RandallsIsland_Big.osm';
% trueWorld.binWidth = 5;
% trueWorld.refX = -300;
% trueWorld.refY = -200;
% trueWorld.angle = 0*pi/180;
% trueWorld.boxlength = 400;
% trueWorld.boxwidth = 400;
% trueWorld.buffer = 0;

% derived world model parameters
trueWorld = loadEnvironment(trueWorld, targetModel);

% given the sensing radius, measurements can only be obtained within some
% window of bins around the target
trueWorld.windowWidth = 3*ceil(swarmModel.Rsense/trueWorld.binWidth)+1;
trueWorld.halfWidth = floor((trueWorld.windowWidth-1)/2);

% Misc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( strcmp(runParams.type, 'matlab') )
    runParams.Nsim = floor(runParams.T/runParams.dt)+1; % number of time-steps to simulate
elseif ( strcmp(runParams.type, 'mace') )
    % origin in utm coordinates
    [ROS_MACE.XRef,ROS_MACE.YRef,ROS_MACE.utmzone] = deg2utm(ROS_MACE.LatRef,ROS_MACE.LongRef);
    ROS_MACE.N = swarmModel.N; % make copy
    % initial position of quads is along a line according to initSpacing
    xInit = linspace(ROS_MACE.xInit,ROS_MACE.xInit+ROS_MACE.initSpacing*ROS_MACE.N,ROS_MACE.N);
    yInit = ones(1,ROS_MACE.N)*ROS_MACE.yInit;
    % create arducopter script with these initial conditions
    generateArducopterCmds( ROS_MACE , xInit , yInit );
end




end
