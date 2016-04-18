
function pahandle = OpenSoundcard(mynoise)

reallyneedlowlatency = 1; % Call it at the beginning of your experiment script, optionally providing the 'reallyneedlowlatency' flag set to one to push really hard for low latency.
InitializePsychSound(reallyneedlowlatency)

% Default to auto-selected default output device 
deviceid = -1;

devs = PsychPortAudio('GetDevices');
for idx = 1:length(devs)
    if devs(idx).DeviceIndex == deviceid
        break;
    end
end
disp(devs(idx));

% sound params
freq = 44100;       % Must set this. 96khz, 48khz, 44.1khz.
buffersize = 0;     % Pointless to set this. Auto-selected to be optimal.
suggestedLatencySecs = [];

% Request latency mode 2, which used to be the best one in our measurement:
% classes 3 and 4 didn't yield any improvements, sometimes they even caused
% problems.
reqlatencyclass = 2; % class 2 empirically the best, 3 & 4 == 2

% Open audio device for low-latency output:
pahandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, freq, 2, buffersize, suggestedLatencySecs);

% Fill buffer with data:
PsychPortAudio('FillBuffer', pahandle, mynoise);




%% Possibility to calibrate
% % Tell driver about hardwares inherent latency, determined via calibration
% % once:
% latbias = 0;
% prelat = PsychPortAudio('LatencyBias', pahandle, latbias) %#ok<NOPRT,NASGU>
% postlat = PsychPortAudio('LatencyBias', pahandle) %#ok<NOPRT,NASGU>
