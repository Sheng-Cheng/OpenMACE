% Test script for sending API packets from the coordinator to remote Xbee
% devices
% October, 2019. Sheng Cheng

% Define some colors
color1 = [10 0 0]; color2 = color1; color3 = color1; test = [0 50 50];
RED = [0 255 0];
GREEN = [255 0 0];
BLUE = [0 0 255];
BLACK = [0 0 0];
WHITE = [255 255 255];

% Messages to be sent
receiver = [3];
% color = [test test RIGHT RIGHT test test LEFT LEFT test test LEFT LEFT test test RIGHT RIGHT];
color = [GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN GREEN ];
% status = 0 for solid color, status = 1 for fast flashing, status = 2 for
% slow flash
status = [0];

msg = [receiver color status];
% generate the packet
APIpacket = ZigBeePacket(1,msg);

% send
serialMsg = sscanf(APIpacket, '%2x');

% open a serial port
s = serialport('/dev/ttyUSB0',9600);

write(s, serialMsg, 'uint8');

delete(s);

