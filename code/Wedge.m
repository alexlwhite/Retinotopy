% c = Wedge(display, carrier, time)
%
% Alex White, using code from Paola Binda & Geoff Boynton
%
% For retinotopic mapping, displays the "Wedge" stimulus: rotating wedge of
% radial checkerboard.
%
% Inputs:
% - display: structure for psychtoolbox screen
% - carrier: structure with parameters for carrier texture (radial
% checkerboard)
% - time: structure with paramters for stimulus timing
%
% Outputs:
% - c: structure containing all the inputs, as well as c.recorded.onsets,
% which has time stamps of stimulus onsets
% 
% %Feb 5 2016: edited so that Wedge starts vertically (c.mask.startAngle = -90)

function c = Wedge(display, carrier, time)

commandwindow

c.display = display;
c.carrier = carrier;
c.time = time;

%% parameters of the stimuli: visible wedge
c.mask.widthAngleDeg    = 360/8; %if discrete angles, best if this angle is a whole-number fraction of 360
c.mask.widthAngle       = c.mask.widthAngleDeg*pi/180;
c.mask.clockwise        = 1;
c.mask.discreteAngles   = 0; % if 0 continuous rotation (360 deg in one cycle)
c.mask.startAngle       = -90; %start vertically 
if c.mask.discreteAngles
    c.mask.Angles = 0:c.mask.widthAngleDeg:(360-c.mask.widthAngleDeg);
else
    c.mask.Angles = NaN;
end

if ~c.mask.clockwise
    c.mask.Angles = c.mask.Angles(end:-1:1);
end

c.recorded.escaped = false;

try
    % open PTB
    if ~c.display.open
        c.display = OpenWindow(c.display);
    end
    
    % initializations
    c.recorded.onsets = NaN(c.time.NCycles,length(c.mask.Angles));
    
    %% make carrier texture
    [Carrier_TxtPtr,x,y] = makeRetinotopyCarrier(c);
    
    %% make visible mask
    rad = sqrt(x.^2+y.^2).^.5; %"radius" of each pixel
    ang = atan2(y,x);          %polar angle of each pixel
    img = ~(abs(ang) < (c.mask.widthAngle/2) & rad <= 1);
    img = cat(3,ones(size(img))*c.display.bkColor(1),ones(size(img))*c.display.bkColor(2),...
        ones(size(img))*c.display.bkColor(3),img*255);
    c.mask.img = img;
    
    % texture is homog background, transparent only at wedge location
    Mask_TxtPtr = Screen('MakeTexture', c.display.windowPtr, img);
    
    %% make fixation point
    c.fixpt.pos = myPix([0 0],[],c.display);
    c.fixpt.size = myPix([],[.3],c.display);
    c.fixpt.type = 1; %0 (default) squares, 1 circles (with anti-aliasing), 2 circles (with high-quality anti-aliasing, if supported by your hardware). If you use dot_type = 1 you'll also need to set a proper blending mode with the Screen('BlendFunction') command!
    
    %% Draw text:
    drawRetinotopyTextStart(c,'Wedge');
    
    %% wait for trigger
    wait4T(c.display.keybs)
    if c.display.nScreens==2 && ~c.display.mirrored, Screen('Flip',c.display.otherWindow); end
    
    %% start counting time
    runStim = true;
    
    t0 = GetSecs; t = GetSecs - t0;
    while runStim
        escape = escPressed(c.display.keybs);
        if ~escape
            if t <= c.time.DummyDur
                %% dummy scans
                % non fa niente
            else
                %% actual stimulus
                elapsedTime = t-c.time.DummyDur;
                thisCycle = ceil(elapsedTime/c.time.CycleDur);
                flickState =  round( mod( elapsedTime * c.carrier.flickerHz, 1) ) +1;
                tInCycle = mod(elapsedTime,c.time.CycleDur);
                
                if c.mask.discreteAngles
                    thisBlock = ceil(tInCycle/(c.time.CycleDur/length(c.mask.Angles)));
                    rotationAngle = c.mask.Angles(thisBlock); % discrete angles
                else
                    rotationAngle = sign(c.mask.clockwise-.5)*mod(tInCycle*360*(1/c.time.CycleDur),360)+c.mask.startAngle; % continuous rotation
                end
                
                if thisCycle <= c.time.NCycles
                    Screen('DrawTexture', c.display.windowPtr, Carrier_TxtPtr(flickState),[],...
                        [0 0 c.display.resolution], rotationAngle);
                    Screen('DrawTexture', c.display.windowPtr, Mask_TxtPtr,[],...
                        [0 0 c.display.resolution], rotationAngle);
                    
                    %save onset time:
                    if c.mask.discreteAngles
                        if isnan(c.recorded.onsets(thisCycle,thisBlock))
                            c.recorded.onsets(thisCycle,thisBlock) = elapsedTime;
                        end
                    else
                        if isnan(c.recorded.onsets(thisCycle,1))
                            c.recorded.onsets(thisCycle,1) = elapsedTime; % record the beginning of the block
                        end
                    end
                end
            end
            % Fixation point:
            Screen('DrawDots',c.display.windowPtr,c.fixpt.pos,c.fixpt.size,[255 0 0]);
            Screen('Flip',c.display.windowPtr);
            %Update time counter and check whether time is up
            t = GetSecs - t0;
            runStim = t < c.time.totaldur;
            
        else %if escaped, end the stimulus
            c.display.open = false;
            c.recorded.escaped = true;
            runStim = false;
            sca;
        end
    end
    c.recorded.stimEnd = GetSecs - t0;
    c.recorded.stimStart = c.recorded.onsets(1);
    c.recorded.stimDurtn = c.recorded.stimEnd - c.recorded.stimStart;
catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca; c.display.open = false;
    commandwindow;
    myerr.message
    myerr.stack.line
    
end %try..catch.

