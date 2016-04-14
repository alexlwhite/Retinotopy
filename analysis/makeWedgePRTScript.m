%make Retinotopy PRT protocol file 


prt = fopen('wedgePRT.prt','w');

nCycles = 8; 
period = 32; 
TR = 2; 
periodTR = round(period/TR);
totalTR = periodTR*nCycles;
nCond = 16; 


hues = linspace(0,(nCond-1)/nCond,nCond);
sats = ones(1,nCond); 
vals = ones(1,nCond); 

rgbs = round(255*hsv2rgb([hues' sats' vals']));

headerTxt1 = 'FileVersion:        2\n\nResolutionOfTime:   Volumes\n\nExperiment:         Wedge\n\n';
headerTxt2 = 'BackgroundColor:    0 0 0\nTextColor:          255 255 255\nTimeCourseColor:    255 255 255\n';
headerTxt3 = 'TimeCourseThick:    3\nReferenceFuncColor: 0 0 80\nReferenceFuncThick: 3\n\n';
headerTxt4 = sprintf('NrOfConditions:     %i',nCond);

for hti=1:4 
    eval(sprintf('fprintf(prt,headerTxt%i);',hti));
end


for ci=1:nCond
    starts = ci:periodTR:totalTR;
    ends   = starts; %+1; 
    
    nRep = length(starts);
    
    fprintf(prt,'\n\nWedge%i\n',ci);
    fprintf(prt,'%i\n',nRep);
    for ri=1:nRep
        fprintf(prt,'%i\t%i\n',starts(ri),ends(ri));
    end
    
    fprintf(prt,'Color: %i %i %i',rgbs(ci,1),rgbs(ci,2),rgbs(ci,3));
end

