% arducopter log processing
% add the external folder 'gps-measurement-tools-master'
% Sheng Cheng, Spring 2020

% first convert .bin or .log file to matlab data using missionplanner
load('2020-02-28 17-35-24.log-303422.mat');

% The columns in each variable can be referred in the variables with
% '_label' appended in the end.

% Convert time to EDT
timeUTC = datetime(Gps2Utc([GPS2(:,5) GPS2(:,4)/1000]));
timeEDT = timeUTC - hours(5);
% GPS2(:,5) is GPS week, GPS2(:,4) is GPS millisecond

% determine arducopter start time
timeUS0 = timeEDT(1)-seconds(GPS2(1,2)/1e6); % TimeUS is in microsecond

% GPS lat and long
GPSLat = GPS2(:,8);
GPSLong = GPS2(:,9);

figure;
plot(GPSLong,GPSLat);
xlabel('Longitude');
ylabel('Latitude');

% use the arducopter start time to refer about time associated with other
% variables
figure;
plot(timeUS0 + seconds(CTUN(:,2)/1e6),CTUN(:,8));
xlabel('time');
ylabel('altitude (m)');