function c = makeRetinotopyTask(c) 

c.task.buttons = KbName(c.task.buttonNames); 

c.task.timeUnits = c.task.targDur; 

maxEvents = ceil(c.time.totaldur/c.task.timeUnits);

ISIs = c.task.minISI + exprndFree(c.task.expMean,1,maxEvents);
ISIs(ISIs>c.task.maxISI) = c.task.maxISI;

eventOnsetTs = cumsum(ISIs); 
eventOnsetTs = eventOnsetTs(eventOnsetTs<c.time.totaldur); 

%round to be in units of time that is checked
eventOnsetIs = ceil(eventOnsetTs/c.task.timeUnits);

c.task.eventOnsetTs = eventOnsetTs;
c.task.eventOnsetIs = eventOnsetIs;
c.task.eventTypes = zeros(size(eventOnsetIs));
c.task.events = zeros(1,maxEvents); 

if length(unique(c.task.whichStim)) == 1
    c.task.events(eventOnsetIs) = c.task.whichStim;
    c.task.eventTypes = ones(size(eventOnsetIs))*c.task.whichStim;
elseif length(unique(c.task.whichStim)) == 2
    %make half of them at fixation, half in the peripehry 
    ws = rand(size(eventOnsetIs));
    c.task.eventTypes(ws<=0.5) = 1;
    c.task.eventTypes(ws>0.5) = 2; 
    
    c.task.events(eventOnsetIs(ws<=0.5)) = 1;
    c.task.events(eventOnsetIs(ws>0.5)) = 2;
end


%length of response window in units of "chunks"
respWinLen = ceil(c.task.maxRespDur/c.task.timeUnits);

%for each "event", set what the correct button response should be 
c.task.correctResps = zeros(1,maxEvents);
c.task.respEventIs = zeros(1,maxEvents);
c.task.feedback = zeros(1,maxEvents);
for ei=1:length(eventOnsetIs)
    c.task.correctResps(eventOnsetIs(ei)+(0:(respWinLen-1))) = c.task.events(eventOnsetIs(ei));
    c.task.respEventIs(eventOnsetIs(ei)+(0:(respWinLen-1))) = ei;
    c.task.feedback(eventOnsetIs(ei)+respWinLen) = 1; %feedback for miss 
    c.task.eventFeedbackTime(ei) = eventOnsetIs(ei)+respWinLen;
end

c.task.nFalseAlarm = 0;
c.task.tFalseAlarm = [];
c.task.eventsHit = zeros(1,length(eventOnsetIs));
c.task.tHit = [];
