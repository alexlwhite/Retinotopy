%make Retinotopy PRT protocol file 
function makeMeridPRT(stim,prtName)

prt = fopen(prtName,'w');

nCycles = stim.time.NCycles; 
period = stim.time.CycleDur; 
TR = stim.display.TR;
periodTR = round(period/TR);
totalTR = periodTR*nCycles;
nCond = 2; 
%NEXT IS A HACK, in case stimulus duration was not a multiple of TRs
%If so, we'll pretending that stim1 lasted 7 TRs and stim 2 lasted 8
%TRs, just to make it fit. 
stimDurTR = [floor(periodTR/nCond) ceil(periodTR/nCond)];


hues = linspace(0,.67,nCond);
sats = ones(1,nCond); 
vals = ones(1,nCond); 

rgbs = round(255*hsv2rgb([hues' sats' vals']));

condLabs = {'Horizontal','Vertical'};

headerTxt1 = 'FileVersion:        2\n\nResolutionOfTime:   Volumes\n\nExperiment:         Meridians\n\n';
headerTxt2 = 'BackgroundColor:    0 0 0\nTextColor:          255 255 255\nTimeCourseColor:    255 255 255\n';
headerTxt3 = 'TimeCourseThick:    3\nReferenceFuncColor: 0 0 80\nReferenceFuncThick: 3\n\n';
headerTxt4 = sprintf('NrOfConditions:     %i',nCond);

for hti=1:4 
    eval(sprintf('fprintf(prt,headerTxt%i);',hti));
end


for ci=1:nCond
    
    starts = (1:periodTR:totalTR)+(ci-1)*floor(periodTR/nCond);
    ends   = starts+stimDurTR(ci)-1;
    
    nRep = length(starts);
    
    fprintf(prt,'\n\n%s\n',condLabs{ci});
    fprintf(prt,'%i\n',nRep);
    for ri=1:nRep
        fprintf(prt,'%i\t%i\n',starts(ri),ends(ri));
    end
    
    fprintf(prt,'Color: %i %i %i',rgbs(ci,1),rgbs(ci,2),rgbs(ci,3));
end

