%% function c = retinotopyParams()
% Returns a structure c with fields specifying stimulus and task parameters
% for Retinotopy experiment 
% Subfields of c 
% - time: itself a structure with timing information 
% - task: itself a structure wihth 
function c = retinotopyParams(display)

%% Timing parameters
time.CycleDur   = 32;  % temporal period (s)
time.NCycles    = 8;   % nreps

time.DummyDur   = 4*display.TR*display.waitDummyScans; % (s)

time.totaldur   = time.DummyDur + time.CycleDur*time.NCycles;

%% Task parameters 
% contrast decrements in either the fixation mark or the checkerboard stimulus
% Task is just to press button when detected 

task.discriminate = false; %whether you have to make separate responses for event in fixation mark vs. checkerboard

task.minISI = 2; 
task.maxISI = 12; 
task.expMean = 5; 
task.targDur = 0.250;

if task.discriminate
    task.buttonNames = {'b','r'};
    task.maxRespDur = 1.5; 
else
    task.buttonNames = {'b','y','g','r'};
    task.maxRespDur = 1.0; 
end

task.stimuli = {'fixation','checkerboard'};
task.whichStim = 1:2; %which stimuli can have decrements: 1=fixation; 2=checkerboard 



%% fixation mark

%New fixation point, January 12 2017: dot with a ring around it. The inner
%dot is what dims, the ring gives feedback
fixpt.dotType          = 2; % 0 (default) squares, 1 circles (with anti-aliasing), 2 circles (with high-quality anti-aliasing, if supported by your hardware). If you use dot_type = 1 you'll also need to set a proper blending mode with the Screen('BlendFunction') command!
fixpt.diameter         = 0.2;
fixpt.ringDiameter     = 0.35;
fixpt.ringThick        = 2; %pixels

%innner fixation  colors: 2 rows: 1=base; 2=decrement;
fixpt.baseColor  = [255 255 255];
fixpt.colors = [fixpt.baseColor; 200 200 200];
%ring colors for feedback: 1=base; 2=miss, 4=false alarm; 3=hit; 
fixpt.ringColors = [fixpt.baseColor; 255 90 90; 225 225 0; 100 255 100];


%% parameters of carrier texture 
carrier.nWedges     = 32;   % how many wedges in 360
carrier.nRings      = 18;   % how many rings in screen
carrier.flickerHz   = 8;    % Hz
carrier.baseContrast = 0.90;

%whether stimulus should be constrained to stop at 
%nearest edge of screen. If not, it extends to the edge of the screen along
%the longest dimension. 
carrier.fitInScreen = false; 


%% parameters for masks (which determine shape of checkerboard segments for each stimulus type) 

% % % Rings: 
ringsMask.expand       = 0; %ring expands or contracts
ringsMask.thickNRings  = 3; %thickness of carrier in number of rings

% % % Wedge: 
wedgeMask.widthAngleDeg    = 360/8; %if discrete angles, best if this angle is a whole-number fraction of 360
wedgeMask.widthAngle       = wedgeMask.widthAngleDeg*pi/180;
wedgeMask.clockwise        = 1;
wedgeMask.discreteAngles   = 0; % if 0 continuous rotation (360 deg in one cycle)
wedgeMask.startAngle       = -90; %start vertically 
if wedgeMask.discreteAngles
    wedgeMask.Angles = 0:wedgeMask.widthAngleDeg:(360-wedgeMask.widthAngleDeg);
else
    wedgeMask.Angles = NaN;
end

% % % Meridians
meridsMask.widthAngleDeg    = 360/8; %if discrete angles, best if this angle is a whole-number fraction of 360
meridsMask.angwidth = meridsMask.widthAngleDeg*pi/180; %width of wedge in radians
meridsMask.clockwise = 1;
meridsMask.Angles = [0 90]; % tested orientations

if ~meridsMask.clockwise
    meridsMask.Angles = meridsMask.Angles(end:-1:1);
end

%% eyetracking 
c.startRecordingTime = 0.050;
%calibration area
c.squareCalib = false;
c.calibShrink = 0.8; 

%% display
%Background color 
display.bkColor = floor(255*[1 1 1]*0.5); 
display.fgColor = [255 255 255]; %white 
%% aggregate all sub-structures: 
c.display    = display; 
c.carrier    = carrier;
c.ringsMask  = ringsMask;
c.wedgeMask  = wedgeMask;
c.meridsMask = meridsMask;
c.time       = time;
c.fixpt      = fixpt; 
c.task      = task;