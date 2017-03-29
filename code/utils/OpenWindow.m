function display = OpenWindow(display)
%display = OpenWindow([display])
%
%Calls the psychtoolbox command "Screen('OpenWindow') using the 'display'
%structure convention.
%
%Inputs:
%   display             A structure containing display settings with fields:
%       screenNum       Screen Number (default is 0)
%       bkColor         Background color (default is black: [0,0,0])
%       skipSyncTests      Flag for skpping screen synchronization (default is 0, or don't skip)
%                       When set to 1, vbl sync check will be skipped,
%                       along with the text and annoying visual (!) warning
%
%Outputs:
%   display             Same structure, but with additional fields filled in:
%       windowPtr       Pointer to window, as returned by 'Screen'
%       frameRate       Frame rate in Hz, as determined by Screen('GetFlipInterval')
%       resolution      [width,height] of screen in pixels
%       center          [x,y] center of screeen in pixels 
%
%Note: for full functionality, the additional fields of 'display' should be
%filled in:
%
%       dist             distance of viewer from screen (cm)
%       width            width of screen (cm)

%Written 11/13/07 by gmb
% 9/17/09 gmb zre added the 'center' field in ouput of display structure.
%
% 10/21/15: ALW added a bunch of functionality: 
%   - loading of normalized gamma table, BlendFunction, and  HideCursor. 
%   - command to choose the screen to use as the screen with the max
%   handle number (should be the external monitor) 
%   - automated setting of screen resolution to some desired level 
%   - opening a second PTB window on the computer's main screen if not in
%   mirror mode, as recommended by M. Kleiner 
%   - printing descriptive output

if ~exist('display','var')
    display.screenNum = 0;
end

if ~isfield(display,'screenNum')
    display.screenNum = 0;
end

if ~isfield(display,'bkColor')
    display.bkColor = [0,0,0]; %black
    display.fgColor = [1 1 1]; %white
end

if ~isfield(display,'skipSyncTests')
    display.skipSyncTests = 1;
end

% get rid of PsychtoolBox Welcome screen
Screen('Preference', 'VisualDebugLevel',3);

if display.skipSyncTests
    Screen('Preference', 'Verbosity', 0);
    Screen('Preference', 'SkipSyncTests',1);
    Screen('Preference', 'VisualDebugLevel',0);
end


% general information on task computer
display.computer = Screen('Computer');  % get information about display computers

% keyboard set up
KbName('UnifyKeyNames');
a = cd;
if a(1)=='/' %if on mac
%     a = PsychHID('Devices');
%     for i = 1:length(a), d(i) = strcmp(a(i).usageName, 'Keyboard'); end
%     keybs = find(d);
    display.keybs = GetKeyboardIndices();
else
    display.keybs = [];
end

%Listen to keys but don't print it out to Matlab command window: 
%not necessary for now, if add it back in, be sure to add ListenChar(1) at end 
%ListenChar(2); 


% If there are multiple displays guess that one without the menu bar is the
% best choice.  Dislay 0 has the menu bar.
display.allScreens = Screen('Screens');
display.screenNum  = max(display.allScreens);

% Set the display resolution 
if isfield(display,'goalResolution')
    display.oldRes = Screen('Resolution',display.screenNum);
    display.changeRes = ~(display.oldRes.width == display.goalResolution(1) && display.oldRes.height == display.goalResolution(2) && display.oldRes.hz == display.goalFPS);
    if display.changeRes
        display.oldRes = SetResolution(display.screenNum, display.goalResolution(1), display.goalResolution(2), display.goalFPS);
    end
else
    display.changeRes = false;
end

%Open the window
[display.windowPtr,display.rect]=Screen('OpenWindow',display.screenNum,display.bkColor);
%Set the display parameters 'frameRate' and 'resolution'
display.frameRate = 1/Screen('GetFlipInterval',display.windowPtr); %Hz

if ~isfield(display,'resolution')
    display.resolution = display.rect([3,4]);
end

[display.xres, display.yres]    = Screen('WindowSize',display.windowPtr);       % heigth and width of screen [pix]
display.ppd = display.dist*tan(1*pi/180)/(display.width/display.xres);	 %pixels per degree 

% determine the main window's center
[display.centerX, display.centerY] = WindowCenter(display.windowPtr);

display.center = floor(display.resolution/2);

%Load calibration file
if ~isempty(display.normlzdGammaTable)
    Screen('LoadNormalizedGammaTable', display.windowPtr, display.normlzdGammaTable);
end

%Set blend function:
Screen('BlendFunction',display.windowPtr,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;

   
display.nScreens = length(display.allScreens);
% If we are not in mirror mode, open a blank screen on the unused monitor
% (recommended by "help MirrorMode") 
if display.nScreens==2
    display.otherScreenNum = display.allScreens(display.allScreens~=display.screenNum);
    display.otherScreenRes = Screen('Resolution',display.otherScreenNum);
    
    display.mirrored = (display.otherScreenRes.width == display.resolution(1)) && (display.otherScreenRes.height == display.resolution(2));
    [display.otherWindow,resn]=Screen('OpenWindow',display.otherScreenNum,display.bkColor);
    display.otherResolution = resn([3,4]);
    display.otherCenter = floor(display.otherResolution/2);
    Screen('Flip',display.otherWindow);
else
    display.otherWindow = display.windowPtr;
    display.mirrored = 2;
end

%Text
Screen('TextSize',display.windowPtr,20);
Screen('TextSize',display.otherWindow,20);

%print output: 
fprintf(1,'\n\n--------------------------------------------------------------\n');
fprintf(1,'(OpenWindow) Loaded parameters for screen %s on computer %s.\n',display.monName,display.computerName); 
fprintf(1,'(OpenWindow) screen height (cm) = %.1f; screen width (cm) = %.1f\n',display.height, display.width);
fprintf(1,'(OpenWindow) vertical pixels = %i; horizontal pixels = %i\n',display.resolution(2), display.resolution(1));


%Check if pixels are square: 
horizRes=display.resolution(1)/display.width;
vertRes=display.resolution(2)/display.height;

fprintf(1,'\n(OpenWindow) horizontal resolution: %.1f pix/cm; vertical resolution: %.1f pix/cm\n',horizRes,vertRes);
if (horizRes/vertRes)<0.9 || (horizRes/vertRes)> 1.1
    fprintf(1,'\n\n(OpenWindow) Warning! Pixels deviate from being square by more than 10%%, so circles will be ovals, squares will be rectangles!\n\tAdjust screen size manually.\n\n');
end
fprintf(1,'\n(OpenWindow) Screen runs at %.1f Hz.\n',display.frameRate);
fprintf(1,'(OpenWindow) subject''s viewing distance: %.1f\n',display.dist); 
if ~isempty(display.normlzdGammaTable)
    fprintf(1,'\n(OpenWindow) loading normalized gamma table for %s display on computer %s\n\n',display.monName,display.computerName);
else
    fprintf(1,'\n(OpenWindow) No normalized gamma table for %s display on computer %s\n\n',display.monName,display.computerName);
end

if display.skipSyncTests
    fprintf(1,'\n(OpenWindow) SKIPPING MONITOR SYNC TESTS\n\n');
end

if ~display.mirrored && display.nScreens==2
    fprintf('(OpenWindow) It seems that there are 2 displays not mirrored.\n(OpenWindow) Opening a second blank screen\n');
end
fprintf(1,'\n--------------------------------------------------------------\n');

%Set display open flag:
display.open = true;