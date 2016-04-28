% function el = initializeEyelinkRetinotopy(c) 
% by Alex White, April 2016
% based on initEyelink by Martin Rolfs
% integrated with John Palmer's EL routines 
% 
% This function: 
% - creates structure el with default settings
% - changes some settings in el and adds some field 
% - initializes connection to Eyelink machine with function EyelinkInit 
%   (as opposed to Eyelink('initialize'), which seems to determine what
%   kind of calibraiton routine you get). 
% - sends some commands to eyelink to change settings, such as calibration
%   area 
% - Opens edf file with name eyefilename 
% - Prints out some header information to eyefilename 
%
% Inputs: 
% - structure c with task and screen info, and "edfFileName", a character string 
%
% Outputs: 
% - structure el 
% - status, which is -1 in dummy mode, 0 if no connection, 1 if
%   good connection 
%
% Note: this function will kill the program and close screen if there's an error in
%   establishing connection 
% 
% This version: for Retinotopy experiments, which use a stucture "c" that
% contains information bout screen, task, stimulus



function [el, status] = initializeEyelinkRetinotopy(c)


%--------------------------------------%
% Initialize el structure with eyelink defaults
%--------------------------------------%

% sets things like calibration target physical parametres 
el=EyelinkInitDefaults(c.display.windowPtr); 

%--------------------------------------%
% Add some arguments to el structure  
%--------------------------------------%

% specify eye to be used
el.eye = el.RIGHT_EYE;							% use eye code defined by low level routine

% move args into el structure
el.screenRect = c.display.rect;
el.pixelsperdegree = c.display.ppd;
el.eyefilename = strcat(c.edfFileName,'.edf');
el.xcenter = c.display.centerX;
el.ycenter = c.display.centerY; 

%--------------------------------------%
% modify a few of the default settings %
%--------------------------------------%
el.backgroundcolour = c.display.bkColor;		% background color when calibrating
el.foregroundcolour = c.display.fgColor;        % foreground color when calibrating

%Set sounds: 

el.calibrationfailedsound = 1;				% no sounds indicating success of calibration
el.calibrationsuccesssound = 1;

%el.drift_correction_target_beep = el.cal_target_beep; %because drift correction causes some crash due to Snd? 

el.helptext='Press RETURN to toggle camera image';
el.helptext=[el.helptext '\n' 'Press C to Calibrate'];
el.helptext=[el.helptext '\n' 'Press V to Validate'];
el.helptext=[el.helptext '\n' 'Press D to Drift Correct only'];
el.helptext=[el.helptext '\n' 'Press ESC to exit and begin experiment'];


EyelinkUpdateDefaults(el);


%--------------------------------------%
% Initialize eye tracker and test if operational
%--------------------------------------%

if ~EyelinkInit(c.EYE<1);  %if c.EYE<0, then initialize in dummy mode                      % Initialization of Eyelink
    reddUp(true); %close connection and screen
    error('ERROR: Bad Eyelink Initialization');
end


%Two crucial difference from Martin Rolfs' old initEyelink: 
% (1) Martin used Eyelink('initialize'), which seems to set things 
% differently than EyelinkInit. 
% Martin's code: 
% if (Eyelink('initialize') ~= 0) %Eyelink('initialize') returns status 0 if ok, -1 if error 
%      Eyelink('initializedummy'); %if there's an error, initialize in dummy mode
% end
% 
% (2) In my code from Martin's lab, there was a separate
% EyelinkDoTrackerSetup function, the one that executes the calibration.
% This seems to be an older version from the one currently sent out with
% PTB. I don't understand all the differences, but the new one uses
% something called el.callbacks. 
%
% It's the combination of these two differences that affects how the
% calibration works. Using EyelinkInit and then calling the newer standared
% EyelinkDoTrackerSetup lets you see the eye image on the stimulus monitor
% when calibrating. 


% JPs code to check again, seems unnecesary here
% if Eyelink('Isconnected') ~= 1, 				% make sure it is connected
% 	error('Error in initializeEyelink:  Eyelink not connected');
% end;

%--------------------------------------%
% Send eyelink commands to change settings: 
%--------------------------------------%
Eyelink('Command', 'clear_screen 0');	% initialize screen on operater PC

Eyelink('Command', 'screen_pixel_coords = %d %d %d %d', ...
	el.screenRect(1),el.screenRect(2),el.screenRect(3)-1,el.screenRect(4)-1);
	
Eyelink('Message', 'DISPLAY_COORDS %d %d %d %d', ...
	el.screenRect(1),el.screenRect(2),el.screenRect(3)-1,el.screenRect(4)-1);

Eyelink('Command', ['active_eye = ',el.eye]);	% set eye to record
Eyelink('Command', 'binocular_enabled = NO');	
Eyelink('Command', 'head_subsample_rate = 0');	% normal (no anti-reflection)
Eyelink('Command', 'heuristic_filter = ON');	% ON for filter (normal)...also possible [1 1]	
Eyelink('Command', 'pupil_size_diameter = NO');	% no for pupil area (yes for dia)
Eyelink('Command', 'simulate_head_camera = NO');% NO to use head camera

if c.MRI
    %Setting to 5pt calibration for the scanner: 
    Eyelink('Command', 'calibration_type = HV5');
else
    Eyelink('Command', 'calibration_type = HV9');
end
Eyelink('Command', 'enable_automatic_calibration = YES');	% YES default
Eyelink('Command', 'randomize_calibration_order = YES');	% YES default
Eyelink('Command', 'automatic_calibration_pacing = 1000');	% 1000 ms default

Eyelink('Command', 'randomize_calibration_order = YES');% YES default
Eyelink('Command', 'randomize_validation_order = YES');	% YES default

%--------------------------------------%
% Set calibraiton area 
%--------------------------------------%
if c.squareCalib
    aspectRatio  = c.display.rect(3)/c.display.rect(4);
    calibAreaH   = c.calibShrink/aspectRatio; %makes it square
else
    calibAreaH   = c.calibShrink;
end
calibAreaV   = c.calibShrink;

calibAreaStr = sprintf('calibration_area_proportion = %.3f %.3f',calibAreaH, calibAreaV);
Eyelink('command', calibAreaStr); % shrinking of calibration area


%---------------------------------------%
% Open eyelink edf file %
%---------------------------------------%

i = Eyelink('OpenFile', el.eyefilename);		% open data file on operater PC
if i~=0
    fprintf('Cannot create EDF file ''%s'' ', edffilename);
    Eyelink( 'Shutdown');
    return;
end
Eyelink('Command', 'clear_screen 0');		% initialize screen on operater PC

%---------------------------------------%
% Print to file information on the experiment %
%---------------------------------------%
Eyelink('command', 'add_file_preamble_text ''Recorded with Retinotopy Code by Alex White''');

%--------------------------------------------------------%
% write descriptions of the experiment into the edf-file %
%--------------------------------------------------------%
Eyelink('message', 'BEGIN OF DESCRIPTIONS');
Eyelink('message', 'Subject code: %s', el.eyefilename);
Eyelink('message', 'END OF DESCRIPTIONS');

%---------------------------------------%
% test mode of eyelink connection
%---------------------------------------%

status = Eyelink('isconnected');
switch status
    case -1
        fprintf(1, 'Eyelink in dummymode.\n\n');
    case  0
        fprintf(1, 'Eyelink not connected.\n\n');
    case  1
        fprintf(1, 'Eyelink connected.\n\n');
end



%% Commands from JPs ELSetEyelinkDefaultsAW
%% commented out by AW 3/12/15 because I'm not sure what they do: 
%Eyelink('Command', 'saccade_velocity_threshold = 35');
%Eyelink('Command', 'saccade_acceleration_threshold = 9500');
%Eyelink('Command', ...
%	'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');	
%Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,BUTTON');
%Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
%Eyelink('Command','file_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');

%Eyelink('Command', 'analog_out_data_type = OFF');		% YES default



