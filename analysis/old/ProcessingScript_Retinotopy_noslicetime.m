%% Information to be updated for this scan
subjDate = '\AW\AWOct27';

AnatomicalFile = 'BVIS_999_WIP_MPRAGE_nobodytune_SENSE_2_1';
FunctionalFiles = {'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_5_1',...
                          'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_6_1',...
                          'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_7_1',...
                          'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_8_1',...
                          'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_9_1',...
                          'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_10_1'};

numSets = numel(FunctionalFiles); % size(FunctionalFiles,1);
 
% number of TRs per scan: 
TRs =120*ones(numSets,1); 

StimFiles = {'AW_151027_01_Rings.mat', ...
             'AW_151027_02_Wedges.mat',...
             'AW_151027_03_Meridians.mat',...
             'AW_151027_04_Rings.mat', ...
             'AW_151027_05_Wedges.mat',...
             'AW_151027_06_Meridians.mat'};

 if numSets ~= numel(StimFiles)
     fprintf(1,'\n\nWARNING: not the same number of stim files as MR sets\n');
     keyboard
 end
 
oppPE = '';  
doDistCorr = ~isempty(oppPE);


%% Dimensions of each functional scan
slices = 30;
xdim = 80;
ydim = 80;

%and the dimensions of the anatomical scan
anatSlices = 176;
anatXDim = 256;
anatYDim = 256;

%% Paths
prjPath = 'C:\Users\Alex White\Dropbox\PROJECTS\Retinotopy';
datPath = [prjPath '\data'];
anaPath = [prjPath '\analysis'];

MRPath = [datPath subjDate '\MRI'];
stimPath = [datPath subjDate '\stimulus'];
anatPath = fullfile(MRPath,'anat');
if ~isdir(anatPath), mkdir(anatPath); end
prtPath = [MRPath '\prts'];
if ~isdir(prtPath), mkdir(prtPath), end;
resPath = fullfile(MRPath,'RESULTS');
if ~isdir(resPath), mkdir(fullfile(MRPath,'RESULTS')); end

cd(datPath);
addpath(genpath(anaPath)); 
 
 %% Make PRTs from stimulus files
 PRTs = cell(1,numSets);
 for fi  = 1:numSets
     fn = fullfile(stimPath,StimFiles{fi});
     load(fn);
     if exist('stim','var')
         switch stim.type
             case 'Rings'
                 if strcmp(subjDate,'\AW\AWOct27')
                     stim.time.nConds = 15; %KLUGE! There were actually 18 conds but that doesn't fit, so set to 15
                 end
                 PRTs{fi} = sprintf('%s/%s_%i_Rings.prt',prtPath,stim.subj,stim.scanNum);
                 makeRingsPRT(stim,PRTs{fi});
                 
             case 'Wedges'
                 PRTs{fi} = sprintf('%s/%s_%i_Wedges.prt',prtPath,stim.subj,stim.scanNum);
                 makeWedgePRT(stim,PRTs{fi});
                 
             case 'Meridians'
                 PRTs{fi} = sprintf('%s/%s_%i_Merids.prt',prtPath,stim.subj,stim.scanNum);
                 makeMeridPRT(stim,PRTs{fi});
         end
     end
 end
%% Make directories and move files
%check if moved happened already
fmrFolders = cell(1,numSets);
for i = 1:numSets
    fmrFolders{i} = fullfile(MRPath,sprintf('s%i',i));
end
moved = isdir(fmrFolders{numSets});
if moved
    x=dir(fmrFolders{numSets});
    moved = size(x,1)>3;
end
if ~moved
    for i = 1:numSets
        if ~isdir(fmrFolders{i}), mkdir(fmrFolders{i}); end;
        movefile(fullfile(MRPath,[FunctionalFiles{i} '.PAR']), fullfile(fmrFolders{i}, [FunctionalFiles{i} '.PAR']));
        movefile(fullfile(MRPath,[FunctionalFiles{i} '.REC']), fullfile(fmrFolders{i}, [FunctionalFiles{i} '.REC']));
    end
end


moved = ~exist(fullfile(MRPath, [AnatomicalFile '.PAR']),'file');
if ~moved
    movefile(fullfile(MRPath, [AnatomicalFile '.PAR']), fullfile(anatPath, [AnatomicalFile '.PAR']))
    movefile(fullfile(MRPath, [AnatomicalFile '.REC']), fullfile(anatPath, [AnatomicalFile '.REC']))
end

if doDistCorr
    oppPath = fullfile(MRPath,'oppPE');
    if ~isdir(oppPath), mkdir(oppPath); end
    moved = ~exist(fullfile(MRPath, [oppPE '.PAR']),'file');
    if ~moved
        movefile(fullfile(MRPath, [oppPE '.PAR']), fullfile(oppPath, [oppPE '.PAR']))
        movefile(fullfile(MRPath, [oppPE '.REC']), fullfile(oppPath, [oppPE '.REC']))
    end
end



%% Start BrainVoyager
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

%% Make fmr files
nVolsToSkip = 0;
createAMR = false;
swapBytes = false;
bytesPerPix = 2;
fmrNames = cell(1,numSets);
for i = 1:numSets
    stcPrefix = sprintf('s%i',i);
    fmrNames{i} = sprintf('s%i.fmr',i);
    rawFile = fullfile(fmrFolders{i}, [FunctionalFiles{i} '.REC']);
    if ~exist(fullfile(fmrFolders{i},fmrNames{i}),'file')
        fmr = bvqx.CreateProjectFMR('PHILIPS_REC',rawFile, TRs(i), nVolsToSkip, createAMR, slices, stcPrefix, swapBytes, xdim, ydim, bytesPerPix, fmrFolders{i});
        fmr.LinkStimulationProtocol(PRTs{i});
        fmr.SaveAs(fmrNames{i});
        fmr.Close;
    end
end

%% Motion Correction 
targetFMR = fullfile(fmrFolders{1},fmrNames{1});
targetVol = 1; 
interpMethod = 2; %trilinear detection and sinc interpolation 
useFullDataSet = 0; %if not, reduced data set (default in GUI)
maxIterations = 100; 
makeMovies = 0;
makeLogFile = 1;

motnFMRs = cell(1,numSets);
for i = 1:numSets
    motnFMRs{i} = fullfile(fmrFolders{i},[fmrNames{i}(1:(end-4)) '_3DMCTS.fmr']);
    if ~exist(motnFMRs{i},'file') %only do motion correction if it's not done already! 
        docFMR = bvqx.OpenDocument(fullfile(fmrFolders{i},fmrNames{i})); 
        docFMR.CorrectMotionTargetVolumeInOtherRunEx(targetFMR,targetVol,interpMethod,useFullDataSet,maxIterations,makeMovies,makeLogFile);
        docFMR.Close;
    end
end

%% Dist. Comp.
if doDistCorr
    oppFile = fullfile(oppPath,[oppPE '.REC']);
    nTRs = 1;
    stcPrefix = 'oppPE';
    fmr = bvqx.CreateProjectFMR('PHILIPS_REC',oppFile, nTRs, nVolsToSkip, createAMR, slices, stcPrefix, swapBytes, xdim, ydim, bytesPerPix, oppPath);
    fmr.SaveAs(['oppPE.fmr']);
    fmr.Close;
    
    disp('Run distortion compensation in COPE plugin');
    % To do this:
    % 	- Plugins Menu --> COPE (v0.5) --> Go to the Estimate VDM Tab (opens by default)
    % 	- Phase-encoding directions = A>>P and P>>A
    % 	- Estimate from : set1_3DMCTS.fmr (pick this for the first row,
    % 	because it's A>>P), Volume = 1, and the oppPE.fmr
    % 	- Type of data = GE
    % 	- Click run at the bottom
    % 	- Go to the Apply VDM tab
    % 	- Phase-encoding directions = A>>P and P>>A
    % 	- VDM --> browse for the VDM file you just created, likely in set1 folder, set1_3DMCTS_vdm.map
    % 	- At the bottom left, click Add --> select each of the motion corrected .fmr files from each folder (set1, set2, etc.; e.g., set1_3DMCTS.fmr)
    %   - At the bottom right, click Run
    disp('Any key to continue.')
    pause
    
    %store names
    undistFMRs = cell(1,numSets);
    for i=1:numSets
        undistFMRs{i} = [motnFMRs{i}(1:(end-4)) '_undist.fmr'];
    end
end
%% Temporal Filter
highPassCycles = 2; %numver of cycles (pairs of two basis functions used to build appropriate design matrix
processedFMRs = cell(1,numSets);
for i = 1:numSets
    if doDistCorr
        fmrName = undistFMRs{i};
    else
        fmrName = motnFMRs{i};
    end

    docFMR = bvqx.OpenDocument(fmrName);
    docFMR.TemporalHighPassFilterGLMFourier(highPassCycles);
    docFMR.Close;
    if doDistCorr
        processedFMRs{i} = fullfile(fmrFolders{i},sprintf('s%i_3DMCTS_undist_LTR_THPGLMF2c.fmr',i));
    else
        processedFMRs{i} = fullfile(fmrFolders{i},sprintf('s%i_3DMCTS_LTR_THPGLMF2c.fmr',i));
    end
end

%% Delete unnecessary files
for i = 1:numSets
    % eval(['cd ' path 'set' int2str(i)])
    %delete original .fmr and .stc file

    fn = fullfile(fmrFolders{i},fmrNames{i});
    delete(fn);
    delete([fn(1:(end-4)) '.stc']);

    %delete motion corrected .fmr and .stc file
    delete(motnFMRs{i});
    delete([motnFMRs{i}(1:(end-4)) '.stc']);
    
    %delete undistorted .fmr and .stc file
    if doDistCorr
        delete(undistFMRs{i});
        delete([undistFMRs{i}(1:(end-4)) '.stc']);
    end
end
cd(MRPath);

%% Make Anatomicals
anatFile = fullfile(anatPath,[AnatomicalFile '.REC']);

anatNBytes = 2;
isLittleEndian = false;

docVMR = bvqx.CreateProjectVMR('PHILIPS_REC',anatFile,anatSlices,isLittleEndian,anatXDim,anatYDim,anatNBytes);

docVMR.SaveAs(fullfile(anatPath,'anat.vmr')); %[path '3danat\3d_anat']);
docVMR.CorrectIntensityInhomogeneities();
docVMR.AutoTransformToSAG('anat_SAG_IIHC.vmr');
docVMR.Close;
delete(fullfile(anatPath,'anat_IIHC*'));
%eval (['!del ' anatPath '\anat_IIHC*'])
docVMR = bvqx.OpenDocument(fullfile(anatPath, 'anat_SAG_IIHC.vmr'));
disp('Examine brightness values. Any key to continue.')
pause

docVMR.AutoACPCAndTALTransformation();
disp('Coregister functionals and anatomicals. Put .trfs in anat directory.')
disp('Any key to continue.')
pause

%% Make VTC's 

vtcSpace = 'TAL'; %'ACPC';

VMR = fullfile(anatPath,'anat_SAG_IIHC.vmr');

if doDistCorr
    IA = 's1_3DMCTS_undist_LTR_THPGLMF2c-TO-anat_SAG_IIHC_IA.trf';
    FA = 's1_3DMCTS_undist_LTR_THPGLMF2c-TO-anat_SAG_IIHC_FA.trf';
else
    IA = 's1_3DMCTS_LTR_THPGLMF2c-TO-anat_SAG_IIHC_IA.trf';
    FA = 's1_3DMCTS_LTR_THPGLMF2c-TO-anat_SAG_IIHC_FA.trf';
end

%these automatically are put in set1 folder
IA = fullfile(fmrFolders{1},IA);
FA = fullfile(fmrFolders{1},FA);

TAL = 'anat_SAG_IIHC_aACPC.tal';
ACPC = 'anat_SAG_IIHC_aACPC.trf';

vtcDataType = 2; %1=integer 2-byte; 2=float
vtcResolution = 3; %WHY?
vtcInterp = 1; %0=nearest neighbor; 1=tilinear; 2=sinc
boundBoxThreshold = 100; 

useBoundingBox = true;

for i = 1:numSets
    docVMR = bvqx.OpenDocument(VMR);
    docVMR.ExtendedTALSpaceForVTCCreation = 0;
    if strcmp(vtcSpace,'ACPC')
        if useBoundingBox
            vtcName = sprintf('s%i_bbox.vtc',i);
            docVMR.UseBoundingBoxForVTCCreation = 1;
        else
            vtcName = sprintf('s%i.vtc',i);
            docVMR.UseBoundingBoxForVTCCreation = 0;
        end
        docVMR.CreateVTCInACPCSpace(processedFMRs{i},IA,FA,ACPC,vtcName,vtcDataType,vtcResolution,vtcInterp,boundBoxThreshold);
    else
        docVMR.UseBoundingBoxForVTCCreation = 0;
        vtcName = sprintf('s%i_TAL.vtc',i);
        docVMR.CreateVTCInTALSpace(processedFMRs{i},IA,FA,ACPC,TAL,vtcName,vtcDataType,vtcResolution,vtcInterp,boundBoxThreshold);
    end
    docVMR.Close;
end