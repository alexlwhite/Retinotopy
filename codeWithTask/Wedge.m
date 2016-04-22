% c = Wedge(display, carrier, time)
%
% Alex White, using code from Paola Binda & Geoff Boynton
%
% For retinotopic mapping, displays the "Wedge" stimulus: rotating wedge of
% radial checkerboard.
%
% Input: a structure "c" with the following substucture fields: 
% - display: structure for psychtoolbox screen
% - carrier: structure with parameters for carrier texture (radial
% checkerboard)
% - fixpt: structure with parameters for fixation point 
% - time: structure with paramters for stimulus timing
% - task: structure with paramters for task
%
%
% Outputs:
% - c: structure containing all the inputs, as well as c.recorded.onsets,
% which has time stamps of stimulus onsets
% 
% %Feb 5 2016: edited so that Wedge starts vertically (c.mask.startAngle = -90)

function c = Wedge(c)

commandwindow

%% parameters of the stimuli: visible wedge

c.mask = c.wedgeMask; % load parameters of mask from preset wedgeMask;

if ~c.mask.clockwise
    c.mask.Angles = c.mask.Angles(end:-1:1);
end

%% make task events
c = makeRetinotopyTask(c);

%% start PTB loop
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
    %background circle
    c.fixpt.pos = myPix([0 0],[],c.display);
    c.fixpt.size = myPix([],[c.fixpt.sizeDeg],c.display);
    
    angles = [0 90];
    allxy = [];
    for ai = 1:2
        startxy = myPix([0 0]-0.5*c.fixpt.sizeDeg*[cosd(angles(ai)) sind(angles(ai))],[],c.display);
        endxy = myPix([0 0]+0.5*c.fixpt.sizeDeg*[cosd(angles(ai)) sind(angles(ai))],[],c.display);
        %newxy = [startx endx; starty endy];
        newxy = [startxy' endxy']; 
        allxy = [allxy newxy];
    end
    c.fixpt.allxy = allxy;
    
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
                
                 %task events 
                taskChunk = ceil(elapsedTime/c.task.timeUnits);
                taskEvent = c.task.events(taskChunk);
                taskEventNum = c.task.respEventIs(taskChunk);
                taskFeedback = c.task.feedback(taskChunk);
                
                fixtnColorI = 1 + taskFeedback;
                crossColorI = 1 + (taskEvent == 1); 
                carrierContrastI = 1 + (taskEvent == 2);
                correctResp = c.task.correctResps(taskChunk);
                
                if thisCycle <= c.time.NCycles
                    Screen('DrawTexture', c.display.windowPtr, Carrier_TxtPtr(carrierContrastI,flickState),[],...
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
            %draw fixation mark 
            Screen('DrawDots',c.display.windowPtr,c.fixpt.pos,c.fixpt.size,c.fixpt.backColor(fixtnColorI,:),[],c.fixpt.type);           
            Screen('DrawLines',c.display.windowPtr, c.fixpt.allxy, c.fixpt.crossThick, c.fixpt.crossColor(crossColorI,:),[],c.fixpt.type); 
   
            Screen('Flip',c.display.windowPtr);
            
            % check for keypress 
            keyPressed = checkTarPress(c.task.buttons);
   
            %determine whether this was the correct response given task
            %events
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
    
    %task performance
    lastEvent = max(c.task.respEventIs(1:taskChunk));
    eHits = c.task.eventsHit(1:lastEvent);
    eTypes = c.task.eventTypes(1:lastEvent);
    for tt = c.task.whichStim
        c.recorded.hitRate(tt) = mean(eHits(eTypes==tt)==1);
    end
    
    %c.recorded.hitRate = mean(c.task.eventsHit==1); 
    c.recorded.nFalseAlarms = c.task.nFalseAlarm;
    c.recorded.wrongStimRate = mean(c.task.eventsHit==-1); catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca; c.display.open = false;
    commandwindow;
    myerr.message
    myerr.stack.line
    
end %try..catch.

