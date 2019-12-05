% This function will send color commands to the quads via the XBee/Arduino

% Much of the code comes from testZigBeePacket.m and uses ZigBeePacketLED.m
% to properly format the XBee message 
% Inputs:  1 input >> 'Arm', 'Disarm', 'Waypoint'
%          3 inputs >> 1. receiver >> enter QUAD_ID
%                      2. color >> 'red', 'blue', 'green', 'white',
%                                  'black', or [R G B]
%                      3. mode >> 1 (standard), 2 (Flash), 3 (Fast Flash)

% function  colors(receiver, color, other)
function colors(varargin)
RIGHT = [0 255 0];
LEFT = [255 0 0];
if nargin == 3
    target = varargin{1}; color = varargin{2}; mode = varargin{3};
% Preset Colors
    tf = isa(color, 'string');
    if tf == 1
        if color == "red"
            rgb = [255 0 0]
        elseif color == "blue"
            rgb = [0 0 255]
        elseif color == "green"
            rgb = [0 255 0] 
        elseif color =="white"
            rgb = [255 255 255] 
        elseif color == "black"
            rgb = [0 0 0]
        end
    else rgb = color
    end
    colorArray = [rgb rgb RIGHT RIGHT rgb rgb LEFT LEFT rgb rgb LEFT LEFT rgb rgb RIGHT RIGHT];
end
if nargin == 1
    if varargin{1} == "Arm"
        green = [255 0 0];
        colorArray = [green green green green green green green green green green green green green green green green]
        mode = 2; % Flash
    
    elseif varargin{1} == "Disarm"
        red = [0 255 0];
        colorArray = [red red red red red red red red red red red red red red red red]
        mode = 2; % Flash
    
    elseif varargin{1} == "Waypoint"
        white = [255 255 255];
        colorArray = [white white white white white white white white white white white white white white white white]
        mode = 3; % Fast Flash
    end
end

msg = [target colorArray mode];

% generate the packet
APIpacket = ZigBeePacket(1,msg);

% send
serialMsg = sscanf(APIpacket, '%2x');

% open a serial port
s = serialport('/dev/ttyUSB0',9600);

write(s, serialMsg, 'uint8');

delete(s);


end