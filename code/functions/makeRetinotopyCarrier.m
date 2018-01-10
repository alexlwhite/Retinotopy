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

%dim: a 1x2 vector of the screen resolution in pixels, e.g., [1280 1024]
dim = round(c.display.resolution);

%AW 10.21.15: In the grid of x,y positions, the value 1 is set to the
%edge of the screen on either the horizontal or vertical dimension.
%Which one depends on whether we want the stimuli to go as far out as
%possible (fitInScreen = false), or be constrained by the smallest
%dimension (fitInScreen = true). 
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

%%  for initial setup at SLU (BMIC) 
% necessary to make all of stimulus visible. Only the top portion of the
% screen was visible on 1/26/17. So the solution is to shrink the stimulus
% down (by increasing prop from 1.33) and prop up the projector. 
% if strcmp(c.display.file,'display_scannerSLU_BigScreen.mat')
%     prop = 1.5; %was 1.6 on January 26, 2017 for AW
%     
%     gridX = linspace(-prop,prop,dim(1))*1024/768;
%     gridY = linspace(-prop,prop,dim(2));
% end

%% Make grid
[x,y] = meshgrid(gridX,gridY);
ang = atan2(y,x);
rad = sqrt(x.^2+y.^2).^.5; %the square root expands rings at greater eccentricity
img = sign( sin(c.carrier.nWedges/2*ang).*sin(pi*c.carrier.nRings*rad) );

ts = ones(length(c.carrier.contrast),2); %[1 1];
for i = 1:length(c.carrier.contrast) %number of contrast levels
    for j = 1:2 % two polarities
        c.carrier.img = ((-1)^j*img*c.carrier.contrast(i)+1)*0.5; % scales between 0 and 1 + inverts polarity if phase<0
        ts(i,j) = Screen('MakeTexture', c.display.windowPtr, c.carrier.img*255);
    end
end