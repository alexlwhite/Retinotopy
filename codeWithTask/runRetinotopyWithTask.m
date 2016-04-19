%% Run retinotopy scans
% Alex Wite 
% October 2015
%
% Total scan duration: 256s (128 TRs)

%Feb 5 2016: edited so that Wedge starts vertically (startAngle = -90)
% 
%April 18 2016: added task! detecting contrast decrements in fixation cross
%and in checkerboard 
% Keys: blue for fixation; red for checkerboard

home; clear all;  

%% parameters specific to this session: 

subj = 'ZZ';


%Increment this number for each scan: 
scanNum = 3;

%vector of scan types to run in this session:
scanOrder = [1 2 3 1 2 3]; 
scanTypes = {'Rings','Wedges','Meridians'};


doMR           = false; %whether we're running in the magnet (determines calibration file)
TR             = 2;     %s

waitDummyScans = false; %whether to wait a few volumes before starting stimulus (for scanner warm-up)
nScans = length(scanOrder);


%% set directories
xFolder = '/Users/alexwhite/Dropbox/PROJECTS/Retinotopy';
cFolder = fullfile(xFolder,'codeWithTask');
dFolder = fullfile(xFolder,'data');

addpath(genpath(cFolder));
cd(cFolder);

%% monitor information 
if doMR
    load('display_scanner.mat');
else
    %load('display_home.mat');
    load('display_office74.mat');
end

display.TR = TR;
display.waitDummyScans = waitDummyScans;
display.open = false;

%Background color 
display.bkColor = floor(255*[1 1 1]*0.5); 


%% Timing parameters
time.CycleDur   = 32;  % temporal period (s)
time.NCycles    = 8;   % nreps

time.DummyDur   = 4*TR*waitDummyScans; % (s)

time.totaldur   = time.DummyDur + time.CycleDur*time.NCycles;
time.totalScans = nScans;

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

% % % task difficulty
task.fixtnDimProp = 0.3; %luminance of cross reduced by this proportion 
task.checkerContrastDimProp = 0.55; %contrast of checkerboard reduced by this proportion


%% fixation mark
fixpt.type = 2; %0 (default) squares, 1 circles (with anti-aliasing), 2 circles (with high-quality anti-aliasing, if supported by your hardware). If you use dot_type = 1 you'll also need to set a proper blending mode with the Screen('BlendFunction') command!
fixpt.sizeDeg = 0.3; 
fixpt.backColor = [0 0 200; 150 150 0; 255 0 0; 0 255 0]; %1=base; 2=miss; 3=error; 4=hit 
fixpt.baseCrossColor  = [200 200 200];
fixpt.crossColor = [fixpt.baseCrossColor; ...
                    round(fixpt.baseCrossColor*(1-task.fixtnDimProp))];

fixpt.crossThick = 3; 

%% parameters of carrier texture 
carrier.nWedges     = 32;   % how many wedges in 360
carrier.nRings      = 18;   % how many rings in screen
carrier.flickerHz   = 8;    % Hz
carrier.baseContrast = 0.90;
carrier.contrast    = [carrier.baseContrast carrier.baseContrast*(1-task.checkerContrastDimProp)];

%whether stimulus should be constrained to stop at 
%nearest edge of screen. If not, it extends to the edge of the screen along
%the longest dimension. 
carrier.fitInScreen = false; 
%% loop through scans (or don't loop, just run scan number scanNum)

for si = scanNum
   time.scanNum = si; 
   
   switch scanOrder(si)
       case 1
           stim = Rings(display, carrier, fixpt, time, task);
       case 2
           stim = Wedge(display, carrier, fixpt, time, task);
       case 3
           stim = Meridians(display, carrier, fixpt, time, task);
   end
   
   %carry over display parameters, to allow screen to stay open
   display = stim.display; 
   
   %save stimulus info for this scan:
   stim.subj             = subj;
   stim.scanNum          = si;
   stim.sessionScanOrder = scanOrder;
   stim.type             = scanTypes{scanOrder(si)};
   stim.doMR             = doMR;
   
   fprintf(1,'\nscan %i duration = %.3f\n',si, stim.recorded.stimDurtn);
   for tt = task.whichStim
       fprintf(1,'\nFor %s stimulus, hit rate = %.3f\n',task.stimuli{tt}, stim.recorded.hitRate(tt));
   end
   fprintf(1,'\nWrong stim rate = %.3f\n', stim.recorded.wrongStimRate);
   fprintf(1,'\nNumber false alarms = %i\n',stim.recorded.nFalseAlarms);

   
   %chose name for this scan's data file
   datFile = setupRetinoDatFile(si,scanTypes{scanOrder(si)},subj,dFolder);
   
   %save data mat file
   save(sprintf('%s.mat',datFile),'stim');
end

%close screen
if stim.display.open
    sca;
end

