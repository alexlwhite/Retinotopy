%make a PRT file for brainvoyager, containing information about 1 run of
%the LOCALIZER scan for VWFA_Attn2
%
%Inputs
%- task: data structure
%- fn: filename for PRT text file, including directory
%
%
%Also saves a mat file with start and end TRs of each
%condition. That mat file has same name as text PRT file, and contains a
%structure called PRT with blockTRs, a cell array with one element for each
%condition (including blanks/breaks). Each element is a nx2 matrix of TRs
%when that condition started (column 1) and ended (column 2).
% 
% The PRT variable in the mat file also contains a field
% eventSequence, which may be more useful. This is a 1xT vector, where T is
% the total number of TRs. Each element is an integer that indicates which
% condition was "on" at that time. 

% 

function PRT = makePRT_VWFA_Attn2_Locr(task, fn)


TR = 2;
typeLabs=  task.localizerStimConds;
typeLabs{strcmp(typeLabs,'locWord')} = 'word';
sideLabs = {'left','right'};

fprintf(1,'\n\n(makePRT_VWFA_Attn1_Locr) Assuming TR is %.1f s\n\n',TR);

blankAsCond = true; %whether to include rest/blanks as a condition 
blankCond = 0;

%% Extract data and convert to TRs
d = task.data;

nStimTypes = numel(typeLabs); 
nStimSides = numel(sideLabs); 

nCond = nStimTypes*nStimSides;

isStim = d.blockTypes~=0;
nStimBlocks = sum(isStim); %count number of blocks that aren't blanks

if blankAsCond
    nBlocks = length(d.blockTypes);
    blockSides = d.blockSides;
    blockTypes = d.blockTypes;
    nCond = nCond+1;
    %assign 1 number to each sidextype condition:
    sidesByCond = [1 1 2 2 blankCond];
    
    typesByCond = [1 2 1 2 blankCond];
    
    conds = [1:4 blankCond];
    
    blockStartTimes = d.blockStartTimes;
    blockEndTimes   = d.blockEndTimes;
    blankCondNum = nCond;
    
else
    nBlocks = nStimBlocks;
    blockSides = d.blockSides(isStim);
    blockTypes = d.blockTypes(isStim);
    
    %assign 1 number to each sidextype condition:
    sidesByCond = [1 1 2 2];
    typesByCond = [1 2 1 2];
    
    conds = 1:4;
    
    blockStartTimes = d.blockStartTimes(isStim);
    blockEndTimes   = d.blockEndTimes(isStim);
end


blockConds = NaN(1,nBlocks); 
condLabs = cell(1,nCond);
nRepsByCond = NaN(1,nCond);

for ci=1:nCond
    blockConds(blockSides==sidesByCond(ci) & blockTypes==typesByCond(ci)) = conds(ci);

    if sidesByCond(ci)==blankCond && typesByCond(ci)==blankCond && blankAsCond
        condLabs{ci} = 'blank';
    else
        condLabs{ci} = sprintf('%s_%s',sideLabs{sidesByCond(ci)},typeLabs{typesByCond(ci)});
    end
    nRepsByCond(ci) = sum(blockConds==conds(ci));
end

blockStartTRs  = 1 + round(blockStartTimes/TR);
blockEndTRs = round(blockEndTimes/TR);

totalTRs = round(task.scanDuration/TR);

%add an initial blank/rest period? 
if blockStartTRs(1)>1 && task.addBlankAtScanStart && blankAsCond
    blockEndTRs = [blockStartTRs(1)-1 blockEndTRs];
    blockEndTimes = [blockStartTimes(1) blockEndTimes];
    
    blockStartTRs = [1 blockStartTRs];
    blockStartTimes = [0 blockStartTimes];
    
    blockConds = [blankCond blockConds];
    nRepsByCond(conds==blankCond)=nRepsByCond(conds==blankCond)+1;
end

%add a final blank/rest period? 
if blockEndTRs(end)<totalTRs && task.addBlankAtScanEnd && blankAsCond
    blockStartTRs = [blockStartTRs blockEndTRs(end)+1];
    blockStartTimes = [blockStartTimes blockEndTimes(end)];
    
    blockEndTRs = [blockEndTRs totalTRs];
    blockEndTimes = [blockEndTimes d.scanDuration];
    
    blockConds = [blockConds blankCond];    
    nRepsByCond(conds==blankCond)=nRepsByCond(conds==blankCond)+1;

end

%% make PRT.eventSequence
%Create PRT.eventSequence, a 1xtotalTRs vector that indicates which condition was on at each TR. For now, 0 is blank
PRT.eventSequence = NaN(1,totalTRs); 
for ci=1:nCond
    
    theseOnsets = blockStartTRs(blockConds==conds(ci));
    theseOffsets = blockEndTRs(blockConds==conds(ci));
    
    for ri=1:nRepsByCond(ci)
        if strcmp(condLabs{ci},'blank')
try
    PRT.eventSequence(theseOnsets(ri):theseOffsets(ri)) = 0;
catch
    keyboard
end
        else
            PRT.eventSequence(theseOnsets(ri):theseOffsets(ri)) = ci;
        end
    end
end


if ~blankAsCond
    %add rest/blanks as 0s in event sequence, but those don't otherwise
    %count as conditions
    PRT.eventSequence(isnan(PRT.eventSequence)) = 0;
else
    %Deal with empty slots in event sequence due to rounding errors
    if any(isnan(PRT.eventSequence))
        fprintf(1,'\n(makePRT_VWFA_Attn1_Locr) Warning! Some TRs not accounted for!\n');
        fprintf(1,'(makePRT_VWFA_Attn1_Locr) Fixing by assuming the previous condition extends 1 TR.\n');
        emptyTRs = find(isnan(PRT.eventSequence));
        for ei=1:length(emptyTRs)
            badTR = emptyTRs(ei);
            
            if badTR==1
                %if the very 1st is empty, thats because of a rounding error for
                %1st event. Extend it back in time
                PRT.eventSequence(badTR)=PRT.eventSequence(badTR+1);
                
                badI = blockStartTRs==(badTR+1);
                blockStartTRs(badI) = badTR;
            else
                PRT.eventSequence(badTR)=PRT.eventSequence(badTR-1);
                %Then correct "breakStartTRs" or "blockStartTRs" which are used in PRT text file
                
                badI = blockEndTRs==(badTR-1);
                blockEndTRs(badI) = badTR;
            end
        end
    end
end


%% make colors
hues = linspace(0,.67,nCond);
sats = ones(1,nCond);
vals = ones(1,nCond);

rgbs = round(255*hsv2rgb([hues' sats' vals']));

breakColor = [150 150 150];
if blankAsCond
    rgbs(blankCondNum,:) = breakColor;
end

%% print .prt text file and make PRT.blockTRs
prt = fopen(fn, 'w');

headerTxt1 = 'FileVersion:        2\n\nResolutionOfTime:   Volumes\n\nExperiment:        VFWA_Attn1_LOCALIZER\n\n';
headerTxt2 = 'BackgroundColor:    0 0 0\nTextColor:          255 255 255\nTimeCourseColor:    255 255 255\n';
headerTxt3 = 'TimeCourseThick:    3\nReferenceFuncColor: 0 0 80\nReferenceFuncThick: 3\n\n';
headerTxt4 = sprintf('NrOfConditions:     %i',nCond); %add one to include break

for hti=1:4
    eval(sprintf('fprintf(prt,headerTxt%i);',hti));
end

%Create PRT.eventSequence, a 1xtotalTRs vector that indicates which condition was on at each TR. For now, 0 is blank
PRT.blockTRs = cell(1,nCond);
for ci=1:nCond
    
    fprintf(prt,'\n\n%s\n',condLabs{ci});
    fprintf(prt,'%i\n',nRepsByCond(ci));
    
    theseOnsets = blockStartTRs(blockConds==conds(ci));
    theseOffsets = blockEndTRs(blockConds==conds(ci));
    
    for ri=1:nRepsByCond(ci)
        fprintf(prt,'%i\t%i\n',theseOnsets(ri),theseOffsets(ri));
    end
    
    fprintf(prt,'Color: %i %i %i',rgbs(ci,1),rgbs(ci,2),rgbs(ci,3));
    
    PRT.blockTRs{ci} = [PRT.blockTRs{ci}; theseOnsets' theseOffsets'];
end


PRT.condLabs = condLabs;
PRT.blankAsCond = blankAsCond;

%% check for any unaccounted for TRs
if any(isnan(PRT.eventSequence))
    fprintf(1,'\n(makePRT_VWFA_Attn1_Locr) ERROR! Some TRs STILL not accounted for! FAIL!!\n');
    return
end

%% save:
matFileName = [fn(1:(end-3)) 'mat'];
save(matFileName,'PRT');

