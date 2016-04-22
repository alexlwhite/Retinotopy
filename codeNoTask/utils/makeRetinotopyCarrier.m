%ts = makeRetinotopyCarrier(c)
%
%by Alex White, 2015
%copied and modified from Paola's code
%
%Makes psychtoolbox textures of the radial checkerboard used as the
%"carrier" in the retinotopy stimulus
%
%input: 
% - c, a structure that contains pointers to an open PTB window
%as well as a sub-structure c.carrier with parameters for the checkerboard.
% 
%ouput: 
% - ts, a vector of pointers to the PTB textures that can be drawn to
% screen
% - x,y: the outputs of meshgrid, with pixel coordinates for the whole
% screen, normalized to either the horizontal or vertical edge, depending
% on whether we want the texture to go as far as possible and which
% dimiension is larger 


function [ts, x, y] = makeRetinotopyCarrier(c)

dim = round(c.display.resolution);

%AW 10.21.15: In the grid of x,y positions, the value 1 is set to the
%edge of the screen on either the horizontal or vertical dimension.
%Which one depends on whether we want the stimuli to go as far out as
%possible, or be constrained by the smallest dimension.
if c.carrier.fitInScreen
    prop = max(dim)/min(dim);
else
    prop = min(dim)/max(dim);
end

if (c.carrier.fitInScreen && dim(1)>dim(2)) || (~c.carrier.fitInScreen && dim(1)<=dim(2))
    gridX = linspace(-prop,prop,dim(1));
    gridY = linspace(-1,1,dim(2));
else
    gridX = linspace(-1,1,dim(1));
    gridY = linspace(-prop,prop,dim(2));
end

[x,y] = meshgrid(gridX,gridY);
ang = atan2(y,x);
rad = sqrt(x.^2+y.^2).^.5; %the square root expands rings at greater eccentricity
img = sign( sin(c.carrier.nWedges/2*ang).*sin(pi*c.carrier.nRings*rad) );

ts = [1 1];
for j = 1:2 % two polarities
    c.carrier.img = ((-1)^j*img*c.carrier.contrast+1)*0.5; % scales between 0 and 1 + inverts polarity if phase<0
    ts(j) = Screen('MakeTexture', c.display.windowPtr, c.carrier.img*255);
end