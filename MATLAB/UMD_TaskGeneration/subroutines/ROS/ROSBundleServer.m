function resp = ROSBundleServer(~,req,resp)

global bundleSource

VehicleID = req.VehicleID;

if isempty(bundleSource)
    source = zeros(12);
else
    source = bundleSource;
end

resp.BundleID = source(VehicleID,1);
resp.Altitude1 = source(VehicleID,2);
resp.Altitude2 = source(VehicleID,2);
resp.Altitude3 = source(VehicleID,2);
resp.Altitude4 = source(VehicleID,2);
resp.Altitude5 = source(VehicleID,2);

resp.Easting1 = source(VehicleID,3);
resp.Northing1 = source(VehicleID,4);
resp.Easting2 = source(VehicleID,5);
resp.Northing2 = source(VehicleID,6);
resp.Easting3 = source(VehicleID,7);
resp.Northing3 = source(VehicleID,8);
resp.Easting4 = source(VehicleID,9);
resp.Northing4 = source(VehicleID,10);
resp.Easting5 = source(VehicleID,11);
resp.Northing5 = source(VehicleID,12);

% if req.VehicleID == 1
%     resp.BundleID = 10;
%     resp.Northing1 = 10;
%     resp.Easting1 = 10;
%     resp.Altitude1 = 10;
%     resp.Northing2 = 20;
%     resp.Easting2 = 20;
%     resp.Altitude2 = 20;
%     resp.Northing3 = 30;
%     resp.Easting3 = 40;
%     resp.Altitude3 = 40;
%     resp.Northing4 = 40;
%     resp.Easting4 = 40;
%     resp.Altitude4 = 40;
%     resp.Northing5 = 50;
%     resp.Easting5 = 50;
%     resp.Altitude5 = 50;
% else
%     resp.BundleID = 100;
%     resp.Northing1 = 100;
%     resp.Easting1 = 100;
%     resp.Altitude1 = 100;
%     resp.Northing2 = 200;
%     resp.Easting2 = 200;
%     resp.Altitude2 = 200;
%     resp.Northing3 = 300;
%     resp.Easting3 = 400;
%     resp.Altitude3 = 400;
%     resp.Northing4 = 400;
%     resp.Easting4 = 400;
%     resp.Altitude4 = 400;
%     resp.Northing5 = 500;
%     resp.Easting5 = 500;
%     resp.Altitude5 = 500;
% end