%% Run retinotopy scans
% Alex Wite 
% October 2015

%Feb 5 2016: edited so that Wedge starts vertically (startAngle = -90)
home; clear all;  

%% parameters specific to this session: 

%Increment this number for each scan: 
scanNum = 2;

subj = 'XX';

doMR           = false; %whether we're running in the magnet (determines calibration file)
TR             = 2;     %s
waitDummyScans = false; %whether to wait a few volumes before starting stimulus (for scanner warm-up)

%vector of scan types to run in this session:
scanOrder = [1 2 3 1 2 3]; 
scanTypes = {'Rings','Wedges','Meridians'};

nScans = length(scanOrder);


%% set directories
xFolder = '/Users/alexwhite/Dropbox/PROJECTS/Retinotopy';
cFolder = fullfile(xFolder,'code');
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

%% parameters of carrier texture 
carrier.nWedges     = 32;   % how many wedges in 360
carrier.nRings      = 18;   % how many rings in screen
carrier.flickerHz   = 8;    % Hz
carrier.contrast    = 0.90;
%whether stimulus should be constrained to stop at 
%nearest edge of screen. If not, it extends to the edge of the screen along
%the longest dimension. 
carrier.fitInScreen = false; 
%% loop through scans (or don't loop, just run scan number scanNum)

for si = scanNum
   time.scanNum = si; 
   
   switch scanOrder(si)
       case 1
           stim = Rings(display, carrier, time);
       case 2
           stim = Wedge(display, carrier, time);
       case 3
           stim = Meridians(display, carrier, time);
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
   
   %chose name for this scan's data file
   datFile = setupRetinoDatFile(si,scanTypes{scanOrder(si)},subj,dFolder);
   
   %save data mat file
   save(sprintf('%s.mat',datFile),'stim');
end

%close screen
if stim.display.open
    sca;
end

