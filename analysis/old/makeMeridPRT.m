%make Retinotopy PRT protocol file 


prt = fopen('meridianPRT.prt','w');

nCycles = 8; 
period = 30; 
TR = 2; 
periodTR = round(period/TR);
totalTR = periodTR*nCycles;
nCond = 2; 
%THIS IS A HACK, because stimulus duration did not fit very nicely into
%TRs. So now we're pretending that stim1 lasted 7 TRs and stim 2 lasted 8
%TRs, just to make it fit. 
stimDurTR = [floor(periodTR/nCond) ceil(periodTR/nCond)];


hues = linspace(0,.67,nCond);
sats = ones(1,nCond); 
vals = ones(1,nCond); 

rgbs = round(255*hsv2rgb([hues' sats' vals']));

condLabs = {'Horizontal','Vertical'};

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

