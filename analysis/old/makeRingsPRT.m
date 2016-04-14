%make Retinotopy PRT protocol file 


prt = fopen('ringsPRT.prt','w');

nCycles = 8; 
period = 30; 
TR = 2; 
periodTR = round(period/TR);
totalTR = periodTR*nCycles;
nCond = 15; 


hues = linspace(0,0.67,nCond);
sats = ones(1,nCond); 
vals = ones(1,nCond); 

rgbs = round(255*hsv2rgb([hues' sats' vals']));

for ci=1:nCond
    starts = ci:periodTR:totalTR;
    ends   = starts; %+1; 
    
    nRep = length(starts);
    
    fprintf(prt,'\n\nring%i\n',ci);
    fprintf(prt,'%i\n',nRep);
    for ri=1:nRep
        fprintf(prt,'%i\t%i\n',starts(ri),ends(ri));
    end
    
    fprintf(prt,'Color: %i %i %i',rgbs(ci,1),rgbs(ci,2),rgbs(ci,3));
end

