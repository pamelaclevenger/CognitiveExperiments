% function [points, varargout] = polar2cartesian(num_items, distance, rotation = 0)

% Polar to cartesian function
% Give locations to your stimuli based on distance from center of screen
% rather than the upper left corner.

%input into the function:
% (1) num_items
%   The number of items around the circle.  Will be evenly distributed
%   around it, starting at the leftmost side of circle.
% (2) distance from center (in pixels)
%   How far in pixels each coordinate will be from the center of the screen
% (3) rotation (in degrees) Default = 0
%   If the user wants to rotate the items, input the number of degrees to
%   rotate by.

%If you don't want the circle centered on the center of the screen, then
%change the parameters in the for loop to add to the location of your
%choice.
global xCenter;
global yCenter;

stops = 360/num_items;
all_thetas = [0:stops:360] + rotation;

for i = 1:length(all_thetas);
    x = distance * cosd(all_thetas(i)) + xCenter;
    y = distance * sind(all_thetas(i)) + yCenter;
end

%Return a list of (x,y) coordinates.


    