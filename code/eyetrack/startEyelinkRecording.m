%% function record = startEyelinkRecording(el, c)
% Sends commands to Eyelink system to start recording. 
% This version: April 22, 2016: designed for Retinotopy experiments
% by Alex White 
% 
% Inputs: 
% - el, a structure containing information about eyelink 
% - c, a structure containing infomraiton about task, display, stimulus 
% 
% Output: 
% - record, a boolean variable indicating whether recording started well or not 

function record = startEyelinkRecording(el, c)

Eyelink('startrecording');	% start recording
% You should always start recording 50-100 msec before required otherwise you may lose a few msec of data
WaitSecs(c.startRecordingTime);

if c.EYE>=0
    key = 1;
    while key~= 0
        key = EyelinkGetKey(el);		% dump any pending local keys
    end
end

err = Eyelink('checkrecording'); 	% check recording status
if err==0
    record = 1;
    Eyelink('message', 'RECORD_START');
else
    record = 0;	% results in repetition of fixation check
    Eyelink('message', 'RECORD_FAILURE');
    fprintf(1,'\n\nRECORD_FAILURE !!!!!!!\n\n');
end