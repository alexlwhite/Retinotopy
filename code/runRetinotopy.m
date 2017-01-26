%% Run retinotopy scans
% Alex Wite 
% October 2015
%
% Total scan duration: 256s (128 TRs)

%Feb 5 2016: edited so that Wedge starts vertically (startAngle = -90)
% 
% April 18 2016: added task! detecting contrast decrements in fixation cross
% and in checkerboard 
% 
% April 19: now you don't have to discriminate location (checkerboard vs
% fixation) of dimming, just press any key when you detect any dimming. 
% 
% April 22-26 2016: added eyetracking  

home; clear all;  

%% parameters specific to this session: 
subj = 'ZX';

%Increment this number for each scan: 
scanNum = 3;

%vector of scan types to run in this session:
scanOrder = [1 2 3 1 2 3 2]; 
scanTypes = {'Rings','Wedges','Meridians'};


MRI            = true; %whether we're running in the magnet (determines calibration file)
TR             = 2;     %s
waitDummyScans = false; %whether to wait a few volumes before starting stimulus (for scanner warm-up)

nScans = length(scanOrder);

%% Should we do eye-tracking?
%-1 = no checking fixation; 0 = eyelink dummy mode (cursor as eye);  1 = full eyelink mode
EYE = -1;  

%% Task difficulty 
fixtnDimProp = 0.35; %luminance of cross reduced by this proportion 
checkerContrastDimProp = 0.5; %contrast of checkerboard reduced by this proportion


%% set directories
xFolder = '/Users/alexwhite/Dropbox/PROJECTS/Retinotopy';
cFolder = fullfile(xFolder,'code');
dFolder = fullfile(xFolder,'data');

addpath(genpath(cFolder));
cd(cFolder);

%% monitor information 
if MRI
    displayFile = 'display_scannerSLU_BigScreen.mat';
    %displayFile = 'display_scannerHSB.mat';

else
    displayFile = 'display_office74.mat';
    %displayFile = 'display_macbook.mat';
end

load(displayFile); 
displayParams.file = displayFile;
displayParams.TR = TR;
displayParams.waitDummyScans = waitDummyScans;
displayParams.open = false;


%% Load parameters 

c = retinotopyParams(displayParams); 

%%%%%%% KLUGEEEEE!!!!!! 
%if using crappy projector at BMIC, shrink carrier a bit to fit in the
%screen
if strcmp(displayFile,'display_scannerSLU_BigScreen.mat')
    c.carrier.fitInScreen = true; 
end
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

