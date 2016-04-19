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
% 
% April 19: now you don't have to discriminate location (checkerboard vs
% fixation) of dimming, just press any key when you detect any dimming. 
% 
% To do: 
% - make subfunctions for routines used in all three stimuli (collecting
% response, computing accuracy, determining "chunks" 
% - move other parameters of "masks" for each stimulus into the Params
% function 



home; clear all;  

%% parameters specific to this session: 

subj = 'ZZ';

%Increment this number for each scan: 
scanNum = 6;

%vector of scan types to run in this session:
scanOrder = [1 2 3 1 2 3]; 
scanTypes = {'Rings','Wedges','Meridians'};


doMR           = false; %whether we're running in the magnet (determines calibration file)
TR             = 2;     %s

waitDummyScans = false; %whether to wait a few volumes before starting stimulus (for scanner warm-up)
nScans = length(scanOrder);

%% Task difficulty 
% % % task difficulty
fixtnDimProp = 0.3; %luminance of cross reduced by this proportion 
checkerContrastDimProp = 0.55; %contrast of checkerboard reduced by this proportion

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

%% Load parameters 

c = RetinotopyWithTaskParams(display); 

c.time.totalScans = nScans;

%% set task difficulty
c.task.fixtnDimProp = fixtnDimProp; %luminance of cross reduced by this proportion 
c.task.checkerContrastDimProp = checkerContrastDimProp; %contrast of checkerboard reduced by this proportion

c.fixpt.crossColor = [c.fixpt.baseCrossColor; ...
                    round(c.fixpt.baseCrossColor*(1-c.task.fixtnDimProp))];

c.carrier.contrast    = [c.carrier.baseContrast c.carrier.baseContrast*(1-c.task.checkerContrastDimProp)];

%% loop through scans (or don't loop, just run scan number scanNum)

for si = scanNum
   c.time.scanNum = si; 
   
   switch scanOrder(si)
       case 1
           stim = Rings(c);
       case 2
           stim = Wedge(c);
       case 3
           stim = Meridians(c);
   end
   
   %carry over display parameters, to allow screen to stay open
   c.display = stim.display; 
   
   %save stimulus info for this scan:
   stim.subj             = subj;
   stim.scanNum          = si;
   stim.sessionScanOrder = scanOrder;
   stim.type             = scanTypes{scanOrder(si)};
   stim.doMR             = doMR;
   
   fprintf(1,'\nscan %i duration = %.3f\n',si, stim.recorded.stimDurtn);
   for tt = c.task.whichStim
       fprintf(1,'\nFor %s stimulus, hit rate = %.3f\n',c.task.stimuli{tt}, stim.recorded.hitRate(tt));
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

