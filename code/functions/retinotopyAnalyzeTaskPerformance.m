%% function c = retinotopyAnalyzeTaskPerformance(c, lastEvent)
% This function analyzes detection task performance in retinotopy scan 
% 
% Inputs: 
% - c: structure contianing information about task and stimulus 
% - lastEvent: index of the last event that occurred in the experiment (to
%   only include in the anlaysis events taht were actually presented) 
% 
% Outputs: 
% - c: original structure with data added to c.recorded, reflecting hit rate, 
%   false alarm rate, and  proportion of time the wrong stimulus was
%   reported

function c = retinotopyAnalyzeTaskPerformance(c, lastEvent)

eHits = c.task.eventsHit(1:lastEvent);
eTypes = c.task.eventTypes(1:lastEvent);
for tt = c.task.whichStim
    c.recorded.hitRate(tt) = mean(eHits(eTypes==tt)==1);
end

%c.recorded.hitRate = mean(c.task.eventsHit==1);
c.recorded.nFalseAlarms = c.task.nFalseAlarm;
c.recorded.wrongStimRate = mean(c.task.eventsHit==-1);