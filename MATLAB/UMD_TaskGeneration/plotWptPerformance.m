%plotWptPerformance(swarmStateHist,swarmModel)
clear all;
close all;
clc;
load('F3FlightData_02_Jul_2019_154758.mat')
close all;

for j = 1:1:length(swarmStateHist)
    t(j) = swarmStateHist{j}.t;
    x(j,:) = swarmStateHist{j}.x;
    xd(j,:) = swarmStateHist{j}.xd;
    yd(j,:) = swarmStateHist{j}.yd;
end

%% default
params.kp = swarmModel.kp_wpt;
params.kd = swarmModel.kd_wpt;
params.umax = swarmModel.umax;
params.vmax = 0.25;
params.N = swarmModel.N;
params.d = swarmModel.umax/params.vmax; % agent damping parameter
params.A = [0 0 1 0; 0 0 0 1; 0 0 -params.d 0; 0 0 0 -params.d];
params.B = [0 0; 0 0; 1 0; 0 1];
%%
N = swarmModel.N;
numPts = length(t);
xsim(1,:) = swarmStateHist{1}.x;
for k = 2:1:numPts
    delt  = t(k) - t(k-1);
    %x0 = [ xsim(k-1,4*j-3); xsim(k-1,4*j-2); xsim(k-1,4*j-1); xsim(k-1,4*j)];
    x0 = xsim(k-1,:);
    % lookup waypoint desired
	params.xd = xd(k,:);
	params.yd = yd(k,:);
    % call ode45
    [tout,xout] = ode45(@(t,x) swarmWptODE(t,x,params),[0 delt],x0);
    % package output
    xsim(k,:)= xout(end,:);
end

% %%
% % optimize free parameters are kp, kd, umax
% lb = [0 0 0 0 0];
% ub = [20 20 3 3 10];
% x0 = [2.8156   13.8507    0.3782    0.7167];
% kp_kd_umax_opt = fmincon(@(p) wptFollowCostFunc(p,params,t,x,xd,yd), x0, [], [], [], [], lb, ub)
% 
% paramsOpt = params;
% paramsOpt.kp = kp_kd_umax_opt(1);
% paramsOpt.kd = kp_kd_umax_opt(2);
% paramsOpt.umax = kp_kd_umax_opt(3);
% paramsOpt.vmax = kp_kd_umax_opt(4);
% %paramsOpt.delay = kp_kd_umax_opt(5);
% paramsOpt.d = paramsOpt.umax/paramsOpt.vmax; % agent damping parameter
% paramsOpt.A = [0 0 1 0; 0 0 0 1; 0 0 -paramsOpt.d 0; 0 0 0 -paramsOpt.d];
% 
% %  use optimized
% params = paramsOpt;
% %%
% N = swarmModel.N;
% numPts = length(t);
% xopt(1,:) = swarmStateHist{1}.x;
% for k = 2:1:numPts
%     delt  = t(k) - t(k-1);
%     %x0 = [ xsim(k-1,4*j-3); xsim(k-1,4*j-2); xsim(k-1,4*j-1); xsim(k-1,4*j)];
%     x0 = xopt(k-1,:);
%     % lookup waypoint desired
% %     if ( t(k) > params.delay )
% %         tdelay = t(k)-params.delay;
% %         params.xd  = interp1(t,xd,tdelay);
% %         params.yd = interp1(t,yd,tdelay);
% %         
% %     else               
%         params.xd = xd(k,:);
%         params.yd = yd(k,:);
% %     end
%     % call ode45
%     [tout,xout] = ode45(@(t,x) swarmWptODE(t,x,params),[0 delt],x0);
%     % package output
%     xopt(k,:)= xout(end,:);
% end
% 
% 

for j = 1:1:N
    figure(j)
    subplot(2,1,1);
    plot(t,xd(:,j),'x');
    hold on;
    plot(t,x(:,(j-1)*4+1));
    plot(t,xsim(:,(j-1)*4+1));
%     plot(t,xopt(:,(j-1)*4+1));
    set(gca,'FontSize',16)
    ylabel('X Pos (m)');
    subplot(2,1,2);
    plot(t,yd(:,j),'x');
    hold on;
    plot( t, x(:,(j-1)*4+2) );
    plot(t,xsim(:,(j-1)*4+2));
%     plot(t,xopt(:,(j-1)*4+2));
    legend('Wpts','Actual','Default Model','Optimized Model');
    set(gca,'FontSize',16)
    xlabel('Time (sec.)')
    ylabel('Y Pos (m)');
end
% 
% end