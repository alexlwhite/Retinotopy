function [stimSeq] = myProtocol(c,outputFile1)

stimtimes = round(c.recorded.timeofStimOnsets/c.display.Tr)+1;
mytimes = round(c.recorded.timeofBockOnsets/c.display.Tr)+1;


fp=fopen([c.files.targetdir outputFile1],'a');
headerprtfile1={'FileVersion:        2 '
    'ResolutionOfTime:   Volumes'
    'Experiment:         '};
headerprtfile2={'BackgroundColor:    0 0 0'
    'TextColor:          255 255 255'
    'TimeCourseColor:    255 255 255'
    'TimeCourseThick:    3'
    'ReferenceFuncColor: 0 0 80'
    'ReferenceFuncThick: 3'
    'NrOfConditions:  2'};


fprintf(fp,'\n%s\n','---------------------------------------------------');
fprintf(fp,'\n%s\n',datestr(now));
fprintf(fp,'\n%s\n',headerprtfile1{:});
% fprintf(fp,'\n%s\n%s\n%sFlash\tFlickFreq=%i\tBlockdur=%d\tNBlocks=%i\n', headerprtfile1{:},c.time.myflick_freq,c.time.BlockDur, c.time.NBlocks);
% fprintf(fp,'\n%s\n\%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\n',headerprtfile2{:});
fprintf(fp,'\n%s\n',headerprtfile2{:});

nconds = length( c.design.conditions ) ;
colors = round(hsv(nconds)*255);
% loop across conditions
for ib = 1:nconds
    % Condition ib
    nreps = sum(c.tbt.conditions == c.design.conditions(ib));
    fprintf(fp,'\n condition: %i \t number of reps: %d\n',ib,nreps);
    fprintf(fp,'\n%d\n',nreps);
    for i = 1:size(mytimes,1)-1
        if c.tbt.conditions(i) == c.design.conditions(ib)
%             fprintf('%d %d %.2f %.2f\n',...
%                 stimtimes(i,1), stimtimes(i,1)+1,...
%                 c.recorded.timeofStimOnsets(i,1),...
%                 c.recorded.timeofStimOnsets(i,1)/3);
            fprintf(fp,'%d %d\n',stimtimes(i,1), stimtimes(i,1)+1);
        end
    end
    fprintf(fp,'Color: %i %i %i\n', colors(ib,1), colors(ib,2), colors(ib,3));
end
fclose(fp);