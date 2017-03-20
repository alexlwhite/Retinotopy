%% function c = retinotopyCheckTaskResponse(c, correctResp, taskEventNum)
% 
% This function is called from inside a retinotopy stimulus function during
% experiment. Checks for a response from the subject and adds data on that
% response to the "c.task" structure. 
% 
% Inputs: 
% - c, structure contianing information about task and stimulus 
% - correctResp: what the current correct response should be. 0=no target
%   event has recently occurred, so no button should be pressed. 1 or 2 = recent event in stimulus 1 or 2. 
% - taskEventNum: an index referring to the number of the target event that
%   has recently occurred, based on the current time in the expriment. Used
%   to determine whether that stimulus was detected or not, to set feedback
%   at the correct time. 
% - taskChunk: an index of the current time segment in the experiment 
% - elapsedTime: time in seconds since stimulus started 
% 
% Outputs: 
% - c: original c structure with data added to c.task (for false alarms and hits) 
function c = retinotopyCheckTaskResponse(c, correctResp, taskEventNum, taskChunk, elapsedTime)

keyPressed = checkTarPress(c.task.buttons);

%determine whether this was the correct response given task events
if keyPressed>0
    if correctResp == 0 %false alarm
        %if false alarm not already recorded in this "chunk",
        %record it now
        if c.task.feedback(taskChunk) ~= 2; %feedback for wrong stimulus/false alarm
            c.task.nFalseAlarm = c.task.nFalseAlarm + 1;
            c.task.tFalseAlarm = [c.task.tFalseAlarm elapsedTime];
        end
        c.task.feedback(taskChunk) = 2; %feedback for wrong stimulus/false alarm
    else
        if correctResp == keyPressed || ~c.task.discriminate %hit
            c.task.eventsHit(taskEventNum) = 1;
            c.task.feedback(c.task.eventFeedbackTime(taskEventNum)) = 3; %feedback for hit
        else %pressed key at right time, but for wrong stimulus
            c.task.eventsHit(taskEventNum) = -1;
            c.task.feedback(c.task.eventFeedbackTime(taskEventNum)) = 2; %feedback for wrong stimulus
        end
        %add time of hit:
        if c.task.eventsHit(taskEventNum) == 0
            c.task.tHit = [c.task.tHit elapsedTime];
        end
    end
end