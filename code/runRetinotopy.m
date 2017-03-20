%% Run retinotopy scans
% Alex Wite 
% October 2015
%
% Total scan duration: 256s (128 TRs)
% 
% This script runs one scan of the basic Retinotopy experiment, with one
% checkerboard stimulus type: Rings (periodically contracting), Wedges (rotating clockwise) and
% Meridians (alternating horizontal and vertical bow-tie). 
% 
% The subject's task: press any button whenenver the
% fixation mark dims or the checkerboard dims (briefly lowers contrast). 
% 
% Each run saves a data variable "stim" in a mat file in
% data/subj/subjDate/. 
% 
% This code is capable of interacting with an Eyelink eye-tracker and
% saving an edf file for each run. 
% 
% Important parameters about the stimuli are in retinotopyParams. 
% 
% In addition, there are several parameters in this script that should be edited for
% each scan: 
% - subj: subject initials
% - scanNum:  scan number, which pulls out a value from vector scanOrder to determine stimulus type
% - MRI: whether this is actually an MRI scan or test oustide scanner. That
%   determines displayName - which display we think we're using. 
% - displayName: the name of the display, which should have a corresponding
%   file display_<name>.mat in code/displayInfo. That file should have info
%   about screen size, width, calibration file etc. 
% - EYE: whether to do eyetracking. %-1 = no; 0 = eyelink dummy mode (cursor as eye);  1 = full eyelink mode
% - fixtnDimProp: magnitude of fixation dimming, as proportion of luminance
% - checkerContrastDimProp: magnitude of checkerboard luminance contrast dimming, as proportion (0=no dimming, 1=total dimming to gray). 


%% parameters specific to this session: 
subj = 'XX';

%Increment this number for each scan: 
scanNum = 1;

%vector of scan types to run in this session:
scanOrder = [1 2 3 1 2 3]; 
scanTypes = {'Rings','Wedges','Meridians'};
nScans = length(scanOrder);

%% MRI parameters

MRI = false; %whether we're running in the magnet (determines calibration file)

TR  = 2;     %s

waitDummyScans = false; %whether to wait a few volumes before starting stimulus (for scanner warm-up)

%% monitor information 
if MRI
    displayName = 'scannerHSB';
else
    displayName = 'default';
end

displayFile = sprintf('display_%s.mat',displayName);

%% Should we do eye-tracking?
%-1 = no checking fixation; 0 = eyelink dummy mode (cursor as eye);  1 = full eyelink mode
EYE = -1;  

%% Task difficulty 
fixtnDimProp = 0.3; %luminance of cross reduced by this proportion 
checkerContrastDimProp = .5; %contrast of checkerboard reduced by this proportion


%% set directories and path
xFolder = retinotopyBase;
cFolder = fullfile(xFolder,'code');
dFolder = fullfile(xFolder,'data');

addpath(genpath(cFolder));
cd(cFolder);


%% Load parameters 

load(displayFile); 
displayParams.file = displayFile;
displayParams.TR = TR;
displayParams.waitDummyScans = waitDummyScans;
displayParams.open = false;

c = retinotopyParams(displayParams); 

c.EYE = EYE;
c.MRI = MRI;

c.totalScans       = nScans;
c.subj             = subj;
c.sessionScanOrder = scanOrder;
  

%% set task difficulty
c.task.fixtnDimProp = fixtnDimProp; %luminance of cross reduced by this proportion 
c.task.checkerContrastDimProp = checkerContrastDimProp; %contrast of checkerboard reduced by this proportion

c.fixpt.colors(2,:) = round(c.fixpt.baseColor*(1-c.task.fixtnDimProp));
c.carrier.contrast    = [c.carrier.baseContrast c.carrier.baseContrast*(1-c.task.checkerContrastDimProp)];

%% loop through scans (or don't loop, just run scan number scanNum)

for si = scanNum
   c.scanNum = si;
   c.type             = scanTypes{scanOrder(si)};
   
   %chose name for this scan's data file
   [datFile, edfFile] = setupRetinoDatFile(si,scanTypes{scanOrder(si)},subj,dFolder);
    
   c.edfFileName = edfFile;
   c.datFileName = datFile;
   
   switch scanOrder(si)
       case 1
           stim = Rings(c);
       case 2
           stim = Wedge(c);
       case 3
           stim = Meridians(c);
   end
   
   %carry over displayParams parameters, to allow screen to stay open
   c.display = stim.display; 
   
   fprintf(1,'\nscan %i duration = %.3f\n',si, stim.recorded.stimDurtn);
   for tt = c.task.whichStim
       fprintf(1,'\nFor %s stimulus, hit rate = %.3f\n',stim.task.stimuli{tt}, stim.recorded.hitRate(tt));
   end
   fprintf(1,'\nWrong stim rate = %.3f\n', stim.recorded.wrongStimRate);
   fprintf(1,'\nNumber false alarms = %i\n',stim.recorded.nFalseAlarms);
   
   %save data mat file
   save(sprintf('%s.mat',datFile),'stim');
end

%close screen
if stim.display.open
    sca;
end

