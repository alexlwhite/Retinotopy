%% function c = RetinotopyWithTaskParams()
% Returns a structure c with fields specifying stimulus and task parameters
% for Retinotopy experiment 
% Subfields of c 
% - time: itself a structure with timing information 
% - task: itself a structure wihth 
function c = RetinotopyWithTaskParams(display)

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
fixpt.type = 2; %0 (default) squares, 1 circles (with anti-aliasing), 2 circles (with high-quality anti-aliasing, if supported by your hardware). If you use dot_type = 1 you'll also need to set a proper blending mode with the Screen('BlendFunction') command!
fixpt.sizeDeg = 0.3; 
fixpt.backColor = [0 0 200; 150 150 0; 255 0 0; 0 255 0]; %1=base; 2=miss; 3=error; 4=hit 
fixpt.baseCrossColor  = [200 200 200];

fixpt.crossThick = 3; 

%% parameters of carrier texture 
carrier.nWedges     = 32;   % how many wedges in 360
carrier.nRings      = 18;   % how many rings in screen
carrier.flickerHz   = 8;    % Hz
carrier.baseContrast = 0.90;

%whether stimulus should be constrained to stop at 
%nearest edge of screen. If not, it extends to the edge of the screen along
%the longest dimension. 
carrier.fitInScreen = false; 


%% aggregate all sub-structures: 
c.display   = display; 
c.carrier   = carrier;
c.time      = time;
c.fixpt     = fixpt; 
c.task      = task;