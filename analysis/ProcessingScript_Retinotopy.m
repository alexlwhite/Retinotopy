%% BrainVoyager pre-processing script
% Specialized for Retinotopy data
% by Alex White, 2016, based heavily on a script by Scott Murray (via
% Michael-Paul Schallmo

subj = 'WD';
subjDate = 'WDNov17';
[AnatomicalFile, FunctionalFiles, slices, TRsPerScan, oppPE, StimFiles] = getRetinotopyScanInfo(subjDate);
 
subjSubjDate = fullfile(subj,subjDate);

x=2;
%% Dimensions of each functional scan
xdim = 80;
ydim = 80;

%and the dimensions of the anatomical scan
anatSlices = 176;
anatXDim = 256;
anatYDim = 256;

%% fill in some info
numSets = numel(FunctionalFiles); % size(FunctionalFiles,1);
 
if numSets ~= numel(StimFiles)
     fprintf(1,'\n\nWARNING: not the same number of stim files as MR sets\n');
     keyboard
end

% number of TRs per scan (assume for now they're all the same) 
if length(TRsPerScan)==1
    TRs = TRsPerScan*ones(numSets,1); 
else
    TRs = TRsPerScan;
end

doDistCorr = ~isempty(oppPE);

%% Paths
prjPath = retinotopyBase;
datPath = fullfile(prjPath,'data');
anaPath = fullfile(prjPath,'analysis');

MRPath = fullfile(datPath,fullfile(subjSubjDate,'MRI'));  
stimPath = fullfile(datPath,fullfile(subjSubjDate,'stimulus'));  

anatPath = fullfile(MRPath,'anat');
if ~isdir(anatPath), mkdir(anatPath); end
prtPath = fullfile(MRPath,'prts');
if ~isdir(prtPath), mkdir(prtPath), end
resPath = fullfile(MRPath,'RESULTS');
if ~isdir(resPath), mkdir(fullfile(MRPath,'RESULTS')); end

cd(datPath);
addpath(genpath(anaPath)); 

%% Make PRTs from stimulus files
PRTs          = cell(1,numSets);
nVWFALoc     = zeros(1,numSets); 
nfLoc        = zeros(1,numSets);
nVWFALocScans = 0;
nfLocScans = 0;

for fi  = 1:numSets
    clear stim task scr 
    fn = fullfile(stimPath,StimFiles{fi});
    %detect fLoc PRT files
    if strcmp(fn((end-3):end),'.prt')
        PRTs{fi} = fn;
        %move this PRT to PRT folder 
        movefile(fn, fullfile(prtPath, StimFiles{fi}));

        nfLocScans = nfLocScans + 1;
        nfLoc(fi) = nfLocScans;
    else
        load(fn);
        if exist('stim','var')
            switch stim.type
                case 'Rings'
                    if strcmp(subjSubjDate,'\AW\AWOct27')
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

        elseif exist('task','var')
            if task.localizer && strcmp(task.codeFilename,'VWFA_Attn2_RunLocalizer.m')
                nVWFALocScans = nVWFALocScans+1;
                prtN = sprintf('%s_Loc%i.prt',subjDate,nVWFALocScans);
                PRTs{fi} = fullfile(prtPath,prtN);
                makePRT_VWFA_Attn2_Locr(task, PRTs{fi});
                nVWFALoc(fi) = nVWFALocScans;
            end
        end
    end
end
%% Make directories and move files
%check if moved happened already
fmrFolders = cell(1,numSets);
for i = 1:numSets
    if nVWFALoc(i)>0
        fmrFolders{i} = fullfile(MRPath,sprintf('s%i_VWFALoc%i',i,nVWFALoc(i)));
    elseif nfLoc(i)>0
        fmrFolders{i} = fullfile(MRPath,sprintf('s%i_fLoc%i',i,nfLoc(i)));
    else
        fmrFolders{i} = fullfile(MRPath,sprintf('s%i',i));
    end
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
    if nfLoc(i)>0
        stcPrefix = sprintf('s%i_fLoc%i',i,nfLoc(i));
        fmrNames{i} = sprintf('s%i_fLoc%i.fmr',i,nfLoc(i));
    elseif nVWFALoc(i)>0
        stcPrefix = sprintf('s%i_VWFALoc%i',i,nVWFALoc(i));
        fmrNames{i} = sprintf('s%i_VWFALoc%i.fmr',i,nVWFALoc(i));
    else
        stcPrefix = sprintf('s%i',i);
        fmrNames{i} = sprintf('s%i.fmr',i);
    end
    rawFile = fullfile(fmrFolders{i}, [FunctionalFiles{i} '.REC']);
    if ~exist(fullfile(fmrFolders{i},fmrNames{i}),'file')
        fmr = bvqx.CreateProjectFMR('PHILIPS_REC',rawFile, TRs(i), nVolsToSkip, createAMR, slices, stcPrefix, swapBytes, xdim, ydim, bytesPerPix, fmrFolders{i});
        fmr.LinkStimulationProtocol(PRTs{i});
        fmr.SaveAs(fmrNames{i});
        fmr.Close;
    end
end

%% Slice time correction
scanOrder = 1; %0=ascending, 1=ascending-interleaved, 2=Siemens ascending-interleaved, 10=descending, 11=descending-interleaved, 12=descending-interleaved Siemens
timeInterp = 0; %0=trilinear, 1=cubic spline, 2= SINC. 
sliceTimeFMRs = cell(1,numSets);
for i = 1:numSets
    docFMR = bvqx.OpenDocument(fullfile(fmrFolders{i},fmrNames{i}));
    docFMR.CorrectSliceTiming(scanOrder,timeInterp);
    sliceTimeFMRs{i} = docFMR.FileNameOfPreprocessdFMR;
    docFMR.Close;
end

%% Motion Correction 
targetFMR = sliceTimeFMRs{1}; %fullfile(fmrFolders{1},fmrNames{1});
targetVol = 1; 
interpMethod = 2; %trilinear detection and sinc interpolation 
useFullDataSet = 0; %if not, reduced data set (default in GUI)
maxIterations = 100; 
makeMovies = 0;
makeLogFile = 1;

motnFMRs = cell(1,numSets);
for i = 1:numSets
    %motnFMRs{i} = fullfile(fmrFolders{i},[fmrNames{i}(1:(end-4)) '_3DMCTS.fmr']);
    thisFile = sliceTimeFMRs{i};
    motnFMRs{i} = [thisFile(1:(end-4)) '_3DMCTS.fmr'];
    if ~exist(motnFMRs{i},'file') %only do motion correction if it's not done already! 
        fprintf(1,'\nstarting motion correction for scan %i\n',i);
        docFMR = bvqx.OpenDocument(thisFile); %(fullfile(fmrFolders{i},fmrNames{i})); 
        docFMR.CorrectMotionTargetVolumeInOtherRunEx(targetFMR,targetVol,interpMethod,useFullDataSet,maxIterations,makeMovies,makeLogFile);
        if ~strcmp(docFMR.FileNameOfPreprocessdFMR,motnFMRs{i})
            fprintf(1,'Resulting filename of motion-corrected fmr, \n\t %s,\n does not match expected:\n\t%s\n\n',docFMR.FileNameOfPreprocessdFMR,motnFMRs{i});
        end
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
    % 	because it's A>>P), Volume = 1, and then oppPE.fmr in the 2nd row
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
    processedFMRs{i} = docFMR.FileNameOfPreprocessdFMR;
    docFMR.Close;
end

%% in case preprocessing is already done and just need to get the filenames: 
% for i=1:numSets
%     processedFMRs{i} = fullfile(fmrFolders{i},sprintf('s%i_SCLAI_3DMCTS_undist_LTR_THPGLMF2c.fmr',i));
% end
%% Delete unnecessary files
for i = 1:numSets
    %delete original .fmr and .stc files
    fn = fullfile(fmrFolders{i},fmrNames{i});
    delete(fn);
    delete([fn(1:(end-4)) '.stc']);

    %delete slice time corrected .fmr and .stc files
    delete(sliceTimeFMRs{i});
    delete([sliceTimeFMRs{i}(1:(end-4)) '.stc']);
    %delete motion corrected .fmr and .stc files
    delete(motnFMRs{i});
    delete([motnFMRs{i}(1:(end-4)) '.stc']);
    
    %delete undistorted .fmr and .stc files
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
docVMR = bvqx.OpenDocument(fullfile(anatPath, 'anat_SAG_IIHC.vmr'));
disp('Examine brightness values. Any key to continue.')
pause

docVMR.AutoACPCAndTALTransformation();
disp('Coregister functional set 1 and anatomical (native space).')
disp('Any key to continue.')
pause

%% Make VTC's 

vtcSpace = 'ACPC'; %'TAL'; 
useBoundingBox = true;

VMR = fullfile(anatPath,'anat_SAG_IIHC.vmr'); %Important to load the native VMR not the ACPC or TAL

if doDistCorr
    IA = 's1_SCLAI_3DMCTS_undist_LTR_THPGLMF2c-TO-anat_SAG_IIHC_IA.trf';
    FA = 's1_SCLAI_3DMCTS_undist_LTR_THPGLMF2c-TO-anat_SAG_IIHC_FA.trf';
else
    IA = 's1_SCLAI_3DMCTS_LTR_THPGLMF2c-TO-anat_SAG_IIHC_IA.trf';
    FA = 's1_SCLAI_3DMCTS_LTR_THPGLMF2c-TO-anat_SAG_IIHC_FA.trf';
end

%these automatically are put in set1 folder
IA = fullfile(fmrFolders{1},IA);
FA = fullfile(fmrFolders{1},FA);

if strcmp(vtcSpace,'TAL')
    vtcType = 'TAL';
else
    if useBoundingBox
        vtcType = 'ACPC_bbox';
    else
        vtcType = 'ACPC';
    end
end


TAL = 'anat_SAG_IIHC_aACPC.tal';
ACPC = 'anat_SAG_IIHC_aACPC.trf';

vtcDataType = 2; %1=integer 2-byte; 2=float
vtcResolution = 3; %WHY?
vtcInterp = 1; %0=nearest neighbor; 1=tilinear; 2=sinc
boundBoxThreshold = 100; 



for i = 1:numSets
    docVMR = bvqx.OpenDocument(VMR);
    docVMR.ExtendedTALSpaceForVTCCreation = 0;
    
    if nfLoc(i)>0
        vtcName = sprintf('s%i_fLoc%i_%s.vtc',i,nfLoc(i),vtcType);
    elseif nVWFALoc(i)>0
        vtcName = sprintf('s%i_VWFALoc%i_%s.vtc',i,nVWFALoc(i),vtcType);
    else
        vtcName = sprintf('s%i_%s.vtc',i,vtcType);
    end
        
        
    if strcmp(vtcSpace,'ACPC')
        if useBoundingBox
            docVMR.UseBoundingBoxForVTCCreation = 1;
            %Set the box as big as possible
            docVMR.TargetVTCBoundingBoxXStart = 1;
            docVMR.TargetVTCBoundingBoxXEnd = 255;
            docVMR.TargetVTCBoundingBoxYStart = 1;
            docVMR.TargetVTCBoundingBoxYEnd = 255;
            docVMR.TargetVTCBoundingBoxZStart = 1;
            docVMR.TargetVTCBoundingBoxZEnd = 255;
        else
            docVMR.UseBoundingBoxForVTCCreation = 0;
        end
        docVMR.CreateVTCInACPCSpace(processedFMRs{i},IA,FA,ACPC,vtcName,vtcDataType,vtcResolution,vtcInterp,boundBoxThreshold);
    else
        docVMR.UseBoundingBoxForVTCCreation = 0;
        docVMR.CreateVTCInTALSpace(processedFMRs{i},IA,FA,ACPC,TAL,vtcName,vtcDataType,vtcResolution,vtcInterp,boundBoxThreshold);
    end
    docVMR.Close;
end